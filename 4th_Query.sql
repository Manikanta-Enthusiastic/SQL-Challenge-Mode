-- Query to calculate the sum of total investment value in 2016 (tiv_2016)
-- for policyholders meeting the following criteria:
-- 1. They share the same tiv_2015 value with one or more other policyholders.
-- 2. Their location (lat, lon) is unique among all policyholders.
-- The result is rounded to two decimal places.


-- Create the Insurance table if it does not already exist
-- This ensures the script can be run without errors in case the table is already created
CREATE TABLE IF NOT EXISTS Insurance (
    pid INT,          -- Unique policy ID for each policyholder
    tiv_2015 FLOAT,   -- Total investment value in 2015
    tiv_2016 FLOAT,   -- Total investment value in 2016
    lat FLOAT,        -- Latitude of the policyholder's city (location)
    lon FLOAT         -- Longitude of the policyholder's city (location)
);

-- Insert records into the Insurance table
-- Each record represents a unique policy with investment and location details

-- Insert the first policy with pid = 1
-- tiv_2015 = 10, tiv_2016 = 5, location = (10, 10)
INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon) 
VALUES (1, 10, 5, 10, 10);

-- Insert the second policy with pid = 2
-- tiv_2015 = 20, tiv_2016 = 20, location = (20, 20)
INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon) 
VALUES (2, 20, 20, 20, 20);

-- Insert the third policy with pid = 3
-- tiv_2015 = 10, tiv_2016 = 30, location = (20, 20)
INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon) 
VALUES (3, 10, 30, 20, 20);

-- Insert the fourth policy with pid = 4
-- tiv_2015 = 10, tiv_2016 = 40, location = (40, 45)
INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon) 
VALUES (4, 10, 40, 40, 45);

-- Insert the fifth policy with pid = 5
-- tiv_2015 = 20, tiv_2016 = 40, location = (50, 35)
INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon) 
VALUES (5, 20, 40, 50, 35);


--*SQL Query*:

SELECT 
    ROUND(SUM(tiv_2016), 2) AS tiv_2016 -- Calculate and round the sum of tiv_2016
FROM 
    Insurance
WHERE 
    -- Condition 1: tiv_2015 is shared with one or more other policyholders
    tiv_2015 IN (
        SELECT tiv_2015
        FROM Insurance
        GROUP BY tiv_2015
        HAVING COUNT(*) > 1 -- Keep only tiv_2015 values that appear more than once
    )
    AND 
    -- Condition 2: The location (lat, lon) is unique
    (lat, lon) IN (
        SELECT lat, lon
        FROM Insurance
        GROUP BY lat, lon
        HAVING COUNT(*) = 1 -- Keep only unique location pairs
    );

-- End Query
