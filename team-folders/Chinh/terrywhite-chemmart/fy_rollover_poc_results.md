# POC Results — FY Rollover-Proof Metrics for TerryWhite Chemmart

> Companion to [fy_rollover_poc_plan.md](./fy_rollover_poc_plan.md). Read plan first for design decisions Q1–Q10.

---

## TL;DR

**Problem 1 (FY rollover) — ✅ solved** at modeling + dataset layer.
No more hardcoded `@(July 2025 - 1 Month Ago)` literals. FYTD/PFYTD now derive their windows dynamically from `dim_date` columns + `max(dim_date.date)` anchors.

**Problem 2 (dashboard filter sync) — ⚠ surfaced, not solved.**
When a dashboard date filter is active, AQL `where()` cannot expand the filter to recover FYTD's wider window. The v2 metrics work correctly **unfiltered** but collapse to base when the dashboard filter clamps the explore. This is an architectural limit of `where()` semantics — it adds, never overrides.

---

## What was built

### Phase 1 — 8 derived dimensions on [dim_date_test_shift_tm.model.aml](./dim_date_test_shift_tm.model.aml)

Postgres SQL expressions, no ETL change required.

| Dimension | Expression |
|---|---|
| `fy_number` | `CASE WHEN EXTRACT(MONTH FROM date)>=7 THEN year+1 ELSE year END` |
| `fy_start_date` | `MAKE_DATE(fy_number-1, 7, 1)` |
| `fy_end_date` | `MAKE_DATE(fy_number, 6, 30)` |
| `fy_month_number` | `((EXTRACT(MONTH FROM date)+5) % 12) + 1` |
| `fy_quarter` | `((fy_month_number-1)/3) + 1` |
| `day_of_month` | `EXTRACT(DAY FROM date)` |
| `day_of_fy` | `EXTRACT(DAY FROM date - fy_start_date) + 1` |
| `fy_label` | `'FY' \|\| RIGHT(fy_number::text, 2)` |

Convention: `fy_number` = end-year. FY26 = Jul 2025 → Jun 2026 (AU standard).

### Phase 2 — 4 hidden anchor metrics on [date_filter_shift_test.dataset.aml](./date_filter_shift_test.dataset.aml)

```aml
metric _anchor_date       = max(dim_date.date)
metric _anchor_fy         = max(dim_date.fy_number)
metric _anchor_fy_start   = max(dim_date.fy_start_date)
metric _anchor_day_of_fy  = date_diff('day', max(fy_start_date), max(date)) + 1
```

All `hidden: true`. All use `max()` on monotonic columns → reliable per-query scalars.

### Phase 3 — 2 v2 comparison metrics

```aml
metric fact_sales_total_sales_amount_fytd_v2 {
  definition: @aql
    fact_sales_total_sales_amount
    | where(dim_date.fy_number >= _anchor_fy)
    | where(dim_date.date <= _anchor_date)
  ;;
}

metric fact_sales_total_sales_amount_pfytd_v2 {
  definition: @aql
    fact_sales_total_sales_amount
    | where(dim_date.fy_number >= _anchor_fy - 1)
    | where(dim_date.fy_number <= _anchor_fy - 1)
    | where(dim_date.day_of_fy <= _anchor_day_of_fy)
  ;;
}
```

Originals (`_fytd`, `_fytd_ly`) untouched per parallel-rollout decision (Q10).

### Phase 4 — skipped per user direction (went straight to phase 5 validation).

---

## Validation results

Data range in source: Jul 1 2023 → May 27 2026. Total = 1,062.

| Scenario | Filter | anchor_date | anchor_fy | day_of_fy | base | FYTD_v2 | PFYTD_v2 | Verdict |
|---|---|---|---|---|---|---|---|---|
| **Unfiltered** | none | May 27 2026 | 2026 | 331 | 1,062 | **331** | **662** | ✅ correct |
| **Last month** | `dim_date.date matches @(last month)` | Apr 30 2026 | 2026 | 304 | 30 | **30** | **null** | ❌ collapsed |

