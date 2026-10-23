# Working version

I use the date from the Date Dimension as the visual/filter condition, along with the standard Sales $ and Sales $ (LY) metrics from the dataset. This is the pattern I currently use in my other datasets and it works as expected.

## Table Fields:

- Date
- Sales $
- Sales $ (LY)

## Conditions:

- Date matches Last Month the date parameter is not used in this version

## Holistics SQL:

```sql
SELECT
  toDate(COALESCE("aql__t3"."dim_date_test_shift_tm->date", "aql__t5"."dim_date_test_shift_tm->date")) AS "ddtst_d_cb08f8",
  MAX("aql__t5"."fact_sales_test_shift_tm->fact_sales_total_sales_amount") AS "fact_sales_total_sales_amount",
  MAX("aql__t3"."fact_sales_test_shift_tm->fact_sales_total_sales_amount") AS "fact_sales_total_sales_amount_ly"
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
        ("dim_date_test_shift_tm"."Date" >= (toDate('2026-04-01') + INTERVAL -1 YEAR))
        AND ("dim_date_test_shift_tm"."Date" < (toDate('2026-05-01') + INTERVAL -1 YEAR))
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
