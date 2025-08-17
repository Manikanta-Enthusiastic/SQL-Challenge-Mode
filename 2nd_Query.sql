# 7-Day Moving Average of Customer Payments

This project calculates the 7-day moving average of the total amount paid by customers at a restaurant. It uses SQL to handle a dataset with customer transactions, focusing on computing the moving average over a rolling 7-day window.

## Problem Statement

The dataset contains the following columns:
- `customer_id`: Unique ID of the customer.
- `name`: Name of the customer.
- `visited_on`: Date when the customer visited the restaurant.
- `amount`: Total amount paid by the customer on that date.

### Goal
Compute the **7-day moving average** of payments, starting from the 7th record (inclusive), with:
- A 7-day window (current day + 6 days prior).
- Average rounded to 2 decimal places.
- Result sorted by the `visited_on` date.


-- Step 1: Drop the existing 'Customer' table if it already exists
DROP TABLE IF EXISTS Customer;

-- Step 2: Create a new 'Customer' table with the following columns:
--   customer_id: Unique identifier for each customer (INTEGER)
--   name: Name of the customer (VARCHAR)
--   visited_on: Date of the customer's visit (DATE)
--   amount: Total amount paid by the customer during the visit (INTEGER)
CREATE TABLE Customer (
    customer_id INT,
    name VARCHAR(100),
    visited_on DATE,
    amount INT
);

-- Step 3: Insert sample data into the 'Customer' table
-- Each row represents a specific visit by a customer with their payment details
INSERT INTO Customer (customer_id, name, visited_on, amount) VALUES
(1, 'Jhon', '2019-01-01', 100),
(2, 'Daniel', '2019-01-02', 110),
(3, 'Jade', '2019-01-03', 120),
(4, 'Khaled', '2019-01-04', 130),
(5, 'Winston', '2019-01-05', 110),
(6, 'Elvis', '2019-01-06', 140),
(7, 'Anna', '2019-01-07', 150),
(8, 'Maria', '2019-01-08', 80),
(9, 'Jaze', '2019-01-09', 110),
(1, 'Jhon', '2019-01-10', 130),
(3, 'Jade', '2019-01-10', 150);

-- SQL Query to Calculate the 7-Day Moving Average of Daily Totals

-- Step 4: Use a Common Table Expression (CTE) to calculate daily totals
WITH DailyTotals AS (
    -- Aggregate the total amount paid on each date
    SELECT
        visited_on,               -- Date of the visit
        SUM(amount) AS daily_amount -- Total amount paid by all customers on this date
    FROM 
        Customer                  -- Source table with visit data
    GROUP BY 
        visited_on                -- Group by the visit date to calculate daily totals
),

-- Step 5: Assign a sequential row number to each date for processing
RankedData AS (
    SELECT
        visited_on,               -- Date of the visit
        daily_amount,             -- Total amount paid on the current date
        ROW_NUMBER() OVER (       -- Assign row numbers to each date in ascending order
            ORDER BY visited_on
        ) AS row_num              -- Unique row number for each date
    FROM 
        DailyTotals               -- Use the aggregated daily totals
),

-- Step 6: Compute the 7-day moving total and moving average
MovingAverage AS (
    SELECT
        visited_on,               -- Current date being analyzed
        row_num,                  -- Sequential row number
        -- Calculate the 7-day moving total of daily amounts
        SUM(daily_amount) OVER (
            ORDER BY row_num      -- Maintain chronological order by row number
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW -- Include the current day and the 6 preceding days
        ) AS total_amount,
        -- Calculate the 7-day moving average of daily amounts
        ROUND(AVG(daily_amount) OVER (
            ORDER BY row_num      -- Maintain chronological order by row number
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW -- Include the current day and the 6 preceding days
        ), 2) AS average_amount
    FROM 
        RankedData                -- Use the ranked data for calculations
)

-- Step 7: Retrieve the final results for dates with at least 7 days of data
SELECT 
    visited_on,                   -- Date of the visit
    total_amount AS amount,       -- 7-day moving total of daily amounts
    average_amount                -- 7-day moving average of daily amounts
FROM 
    MovingAverage                 -- Use the computed moving averages
WHERE 
    row_num >= 7                  -- Ensure at least 7 days of data are available
ORDER BY 
    visited_on;                   -- Sort results by date in ascending order

-- End of query
