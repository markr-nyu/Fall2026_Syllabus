-- Order schema query preview
-- These examples show why normalized tables and foreign keys are useful.
-- The setup section creates and populates the schema so the queries return data.
-- A full DML and joins lesson comes later.

PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- DDL: create the normalized order schema
-- ------------------------------------------------------------
-- Drop child tables before parent tables so this script can be rerun.

DROP TABLE IF EXISTS orderLine;
DROP TABLE IF EXISTS customer_order;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
  customerId INTEGER PRIMARY KEY,
  customerName TEXT NOT NULL
);

CREATE TABLE product (
  productId INTEGER PRIMARY KEY,
  productName TEXT NOT NULL,
  manufacturer TEXT NOT NULL,
  color TEXT NOT NULL,
  unitCost REAL NOT NULL CHECK (unitCost >= 0),
  UNIQUE (productName, manufacturer, color)
);

CREATE TABLE customer_order (
  orderId INTEGER PRIMARY KEY,
  customerId INTEGER NOT NULL,
  orderDate TEXT,
  FOREIGN KEY (customerId) REFERENCES customer(customerId)
);

CREATE TABLE orderLine (
  orderId INTEGER NOT NULL,
  orderLineNumber INTEGER NOT NULL,
  productId INTEGER NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (orderId, orderLineNumber),
  FOREIGN KEY (orderId) REFERENCES customer_order(orderId),
  FOREIGN KEY (productId) REFERENCES product(productId)
);

-- ------------------------------------------------------------
-- Small sample dataset
-- ------------------------------------------------------------
-- The sample is intentionally small so the query results are easy to trace.

INSERT INTO customer (customerId, customerName)
VALUES (3564, 'Smith'),
       (5643, 'Brown');

INSERT INTO product
  (productId, productName, manufacturer, color, unitCost)
VALUES
  (1, 'Ceiling Fan', 'Hampton Bay', 'White', 354),
  (2, 'Ceiling Fan', 'Hampton Bay', 'Black', 365),
  (3, 'Sconce', 'Hunter', 'Bronze', 276);

INSERT INTO customer_order (orderId, customerId, orderDate)
VALUES (10354, 3564, '2026-03-02'),
       (10357, 5643, '2026-03-03');

INSERT INTO orderLine
  (orderId, orderLineNumber, productId, quantity)
VALUES
  (10354, 1, 1, 1),
  (10357, 1, 2, 2),
  (10357, 2, 3, 1);

-- ------------------------------------------------------------
-- One-table queries
-- ------------------------------------------------------------

-- Show every customer.
SELECT *
FROM customer;

-- Show product details without displaying every column.
SELECT productName, manufacturer, color, unitCost
FROM product;

-- Show the lines belonging to one order.
SELECT orderLineNumber, productId, quantity
FROM orderLine
WHERE orderId = 10357
ORDER BY orderLineNumber;

-- ------------------------------------------------------------
-- Two-table joins (no aliases)
-- ------------------------------------------------------------

-- Show each order with the name of the customer who placed it.
SELECT customer_order.orderId,
       customer_order.orderDate,
       customer.customerName
FROM customer_order
JOIN customer
  ON customer_order.customerId = customer.customerId
ORDER BY customer_order.orderId;

-- Show each order line with its product information.
SELECT orderLine.orderId,
       orderLine.orderLineNumber,
       product.productName,
       product.manufacturer,
       product.color,
       product.unitCost,
       orderLine.quantity
FROM orderLine
JOIN product
  ON orderLine.productId = product.productId
ORDER BY orderLine.orderId, orderLine.orderLineNumber;

-- Show which line numbers belong to each order date.
SELECT customer_order.orderId,
       customer_order.orderDate,
       orderLine.orderLineNumber,
       orderLine.quantity
FROM customer_order
JOIN orderLine
  ON customer_order.orderId = orderLine.orderId
ORDER BY customer_order.orderId, orderLine.orderLineNumber;

-- Show the calculated cost of each line without storing TotalCost.
SELECT orderLine.orderId,
       orderLine.orderLineNumber,
       product.productName,
       product.unitCost,
       orderLine.quantity,
       product.unitCost * orderLine.quantity
FROM orderLine
JOIN product
  ON orderLine.productId = product.productId
ORDER BY orderLine.orderId, orderLine.orderLineNumber;

-- ------------------------------------------------------------
-- One three-table join (no aliases)
-- ------------------------------------------------------------

-- Show each order, its line numbers, and the products ordered.
SELECT customer_order.orderId,
       customer_order.orderDate,
       orderLine.orderLineNumber,
       product.productName,
       product.unitCost,
       orderLine.quantity,
       product.unitCost * orderLine.quantity
FROM customer_order
JOIN orderLine
  ON customer_order.orderId = orderLine.orderId
JOIN product
  ON orderLine.productId = product.productId
ORDER BY customer_order.orderId, orderLine.orderLineNumber;
