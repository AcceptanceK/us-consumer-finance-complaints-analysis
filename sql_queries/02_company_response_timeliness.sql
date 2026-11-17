WITH company_stats AS (
    SELECT
        company,
        COUNT(DISTINCT complaint_id)                                           AS total_complaints,
        COUNT(DISTINCT complaint_id) FILTER (WHERE timely_response = 'No')     AS untimely_responses,
        COUNT(DISTINCT complaint_id) FILTER (WHERE timely_response IN ('Yes', 'No'))
                                                                               AS known_status_complaints
    FROM complaints_clean
    GROUP BY company
    HAVING COUNT(DISTINCT complaint_id) >= 30
),
company_rates AS (
    SELECT
        company,
        total_complaints,
        untimely_responses,
        ROUND(
            100.0 * untimely_responses / NULLIF(known_status_complaints, 0),
            1
        ) AS untimely_rate
    FROM company_stats
)
SELECT
    company,
    total_complaints,
    untimely_responses,
    untimely_rate,
    DENSE_RANK() OVER (ORDER BY untimely_responses DESC)           AS untimely_volume_rank,
    DENSE_RANK() OVER (ORDER BY untimely_rate DESC NULLS LAST)     AS untimely_rate_rank
FROM company_rates
ORDER BY untimely_volume_rank, untimely_rate_rank, company
LIMIT 20;