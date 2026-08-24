# POC Plan — FY Rollover-Proof Metrics for TerryWhite Chemmart

> Scope: **Problem 1 only** — kill hardcoded FY literals in metrics so FYTD/PFYTD survive financial-year rollover without manual edits.
> Problem 2 (dashboard-filter-end sync) is acknowledged but deferred.

---

## Context

### Customer

TerryWhite Chemmart — Australia, FY starts **July 1**.

### Base setup

- Models: [dim_date_test_shift_tm.model.aml](./dim_date_test_shift_tm.model.aml), [fact_sales_test_shift_tm.model.aml](./fact_sales_test_shift_tm.model.aml)
- Dataset: [date_filter_shift_test.dataset.aml](./date_filter_shift_test.dataset.aml)
- Dashboard: [terrywhite_chemmart.page.aml](./terrywhite_chemmart.page.aml)
- Data source: `demodb` (Postgres) — CSV-imported, persisted in `persisted_models` schema

### Problems addressed

1. **FY rollover maintenance** — `exact_period(@(July 2025 - 1 Month Ago))` literals must be hand-edited every July
2. **Metric sprawl** — same `sum(sales_amount)` cloned per window (TY, PY, FYTD, PFYTD, …)

### Bridge from prior thread

Prior investigation (T-019e499e-6ef1-73a1-955f-0d04116d86d8) settled the filter-wiring debate: use `dim_date.date` at explore level — `relative_period` shifts correctly. Parameter-inside-metric pattern is broken; ignore.

---

## Design decisions (resolved via grill-me)

| #   | Branch            | Decision                                                                                                                      |
| --- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Q1  | FY semantics home | Precomputed columns on `dim_date`                                                                                             |
| Q2  | Column set        | All: `fy_number`, `fy_start_date`, `fy_end_date`, `fy_quarter`, `fy_month_number`, `day_of_fy`, `fy_label`                    |
| Q3  | Compute location  | Upstream ETL (Postgres) — **POC fallback**: AML derived dimensions, since dim_date is CSV-imported                            |
| Q4  | Edge cases        | Leap-pair `(fy_month_number, day_of_month)`; `fy_number` = end-year (FY26 = Jul 2025–Jun 2026)                                |
| Q5  | FYTD endpoint     | Dashboard filter end date                                                                                                     |
| Q6  | Filter→FY bridge  | Metric AQL: `max(dim_date.date)` + `first(dim_date.fy_number where date = max)`                                               |
| Q7  | Anchor pattern    | Helper sub-metrics OR inline (both OK — validate AQL syntax first)                                                            |
| Q8  | PFYTD shift       | **Column-based** (`fy_number - 1` + leap-pair compare). NOT `relative_period(-1 year)` — that shifts dashboard filter, not FY |
| Q9  | Helper placement  | Dataset-level                                                                                                                 |
| Q10 | Rollout           | Parallel `_v2` metrics (POC side-by-side compare)                                                                             |

---

## Decision tree

