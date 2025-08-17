-- ===============================================================
-- Objective:
-- Retrieve the top 3 highest salaries in each department using SQL
-- using DENSE_RANK() to handle ties (i.e., duplicate salaries).
-- ===============================================================

-- Step 1: Create the Department table
CREATE TABLE IF NOT EXISTS Department (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Step 2: Create the Employee table
CREATE TABLE IF NOT EXISTS Employee (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    salary INT,
    departmentId INT,
    FOREIGN KEY (departmentId) REFERENCES Department(id)
);

-- Step 3: Insert sample data into Department
INSERT INTO Department (id, name) VALUES
(1, 'Engineering'),
(2, 'Human Resources'),
(3, 'Marketing');

-- Step 4: Insert sample data into Employee
INSERT INTO Employee (id, name, salary, departmentId) VALUES
(1, 'Alice', 70000, 1),
(2, 'Bob', 90000, 1),
(3, 'Charlie', 85000, 1),
(4, 'David', 90000, 1),    -- tie with Bob
(5, 'Eva', 50000, 2),
(6, 'Frank', 60000, 2),
(7, 'Grace', 75000, 2),
(8, 'Heidi', 95000, 3),
(9, 'Ivan', 92000, 3),
(10, 'Judy', 91000, 3),
(11, 'Ken', 80000, 3);

-- Step 5: Query to get Top 3 Salaries in each department
SELECT 
    d.name AS department_name,
    e.name AS employee_name,
    e.salary
FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS salary_rank
    FROM Employee
) e
JOIN Department d ON e.departmentId = d.id
WHERE e.salary_rank <= 3
ORDER BY d.name, salary DESC;

-- ===============================================================
-- Explanation:
-- - DENSE_RANK() partitions rows by departmentId
--   and ranks them based on descending salary.
-- - We then filter to get only those rows where rank <= 3
-- - This allows us to include ties (e.g., two employees with the same salary).
-- ===============================================================
