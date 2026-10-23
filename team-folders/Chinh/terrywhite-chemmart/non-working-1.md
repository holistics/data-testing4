# Non-Working Version 1

I use the parameter as the filter by applying it inside the metric with a where clause against the Date Dimension date. For the LY calculation, I use the Date Dimension date column as the relative_period offset.

## Table Fields:

- Date
- Sales $ (Parameter Filtered | Date Dim)
- Sales $ (LY) (Parameter Filtered | Date Dim)

## Conditions:

- Date Parameter matches Last Month

## Holistics SQL:

```sql
SELECT
  toDate(COALESCE("aql__t3"."dim_date_test_shift_tm->date", "aql__t5"."dim_date_test_shift_tm->date")) AS "ddtst_d_cb08f8",
  MAX("aql__t5"."fact_sales_test_shift_tm->fact_sales_total_sales_amount") AS "fact_sales_total_sales_amount_param_filtered_date_dim",
  MAX("aql__t3"."fact_sales_test_shift_tm->fact_sales_total_sales_amount") AS "fact_sales_total_sales_amount_param_filtered_date_dim_ly"
FROM
  (
    SELECT
      toStartOfDay("dim_date_test_shift_tm"."Date" + INTERVAL 1 YEAR) AS "dim_date_test_shift_tm->date",
      SUM("fact_sales_test_shift_tm"."SalesAmount") AS "fact_sales_test_shift_tm->fact_sales_total_sales_amount"
    FROM
      Fact_Sales "fact_sales_test_shift_tm"
      LEFT JOIN Dim_Date "dim_date_test_shift_tm" ON "fact_sales_test_shift_tm"."Date" = "dim_date_test_shift_tm"."Date"
    WHERE
      (
        ("dim_date_test_shift_tm"."Date" >= toDate('2026-04-01'))
        AND ("dim_date_test_shift_tm"."Date" < toDate('2026-05-01'))
      )
      AND (
        ("dim_date_test_shift_tm"."Date" IS NULL)
        OR (("dim_date_test_shift_tm"."Date" + INTERVAL 1 YEAR + INTERVAL -1 YEAR) = "dim_date_test_shift_tm"."Date")
      )
    GROUP BY
      toStartOfDay("dim_date_test_shift_tm"."Date" + INTERVAL 1 YEAR)
  ) "aql__t3"
  FULL JOIN (
    SELECT
      "dim_date_test_shift_tm"."Date" AS "dim_date_test_shift_tm->date",
      SUM("fact_sales_test_shift_tm"."SalesAmount") AS "fact_sales_test_shift_tm->fact_sales_total_sales_amount"
    FROM
      Fact_Sales "fact_sales_test_shift_tm"
      LEFT JOIN Dim_Date "dim_date_test_shift_tm" ON "fact_sales_test_shift_tm"."Date" = "dim_date_test_shift_tm"."Date"
    WHERE
      ("dim_date_test_shift_tm"."Date" >= toDate('2026-04-01'))
      AND ("dim_date_test_shift_tm"."Date" < toDate('2026-05-01'))
    GROUP BY
      "dim_date_test_shift_tm"."Date"
  ) "aql__t5" ON "aql__t3"."dim_date_test_shift_tm->date" = "aql__t5"."dim_date_test_shift_tm->date"
GROUP BY
  toDate(COALESCE("aql__t3"."dim_date_test_shift_tm->date", "aql__t5"."dim_date_test_shift_tm->date"))
HAVING
  (MAX("aql__t3"."fact_sales_test_shift_tm->fact_sales_total_sales_amount") IS NOT NULL)
  OR (MAX("aql__t5"."fact_sales_test_shift_tm->fact_sales_total_sales_amount") IS NOT NULL)
ORDER BY
  toDate(COALESCE("aql__t3"."dim_date_test_shift_tm->date", "aql__t5"."dim_date_test_shift_tm->date")) ASC NULLS LAST
LIMIT
  5000
```
