-- Surfside Surfboards
-- Original business rules and database concept: Kristofor Figueiredo
-- SQL implementation reconstructed from the original project brief.
-- Target: MySQL 8.0+

CREATE DATABASE IF NOT EXISTS surfside
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE surfside;

CREATE TABLE customers (
  customer_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  date_of_birth DATE NULL,
  pro_global_ranking INT UNSIGNED NULL,
  veteran_id VARCHAR(80) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id),
  UNIQUE KEY uq_customers_veteran_id (veteran_id),
  CONSTRAINT chk_customers_pro_ranking
    CHECK (pro_global_ranking IS NULL OR pro_global_ranking >= 1)
);

CREATE TABLE customer_phones (
  customer_phone_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id BIGINT UNSIGNED NOT NULL,
  phone_type ENUM('mobile', 'home', 'work', 'other') NOT NULL DEFAULT 'mobile',
  phone_number VARCHAR(30) NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (customer_phone_id),
  UNIQUE KEY uq_customer_phone (customer_id, phone_number),
  CONSTRAINT fk_customer_phones_customer
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE surfboards (
  surfboard_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  board_name VARCHAR(100) NOT NULL,
  board_description VARCHAR(500) NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (surfboard_id),
  UNIQUE KEY uq_surfboards_name (board_name)
);

CREATE TABLE components (
  component_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  component_name VARCHAR(100) NOT NULL,
  component_type ENUM('deck', 'leash', 'fin', 'spare', 'other') NOT NULL,
  unit_cost DECIMAL(10,2) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (component_id),
  UNIQUE KEY uq_components_name_type (component_name, component_type),
  CONSTRAINT chk_components_unit_cost CHECK (unit_cost >= 0)
);

-- The fixed bill of materials for each company-defined board model.
CREATE TABLE surfboard_components (
  surfboard_id BIGINT UNSIGNED NOT NULL,
  component_id BIGINT UNSIGNED NOT NULL,
  component_quantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (surfboard_id, component_id),
  CONSTRAINT chk_surfboard_components_quantity CHECK (component_quantity >= 1),
  CONSTRAINT fk_surfboard_components_board
    FOREIGN KEY (surfboard_id) REFERENCES surfboards (surfboard_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_surfboard_components_component
    FOREIGN KEY (component_id) REFERENCES components (component_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE orders (
  order_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id BIGINT UNSIGNED NOT NULL,
  order_date DATE NOT NULL,
  order_status ENUM('placed', 'paid', 'fulfilled', 'cancelled', 'refunded')
    NOT NULL DEFAULT 'placed',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (order_id),
  KEY idx_orders_customer_date (customer_id, order_date),
  KEY idx_orders_date_status (order_date, order_status),
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- unit_price is captured at sale time so historical revenue does not change
-- when component costs or future board prices change.
CREATE TABLE order_items (
  order_item_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  surfboard_id BIGINT UNSIGNED NOT NULL,
  quantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_item_id),
  UNIQUE KEY uq_order_board (order_id, surfboard_id),
  KEY idx_order_items_board (surfboard_id),
  CONSTRAINT chk_order_items_quantity CHECK (quantity >= 1),
  CONSTRAINT chk_order_items_price CHECK (unit_price >= 0),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_order_items_board
    FOREIGN KEY (surfboard_id) REFERENCES surfboards (surfboard_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE reviews (
  review_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  review_text VARCHAR(2000) NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (review_id),
  UNIQUE KEY uq_reviews_order (order_id),
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_reviews_order
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE OR REPLACE VIEW v_surfboard_catalog AS
SELECT
  s.surfboard_id,
  s.board_name,
  s.is_active,
  COUNT(sc.component_id) AS component_count,
  COALESCE(SUM(c.unit_cost * sc.component_quantity), 0.00) AS component_cost
FROM surfboards AS s
LEFT JOIN surfboard_components AS sc
  ON sc.surfboard_id = s.surfboard_id
LEFT JOIN components AS c
  ON c.component_id = sc.component_id
GROUP BY s.surfboard_id, s.board_name, s.is_active;

CREATE OR REPLACE VIEW v_order_totals AS
SELECT
  o.order_id,
  o.customer_id,
  o.order_date,
  o.order_status,
  COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS order_total
FROM orders AS o
LEFT JOIN order_items AS oi
  ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, o.order_date, o.order_status;
