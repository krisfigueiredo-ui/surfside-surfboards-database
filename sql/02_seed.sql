-- Synthetic demonstration records only. No real customer data.
USE surfside;

INSERT INTO customers
  (customer_id, first_name, last_name, date_of_birth, pro_global_ranking, veteran_id)
VALUES
  (1, 'Casey', 'Reef', '1994-04-12', 18, NULL),
  (2, 'Jordan', 'Cove', '1988-09-21', NULL, 'DEMO-VET-1042'),
  (3, 'Morgan', 'Tide', '1998-02-03', 64, 'DEMO-VET-2051'),
  (4, 'Taylor', 'Break', '1991-07-15', NULL, NULL),
  (5, 'Riley', 'Shore', '2000-11-08', 103, NULL),
  (6, 'Avery', 'Current', '1985-01-29', NULL, NULL);

INSERT INTO customer_phones
  (customer_id, phone_type, phone_number, is_primary)
VALUES
  (1, 'mobile', '555-010-1001', TRUE),
  (1, 'work',   '555-010-1002', FALSE),
  (2, 'mobile', '555-010-2001', TRUE),
  (3, 'mobile', '555-010-3001', TRUE),
  (4, 'home',   '555-010-4001', TRUE),
  (5, 'mobile', '555-010-5001', TRUE),
  (6, 'mobile', '555-010-6001', TRUE);

INSERT INTO components
  (component_id, component_name, component_type, unit_cost)
VALUES
  (1, 'Short Fiberglass Deck', 'deck', 210.00),
  (2, 'Medium Carbon Deck', 'deck', 320.00),
  (3, 'Long Wood Deck', 'deck', 275.00),
  (4, 'Standard Leash', 'leash', 24.00),
  (5, 'Reinforced Pro Leash', 'leash', 39.00),
  (6, 'Single Fin Set', 'fin', 42.00),
  (7, 'Twin Fin Set', 'fin', 58.00),
  (8, 'Triple Fin Set', 'fin', 76.00),
  (9, 'Spare Triple Fin Set', 'spare', 76.00);

INSERT INTO surfboards
  (surfboard_id, board_name, board_description)
VALUES
  (1, 'Short Pro', 'Performance short board for demanding surf conditions.'),
  (2, 'Carbon Twin', 'Responsive medium carbon board with a twin-fin setup.'),
  (3, 'Classic Long', 'Stable long wood board designed for smooth cruising.'),
  (4, 'Reef Utility', 'Durable short board with reinforced leash and spare fins.');

INSERT INTO surfboard_components
  (surfboard_id, component_id, component_quantity)
VALUES
  (1, 1, 1), (1, 5, 1), (1, 8, 1),
  (2, 2, 1), (2, 4, 1), (2, 7, 1),
  (3, 3, 1), (3, 4, 1), (3, 6, 1),
  (4, 1, 1), (4, 5, 1), (4, 8, 1), (4, 9, 1);

INSERT INTO orders
  (order_id, customer_id, order_date, order_status)
VALUES
  (1001, 1, '2026-01-14', 'fulfilled'),
  (1002, 2, '2026-02-08', 'fulfilled'),
  (1003, 3, '2026-02-23', 'fulfilled'),
  (1004, 1, '2026-03-19', 'fulfilled'),
  (1005, 4, '2026-04-05', 'fulfilled'),
  (1006, 5, '2026-05-11', 'paid'),
  (1007, 3, '2026-06-17', 'fulfilled'),
  (1008, 2, '2026-06-21', 'cancelled');

INSERT INTO order_items
  (order_id, surfboard_id, quantity, unit_price)
VALUES
  (1001, 1, 1, 499.00),
  (1001, 4, 1, 579.00),
  (1002, 3, 1, 469.00),
  (1003, 2, 2, 649.00),
  (1004, 1, 1, 499.00),
  (1005, 3, 1, 469.00),
  (1005, 2, 1, 649.00),
  (1006, 4, 1, 579.00),
  (1007, 1, 2, 499.00),
  (1008, 2, 1, 649.00);

INSERT INTO reviews
  (order_id, rating, review_text)
VALUES
  (1001, 5, 'Stable at speed and the fixed component package felt well balanced.'),
  (1002, 4, 'The long board tracked smoothly and arrived as described.'),
  (1003, 5, 'Both boards were consistent and ready for regular training use.'),
  (1004, 3, 'Strong performance, though the leash could use a clearer care guide.'),
  (1005, 4, 'Good range across two different board styles.');
