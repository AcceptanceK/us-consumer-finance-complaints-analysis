
WITH combos AS (
    SELECT
        company,
        product,
        state,
        COUNT(DISTINCT complaint_id) AS total_complaints,
        COUNT(DISTINCT complaint_id) FILTER (
            WHERE timely_response = 'No'
        ) AS untimely_responses,
        COUNT(DISTINCT complaint_id) FILTER (
            WHERE timely_response IN ('Yes', 'No')
        ) AS known_status_complaints
    FROM complaints_clean
    WHERE product IN ('Checking or savings account', 'Credit card')
      AND company IS NOT NULL
      AND UPPER(TRIM(company)) NOT IN ('', 'NONE')
      AND state IS NOT NULL
      AND UPPER(TRIM(state)) NOT IN ('', 'NONE')
    GROUP BY
        company,
        product,
        state
),

company_totals AS (
    SELECT
        company,
        COUNT(DISTINCT complaint_id) AS company_total_complaints
    FROM complaints_clean
    WHERE product IN ('Checking or savings account', 'Credit card')
      AND company IS NOT NULL
      AND UPPER(TRIM(company)) NOT IN ('', 'NONE')
    GROUP BY company
),

with_company_total AS (
    SELECT
        c.company,
        c.product,
        c.state,
        c.total_complaints,
        c.untimely_responses,
        c.known_status_complaints,
        ct.company_total_complaints
    FROM combos c
    INNER JOIN company_totals ct
        ON c.company = ct.company
),

qualified AS (
    SELECT
        company,
        product,
        state,
        total_complaints,
        untimely_responses,

        ROUND(
            100.0 * untimely_responses
            / NULLIF(known_status_complaints, 0),
            1
        ) AS untimely_rate_pct,

        company_total_complaints,

        ROUND(
            100.0 * total_complaints
            / NULLIF(company_total_complaints, 0),
            1
        ) AS share_of_company_pct

    FROM with_company_total
    WHERE total_complaints >= 20
)

SELECT
    company,
    product,
    state,
    total_complaints,
    untimely_responses,
    untimely_rate_pct,
    company_total_complaints,
    share_of_company_pct,

    DENSE_RANK() OVER (
        ORDER BY
            untimely_responses DESC,
            total_complaints DESC
    ) AS priority_rank

FROM qualified
ORDER BY
    priority_rank,
    company,
    product,
    state
LIMIT 20;
