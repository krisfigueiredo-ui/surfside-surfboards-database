-- Quarterly management questions from the original business rules.
USE surfside;

SET @quarter_start = '2026-01-01';
SET @quarter_end = '2026-04-01';

-- 1. Highest-spending customer in the selected quarter.
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  ROUND(SUM(vot.order_total), 2) AS quarter_spend
FROM v_order_totals AS vot
JOIN customers AS c
  ON c.customer_id = vot.customer_id
WHERE vot.order_date >= @quarter_start
  AND vot.order_date < @quarter_end
  AND vot.order_status IN ('paid', 'fulfilled')
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY quarter_spend DESC, c.customer_id
LIMIT 1;

-- 2. Best-selling surfboard by units, with revenue as a secondary measure.
SELECT
  s.surfboard_id,
  s.board_name,
  SUM(oi.quantity) AS units_sold,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue
FROM orders AS o
JOIN order_items AS oi
  ON oi.order_id = o.order_id
JOIN surfboards AS s
  ON s.surfboard_id = oi.surfboard_id
WHERE o.order_date >= @quarter_start
  AND o.order_date < @quarter_end
  AND o.order_status IN ('paid', 'fulfilled')
GROUP BY s.surfboard_id, s.board_name
ORDER BY units_sold DESC, gross_revenue DESC, s.surfboard_id
LIMIT 1;

-- 3. Reviews requiring product or service follow-up.
SELECT
  r.review_id,
  r.rating,
  r.review_text,
  o.order_id,
  o.order_date,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM reviews AS r
JOIN orders AS o
  ON o.order_id = r.order_id
JOIN customers AS c
  ON c.customer_id = o.customer_id
WHERE o.order_date >= @quarter_start
  AND o.order_date < @quarter_end
  AND r.rating <= 3
ORDER BY r.rating ASC, r.submitted_at DESC;

-- 4. Board catalog with fixed bill-of-material cost.
SELECT *
FROM v_surfboard_catalog
ORDER BY board_name;

-- 5. Sponsorship candidates: ranked pro surfers and lifetime spend.
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.pro_global_ranking,
  ROUND(COALESCE(SUM(
    CASE WHEN vot.order_status IN ('paid', 'fulfilled') THEN vot.order_total ELSE 0 END
  ), 0), 2) AS lifetime_spend
FROM customers AS c
LEFT JOIN v_order_totals AS vot
  ON vot.customer_id = c.customer_id
WHERE c.pro_global_ranking IS NOT NULL
GROUP BY c.customer_id, c.first_name, c.last_name, c.pro_global_ranking
ORDER BY c.pro_global_ranking ASC;

-- 6. Veteran eligibility is independent of pro status.
SELECT
  customer_id,
  CONCAT(first_name, ' ', last_name) AS customer_name,
  veteran_id,
  pro_global_ranking
FROM customers
WHERE veteran_id IS NOT NULL
ORDER BY last_name, first_name;
