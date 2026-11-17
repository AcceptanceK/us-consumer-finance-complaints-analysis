WITH monthly_counts AS (
    SELECT
        product,
        issue,
        DATE_TRUNC('month', date_received AT TIME ZONE 'UTC')::date AS complaint_month,
        COUNT(DISTINCT complaint_id)                                AS complaints
    FROM complaints_clean
    WHERE date_received >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
      AND date_received <  TIMESTAMPTZ '2025-04-01 00:00:00+00'
      AND product IN ('Checking or savings account', 'Credit card')
    GROUP BY
        product,
        issue,
        DATE_TRUNC('month', date_received AT TIME ZONE 'UTC')::date
),
pivoted AS (
    SELECT
        product,
        issue,
        COALESCE(SUM(complaints) FILTER (WHERE complaint_month = DATE '2025-01-01'), 0) AS jan_complaints,
        COALESCE(SUM(complaints) FILTER (WHERE complaint_month = DATE '2025-02-01'), 0) AS feb_complaints,
        COALESCE(SUM(complaints) FILTER (WHERE complaint_month = DATE '2025-03-01'), 0) AS mar_complaints
    FROM monthly_counts
    GROUP BY product, issue
),
metrics AS (
    SELECT
        product,
        issue,
        jan_complaints,
        feb_complaints,
        mar_complaints,
        jan_complaints + feb_complaints + mar_complaints                AS quarterly_total,
        mar_complaints - feb_complaints                                 AS feb_to_mar_change,
        ROUND(
            100.0 * (mar_complaints - feb_complaints)
            / NULLIF(feb_complaints, 0),
            1
        )                                                               AS feb_to_mar_growth_pct,
        ROUND((jan_complaints + feb_complaints + mar_complaints) / 3.0, 1) AS three_month_avg
    FROM pivoted
    WHERE jan_complaints + feb_complaints + mar_complaints >= 100
)
SELECT
    product,
    issue,
    jan_complaints,
    feb_complaints,
    mar_complaints,
    quarterly_total,
    feb_to_mar_change,
    feb_to_mar_growth_pct,
    three_month_avg,
    DENSE_RANK() OVER (ORDER BY feb_to_mar_change DESC) AS growth_rank
FROM metrics
ORDER BY growth_rank, quarterly_total DESC, product, issue
LIMIT 15;