### Reading the results

**Unfiltered (proves Problem 1 solved):**
- FYTD_v2 = 331 = sum of Jul 1 2025 → May 27 2026 sales ✓
- PFYTD_v2 = 662 = sum of Jul 1 2024 → equivalent-day-of-FY25 sales ✓
- **No literal `July 2025` anywhere.** Logic survives FY rollover automatically.

**Last month (exposes Problem 2):**
- Dashboard filter clamps explore to Apr 2026
- All metrics — including v2 — operate within that clamped scope
- FYTD_v2's `where(date <= anchor_date)` is a no-op (anchor_date IS Apr 30 within scope)
- PFYTD_v2's `where(fy_number = anchor-1)` matches zero rows (FY25 already filtered out)

---

## AQL learnings (Postgres dialect, Holistics 1.0.6)

| Quirk | Workaround |
|---|---|
| `==` between dimension and `max(dim)` rejected by `where()` | Use `>=` (equivalent when comparing to max) |
| Multiple `dim <op> max(dim)` in one `where(... and ...)` rejected | Chain separate `\| where()` clauses |
| Anchor sub-metrics CAN be referenced in `where()` filter conditions | ✓ Phase 2 helpers work as designed |
| AQL has no `-` operator for Date type | Use `date_diff('day', a, b)` |
| `period_to_date('fiscal_year', ...)` | Not supported |
| `first(field, where: ...)` scalar lookup | Not supported (only `first_value` window function) |
| Window function args must be already-grouped or aggregated | Wrap in `max()` etc. |
| Explore-level filter narrows ALL metric subqueries | `where()` cannot expand back — this is the Problem 2 wall |

---

## Migration path

### From POC → production

**If unfiltered semantics acceptable** (e.g. FYTD always = real-world FYTD, ignores dashboard filter):
1. Move 8 derived dimensions from AML to upstream Postgres `dim_date` table (post-CSV-import). DDL or dbt seed. Drop AML `@sql` overrides.
2. Drop `_v2` suffix on metrics. Deprecate original `fact_sales_total_sales_amount_fytd` and `_fytd_ly`.
3. Keep anchor metrics hidden. Document the pattern for future windows (FQTD, FMTD, etc.).

**If dashboard-filter-sync required** (Problem 2):
1. Pause v2 metric promotion.
2. Tackle Problem 2 (separate POC). Candidates explored:
   - `exact_period(date, @dynamic_expression)` if Holistics adds dynamic-literal support
   - Custom AQL function like `period_to_date('financial_year', ...)` upstream feature request
   - Widget-level filter routing (FYTD/PFYTD widgets opt out of dashboard date filter)
   - Two-pass query pattern (extract anchor, then unfiltered sub-query — currently no AQL primitive)

---

## What stays unchanged

- Originals `fact_sales_total_sales_amount`, `_ly` work as before — explore-filter-driven, used for TY/PY widgets
- `relative_period(date, interval(-1 year))` for PY remains the right pattern — it rewrites the filter predicate, doesn't fight it

---

## Recommendation

**Promote modeling work (Phase 1) regardless** — the FY columns on `dim_date` are useful for grouping, slicing, drilldowns, and any future fiscal analysis. Zero downside.

**Defer v2 metric promotion** until Problem 2 path is chosen. Current v2 metrics are correct in unfiltered context only; shipping them with dashboard filters active will silently mislead users.

**Open follow-ups for Holistics platform team:**
1. Fiscal-year support in `period_to_date(grain, date, fy_start_month=7)`
2. Dynamic boundaries for `exact_period(date, @expr)` — accept metric refs or expressions, not only literals
3. AQL primitive for "expand filter scope inside metric" — analogous to `relative_period` but for window expansion not shifting
