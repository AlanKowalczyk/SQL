-----------------------------------------
-- Created on 21 Apr 2024              --
-- Last modification 22 Apr 2024 by AK --
-- author Alan Kowalczyk               --
-----------------------------------------


CREATE OR REPLACE VIEW order_view
AS
SELECT
    c.first_name || ' ' || c.last_name AS client,
    p.product_name AS product,
    o.quantity AS quantity,
    p.price AS price,
    o.quantity * p.price AS total_value
FROM orders o
    JOIN customers c on o.customer_id = c.id
    JOIN products p on p.id = o.product_id
ORDER BY client ASC;

CREATE OR REPLACE VIEW inventory_view
AS
SELECT
    p.product_name AS product,
    i.quantity AS quantity,
    p.price AS price,
    i.quantity * p.price AS total_value
FROM inventories i
    JOIN products p on p.id = i.product_id
ORDER BY quantity ASC;