```diagram
Problem 1: FY rollover maintenance
│
├── Q1: Where do FY semantics live?
│   ├── (A) ✅ Precomputed columns on dim_date
│   ├── (B) AML derived dimensions (POC fallback)
│   ├── (C) Separate dim_financial_year table
│   └── (D) Calculated per metric (status quo)
│
├── Q2: Which FY columns?
│   └── ✅ ALL: fy_number, fy_start_date, fy_end_date,
│              fy_quarter, fy_month_number, day_of_fy, fy_label
│
├── Q3: Where compute them?
│   ├── (A) Upstream Postgres ETL  ← target end-state
│   ├── (B) ✅ Holistics AML model  ← POC (CSV-imported tables)
│   └── (C) Warehouse view
│
├── Q5: FYTD endpoint?
│   ├── (i) today()
│   ├── (ii) ✅ Dashboard filter end date
│   └── (iii) Latest fact_sales.date
│
├── Q6: How does metric bridge filter → FY?
│   ├── (A) ✅ Metric AQL: max(dim_date.date) + first(fy_number where date=max)
│   ├── (B) Helper dimension on dim_date
│   ├── (C) Native period_to_date('fiscal_year', ...) ❌ not supported
│   └── (D) Two-step pipe (still needs literal)
│
├── Q7: Anchor pattern?
│   ├── (A) Inline in every metric
│   ├── (B) Helper sub-metrics (_anchor_date, _anchor_fy, ...)
│   └── ✅ Either — validate AQL syntax via holistics mcp first
│
├── Q8: PFYTD shift?
│   ├── (A) ✅ Column-based: fy_number - 1 + leap-pair
│   ├── (B) relative_period(-1 year) ❌ shifts filter, not FY
│   └── (C) Hybrid (rejected)
│
├── Q9: Where helpers live?
│   └── ✅ (A) Dataset-level
│
└── Q10: Rollout?
    └── ✅ (B) Parallel _v2 metrics for POC
```

---

## Tooling

- Skills: `develop-amql`, `search-docs`, `analyze-data`, `visualize-data`
- CLI: `holistics sync-code --background`, `holistics aml validate`
- MCP: `validate_aql`, `execute_aql`, `fetch_dataset`, `search_docs`
- Dataset uname: `date_filter_shift_test`

---

## Phases

### Phase 0 — Environment ✅ done

- CLI `1.0.6` working
- Local AML compiles clean
- Sync up-to-date on branch `chinh-dm-dev`
- MCP `fetch_dataset`, `validate_aql`, `search_docs` reachable
- ⚠ MCP `execute_aql` returning server-side 500 — defer number validation to phase 5

### Phase 1 — Add FY derived dimensions to dim_date model

File: [dim_date_test_shift_tm.model.aml](./dim_date_test_shift_tm.model.aml)

Add 7 derived dimensions (Postgres SQL via `@sql {{ #SOURCE.date }}` expressions):

| Dimension         | Type   | Postgres expression sketch                                                                                  |
| ----------------- | ------ | ----------------------------------------------------------------------------------------------------------- | --- | -------------------------- |
| `fy_number`       | number | `CASE WHEN EXTRACT(MONTH FROM date) >= 7 THEN EXTRACT(YEAR FROM date) + 1 ELSE EXTRACT(YEAR FROM date) END` |
| `fy_start_date`   | date   | `MAKE_DATE(fy_number - 1, 7, 1)`                                                                            |
| `fy_end_date`     | date   | `MAKE_DATE(fy_number, 6, 30)`                                                                               |
| `fy_month_number` | number | `((EXTRACT(MONTH FROM date)::int + 5) % 12) + 1`                                                            |
| `day_of_month`    | number | `EXTRACT(DAY FROM date)`                                                                                    |
| `day_of_fy`       | number | `(date - fy_start_date)::int + 1`                                                                           |
| `fy_label`        | text   | `'FY'                                                                                                       |     | RIGHT(fy_number::text, 2)` |

**Validation:** `holistics aml validate` + `holistics mcp validate_aql` probing each new dim.

**Output:** dim_date model with 7 new dimensions, all visible during POC (hide post-validation).

### Phase 2 — Add anchor helper metrics to dataset

File: [date_filter_shift_test.dataset.aml](./date_filter_shift_test.dataset.aml)

Hidden helper metrics (prefix `_anchor_`):

- `_anchor_date` = `max(dim_date_test_shift_tm.date)`
- `_anchor_fy` = `first(dim_date_test_shift_tm.fy_number, where: dim_date_test_shift_tm.date = _anchor_date)`
- `_anchor_fy_month` = same pattern on `fy_month_number`
- `_anchor_day_of_month` = same pattern on `day_of_month`

⚠ AQL syntax of `first(... where: ...)` and cross-metric refs in `where` needs MCP validation. If unsupported → fall back to inline (Q7-A) in phase 3.

