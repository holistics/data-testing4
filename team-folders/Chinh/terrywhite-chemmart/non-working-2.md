# Non-Working Version 2

I use the parameter as the filter by applying it inside the metric with a where clause against the Sales Fact date. For the LY calculation, I use the Sales Fact date column as the relative_period offset.

## Table Fields:

- Date
- Sales $ (Parameter Filtered | Date Fact)
- Sales $ (LY) (Parameter Filtered | Date Fact)

## Conditions:

- Date Parameter matches Last Month

## Holistics SQL:

```sql
SELECT
  toDate("aql__t3"."dim_date_test_shift_tm->date") AS "ddtst_d_cb08f8",
  "aql__t3"."fact_sales_test_shift_tm->fact_sales_total_sales_amount" AS "fact_sales_total_sales_amount_param_filtered_date_fact",
  "aql__t3"."fact_sales_test_shift_tm->fact_sales_total_sales_amount" AS "fact_sales_total_sales_amount_param_filtered_date_fact_ly"
FROM
  (
    SELECT
      "dim_date_test_shift_tm"."Date" AS "dim_date_test_shift_tm->date",
      SUM("fact_sales_test_shift_tm"."SalesAmount") AS "fact_sales_test_shift_tm->fact_sales_total_sales_amount"
    FROM
      Fact_Sales "fact_sales_test_shift_tm"
      LEFT JOIN Dim_Date "dim_date_test_shift_tm" ON "fact_sales_test_shift_tm"."Date" = "dim_date_test_shift_tm"."Date"
    WHERE
      ("fact_sales_test_shift_tm"."Date" >= toDate('2026-04-01'))
      AND ("fact_sales_test_shift_tm"."Date" < toDate('2026-05-01'))
    GROUP BY
      "dim_date_test_shift_tm"."Date"
  ) "aql__t3"
ORDER BY
  toDate("aql__t3"."dim_date_test_shift_tm->date") ASC NULLS LAST
LIMIT
  5000
```
