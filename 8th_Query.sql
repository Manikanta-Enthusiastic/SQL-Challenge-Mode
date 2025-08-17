-- ==========================================================
-- SQL Script: SalesPerson, Company, and Orders Schema Setup
-- Task: Find all salespersons who did NOT make any orders 
--       for the company named 'RED'.
-- ==========================================================

-- ========================
-- Table Definitions
-- ========================
CREATE TABLE IF NOT EXISTS SalesPerson (
    sales_id INT,
    name VARCHAR(255),
    salary INT,
    commission_rate INT,
    hire_date DATE
);

CREATE TABLE IF NOT EXISTS Company (
    com_id INT,
    name VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT,
    order_date DATE,
    com_id INT,
    sales_id INT,
    amount INT
);

-- ========================
-- Sample Data
-- ========================
TRUNCATE TABLE SalesPerson;
INSERT INTO SalesPerson (sales_id, name, salary, commission_rate, hire_date) VALUES
(1, 'John', 100000, 6, '2006-04-01'),
(2, 'Amy', 12000, 5, '2010-05-01'),
(3, 'Mark', 65000, 12, '2008-12-25'),
(4, 'Pam', 25000, 25, '2005-01-01'),
(5, 'Alex', 5000, 10, '2007-02-03');

TRUNCATE TABLE Company;
INSERT INTO Company (com_id, name, city) VALUES
(1, 'RED', 'Boston'),
(2, 'ORANGE', 'New York'),
(3, 'YELLOW', 'Boston'),
(4, 'GREEN', 'Austin');

TRUNCATE TABLE Orders;
INSERT INTO Orders (order_id, order_date, com_id, sales_id, amount) VALUES
(1, '2014-01-01', 3, 4, 10000),
(2, '2014-02-01', 4, 5, 5000),
(3, '2014-03-01', 1, 1, 50000),
(4, '2014-04-01', 1, 4, 25000);

-- ========================
-- Solution Query
-- ========================

-- Step 1: Identify salespeople who have worked with RED
WITH RedSales AS (
    SELECT DISTINCT o.sales_id
    FROM Orders o
    JOIN Company c
        ON o.com_id = c.com_id
    WHERE c.name = 'RED'  -- filter only RED company
)

-- Step 2: Select all salespeople and exclude those in RedSales
SELECT sp.name
FROM SalesPerson sp
LEFT JOIN RedSales rs
    ON sp.sales_id = rs.sales_id
WHERE rs.sales_id IS NULL   -- keep only those NOT in RedSales
;

-- ===============================================================
-- Explanation of Logic
-- ===============================================================
-- 1. The CTE `RedSales` finds all sales_id values for salespeople
--    who have placed at least one order for the company named "RED".
--
-- 2. We LEFT JOIN the entire SalesPerson table with this CTE.
--    - If a salesperson has worked with RED, their ID appears in RedSales.
--    - If they have not, the join produces NULL.
--
-- 3. The final filter `WHERE rs.sales_id IS NULL` ensures we only
--    keep salespeople who were never associated with RED.
--
-- ===============================================================
-- Final Output:
-- This will list all salespeople names who never worked with RED.
-- With the provided data, the result will be:
--   Amy
--   Mark
--   Alex
-- ===============================================================
