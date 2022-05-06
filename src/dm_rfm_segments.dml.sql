-- fill dm_rfm_segments table
TRUNCATE TABLE analysis.dm_rfm_segments;

INSERT INTO analysis.dm_rfm_segments
WITH cte_raw AS (
    SELECT
        user_id   as user_id,
        MIN(LOCALTIMESTAMP - ts) as recency,
        COUNT(*)  as frequency,
        SUM(cost) as monetary_value
    FROM
        analysis.orders
    GROUP BY
        user_id
)
SELECT
    user_id,
    NTILE(5) OVER (ORDER BY recency DESC) as "recency",
    NTILE(5) OVER (ORDER BY frequency ASC) as "frequency",
    NTILE(5) OVER (ORDER BY monetary_value ASC) as "monetary_value"
FROM
    cte_raw
;