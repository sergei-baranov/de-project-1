-- create orders view by production.orderstatuslog
DROP VIEW IF EXISTS analysis.orders;
-- насколько я понял из конекста,
-- надо учесть ещё и пользователей без закзов вовсе,
-- отсюда ниже COALESCE, для кластеризации последующей
CREATE OR REPLACE VIEW analysis.orders AS
WITH cte_statuses AS (
    SELECT DISTINCT
        order_id,
        first_value(status_id) OVER (
            PARTITION BY order_id ORDER BY dttm DESC
        ) as status
    FROM
        production.orderstatuslog
)
SELECT
    u.id                                  as user_id,
    COALESCE(o.cost, 0)                   as cost,
    COALESCE(o.order_ts, to_timestamp(1)) as ts
FROM
    production.users u
    LEFT JOIN production.orders o ON o.user_id = u.id
    LEFT JOIN cte_statuses cs ON cs.order_id = o.order_id
    LEFT JOIN production.orderstatuses s ON s.id = cs.status
WHERE
    (s.key IS NULL OR s.key = 'Closed')
    AND (o.cost IS NULL OR o.cost > 0.0)
    AND (o.order_ts IS NULL OR EXTRACT('year' FROM o.order_ts) >= 2021.0)
;