**Validation:** `validate_aql` each helper individually.

**Output:** 4 hidden anchor metrics.

### Phase 3 — Add `_v2` comparison metrics (parallel)

Same dataset file. Originals untouched.

`fact_sales_total_sales_amount_fytd_v2`:

```
base
| where(
    dim_date_test_shift_tm.fy_number = _anchor_fy
    and dim_date_test_shift_tm.date <= _anchor_date
  )
```

`fact_sales_total_sales_amount_pfytd_v2`:

```
base
| where(
    dim_date_test_shift_tm.fy_number = _anchor_fy - 1
    and (
      dim_date_test_shift_tm.fy_month_number < _anchor_fy_month
      or (dim_date_test_shift_tm.fy_month_number = _anchor_fy_month
          and dim_date_test_shift_tm.day_of_month <= _anchor_day_of_month)
    )
  )
```

(Tuple compare unrolled — AQL likely lacks native tuple compare.)

**Validation:** `validate_aql` on both v2 metrics.

**Output:** 2 new metrics. Existing `_fytd` / `_fytd_ly` untouched.

### Phase 4 — Side-by-side comparison block on dashboard

File: [terrywhite_chemmart.page.aml](./terrywhite_chemmart.page.aml)

Add new `VizBlock` (e.g. `v_fytd_compare`) with `DataTable`:

- Columns: `date`, `sales_amount` (base), `fytd_v2`, `pfytd_v2`
- Viz-level filter: `dim_date_test_shift_tm.date matches 'last month'` (proven pattern from `v_1iiv`/`v_kum1` working block)

**Output:** one new block on existing page.

### Phase 5 — Validate numbers via `execute_aql`

Retry once server 500 clears. Scenarios:

| Filter                  | Expected FYTD window     | Expected PFYTD window    |
| ----------------------- | ------------------------ | ------------------------ |
| `last month` (Apr 2026) | Jul 1 2025 → Apr 30 2026 | Jul 1 2024 → Apr 30 2025 |
| `Jul 2025`              | Jul 1 2025 → Jul 31 2025 | Jul 1 2024 → Jul 31 2024 |
| `Jun 2025`              | Jul 1 2024 → Jun 30 2025 | Jul 1 2023 → Jun 30 2024 |

**Cross-FY-boundary test (3rd row) is the proof point** — kills the literal-driven failure mode.

Use skill `analyze-data` to render `result_data` as markdown.

### Phase 6 — Document POC outcome

Write `fy_rollover_poc_results.md` in this folder:

- Old (literal) vs new (v2) numbers side-by-side
- Promotion path: lift derived dims to Postgres columns; rename `_v2` → drop suffix; deprecate hardcoded `_fytd` / `_fytd_ly`

---

## Division of labor

**My side (agent):**

- Edit AML (phases 1, 2, 3, 4)
- Run `validate_aql`, `execute_aql` via MCP
- Build comparison table
- Draft results doc

**Your side (Chinh):**

- Confirm cloud-side commits when sync stages new files
- Approve dashboard layout addition (new block on existing page)
- Eyeball plausibility once POC renders in UI
- Retry `execute_aql` from UI if MCP 500 persists

**Expected deliverables:**

- 1 model file updated (7 new dims)
- 1 dataset file updated (4 anchors + 2 v2 metrics)
- 1 dashboard block added
- 1 results doc

---

## Risks

- **AQL syntax** for `first(..., where: ...)` and sub-metric refs inside `where` may differ — fallback to inline anchor pattern. No functional impact, just more verbose.
- **CSV column types** — if dim_date `date` column landed as `text` not `date`, Postgres date-math expressions need casts.
- **MCP `execute_aql` 500** — currently server-down for all datasets. Blocks phase 5. Workaround: validate in Holistics UI.
- **Cloud-side staged files** — sync sometimes leaves files in "uncommitted" state on cloud, blocking MCP queries until cloud commit happens.
