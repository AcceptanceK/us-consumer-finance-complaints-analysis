
WITH monthly_counts AS (
    SELECT
        product,
        DATE_TRUNC(
            'month',
            date_received AT TIME ZONE 'UTC'
        )::date AS complaint_month,
        COUNT(DISTINCT complaint_id) AS total_complaints
    FROM complaints_clean
    WHERE date_received >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
      AND date_received <  TIMESTAMPTZ '2025-04-01 00:00:00+00'
    GROUP BY
        product,
        DATE_TRUNC(
            'month',
            date_received AT TIME ZONE 'UTC'
        )::date
),

product_months AS (
    SELECT
        p.product,
        m.complaint_month
    FROM (
        SELECT DISTINCT product
        FROM monthly_counts
    ) p
    CROSS JOIN (
        SELECT GENERATE_SERIES(
            DATE '2025-01-01',
            DATE '2025-03-01',
            INTERVAL '1 month'
        )::date AS complaint_month
    ) m
),

filled AS (
    SELECT
        pm.product,
        pm.complaint_month,
        COALESCE(mc.total_complaints, 0) AS total_complaints
    FROM product_months pm
    LEFT JOIN monthly_counts mc
        ON mc.product = pm.product
       AND mc.complaint_month = pm.complaint_month
),

with_previous AS (
    SELECT
        product,
        complaint_month,
        total_complaints,
        LAG(total_complaints) OVER (
            PARTITION BY product
            ORDER BY complaint_month
        ) AS previous_month_complaints
    FROM filled
)

SELECT
    product,
    complaint_month,
    total_complaints,
    previous_month_complaints,

    total_complaints - previous_month_complaints
        AS monthly_change,

    ROUND(
        100.0 * (total_complaints - previous_month_complaints)
        / NULLIF(previous_month_complaints, 0),
        1
    ) AS monthly_growth_pct

FROM with_previous
ORDER BY product, complaint_month;
