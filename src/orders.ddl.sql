-- create orders view
DROP VIEW IF EXISTS analysis.orders;
-- насколько я понял из конекста,
-- надо учесть ещё и пользователей без закзов вовсе,
-- отсюда ниже COALESCE, для кластеризации последующей
CREATE OR REPLACE VIEW analysis.orders AS
WITH
cte_closed_orders AS (
    SELECT
        user_id,
        cost,
        order_ts
    FROM
        production.orders o
        INNER JOIN production.orderstatuses s ON s.id = o.status
    WHERE
        s.key = 'Closed'
        AND EXTRACT('year' FROM o.order_ts) >= 2021.0
)
SELECT
    u.id                                  as user_id,
    COALESCE(o.cost, 0)                   as cost,
    COALESCE(o.order_ts, to_timestamp(1)) as ts
FROM
    production.users u
    LEFT JOIN cte_closed_orders o ON o.user_id = u.id
;