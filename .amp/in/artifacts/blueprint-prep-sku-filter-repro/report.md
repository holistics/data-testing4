# Blueprint Prep SKU filter reproduction

## Review link

https://testing4.holistics.io/studio/projects/30434/explore/team-folders/Chinh/blueprint-prep-sku-filter-repro/blueprint_prep_sku_filter_repro.page.aml?branch=chinh-dm-dev

This is an unpublished Development preview on `chinh-dm-dev`; it is not a Production Reporting URL.

## Reproduced behavior

- The PostgreSQL Query Model generates 125,000 distinct SKUs directly with `generate_series()`: 25,000 each for `PLEVEL400`, `PLEVEL401`, `PLEVEL1400`, `PLEVEL1401`, and control group `PLEVEL500`.
- AQL returned 125,000 total distinct SKUs and 25,000 per Product Level.
- AQL `Contains 400` returned `PLEVEL400` and `PLEVEL1400`, 25,000 each.
- AQL `Contains 401` returned `PLEVEL401` and `PLEVEL1401`, 25,000 each.
- AQL `Starts With AMCAT_PLEVEL400_` returned only `PLEVEL400`, 25,000.
- AQL exact Product Level selection returned 100,000 SKUs across the four requested levels and excluded `PLEVEL500`.

## Headed browser verification

Tested in headed Google Chrome using an isolated clone of the local `holistics.io` profile on CDP port `9333`.

- `Contains` exposes one text input. `Contains 400` showed `PLEVEL400` and `PLEVEL1400`, 25,000 each.
- `Starts With` exposes one text input. `AMCAT_PLEVEL400_` showed only `PLEVEL400`, 25,000. The final query update took 2.702 seconds.
- Raw SKU `Is` reported: `Loaded 200 out of 125000 available options.` The already-prefetched list opened in 0.103 seconds after a full dashboard navigation. This testing4 timing does not represent Blueprint Prep's environment.
- Product Level `Is` accepted the four requested values. The final query update took 2.905 seconds and showed four 25,000-SKU groups, totalling 100,000; `PLEVEL500` was excluded.

## Primary evidence

- `screenshots/01-initial-contains-400.png`
- `screenshots/02-text-operator-menu-single-input.png`
- `screenshots/04-starts-with-prefix-result.png`
- `screenshots/06-sku-is-high-cardinality-list.png`
- `screenshots/09-product-level-four-values-result.png`
- `screenshots/11-final-default-contains-400.png`

Other screenshots and timing files in this directory record intermediate browser states and diagnostics.
