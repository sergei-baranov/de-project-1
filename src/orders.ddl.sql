-- create orders view
CREATE OR REPLACE VIEW analysis.orders AS

SELECT
    o.order_id as id,
    u.id       as user_id,
    o.cost     as cost,
    o.order_ts as ts
FROM
    production.users u
    INNER JOIN production.orders o ON o.user_id = u.id
    INNER JOIN production.orderstatuses s ON s.id = o.status
WHERE
    s.key = 'Closed'
    AND o.cost > 0.0
    AND EXTRACT('year' FROM o.order_ts) >= 2021.0
;