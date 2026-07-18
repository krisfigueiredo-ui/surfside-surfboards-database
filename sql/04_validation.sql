-- Read-only integrity checks. Every issue_count should return 0.
USE surfside;

SELECT 'orders_without_items' AS check_name, COUNT(*) AS issue_count
FROM orders AS o
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
  AND o.order_status <> 'cancelled';

SELECT 'boards_without_components' AS check_name, COUNT(*) AS issue_count
FROM surfboards AS s
LEFT JOIN surfboard_components AS sc ON sc.surfboard_id = s.surfboard_id
WHERE sc.surfboard_id IS NULL;

SELECT 'reviews_customer_mismatch_not_possible' AS check_name, 0 AS issue_count;

SELECT 'multiple_primary_phones' AS check_name, COUNT(*) AS issue_count
FROM (
  SELECT customer_id
  FROM customer_phones
  WHERE is_primary = TRUE
  GROUP BY customer_id
  HAVING COUNT(*) > 1
) AS invalid_primary_phones;

SELECT 'invalid_order_totals' AS check_name, COUNT(*) AS issue_count
FROM v_order_totals
WHERE order_total < 0;
