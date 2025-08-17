-- ==========================================
-- Polarized Books Analysis 📚
-- ==========================================
-- This script:
--   1. Creates schema for books and reading sessions
--   2. Inserts sample data
--   3. Runs an analysis query to identify "polarized" books
--
-- A book is considered polarized if:
--   - It has at least 5 reading sessions
--   - it has at least one rating ≥ 4 and at least one rating ≤ 2
--   - It shows a spread between highest and lowest ratings
--   - At least 60% of its ratings are extreme (<=2 or >=4)
-- ==========================================


-- -----------------------------
-- Drop existing tables (safety)
-- -----------------------------
DROP TABLE IF EXISTS reading_sessions;
DROP TABLE IF EXISTS books;


-- -----------------------------
-- Table: books
-- Stores book metadata
-- -----------------------------
CREATE TABLE books (
    book_id INT PRIMARY KEY,        -- Unique identifier for each book
    title VARCHAR(255) NOT NULL,    -- Book title
    author VARCHAR(255) NOT NULL,   -- Author name
    genre VARCHAR(100),             -- Genre classification
    pages INT                       -- Number of pages
);


-- -----------------------------
-- Table: reading_sessions
-- Stores each reading session and its rating
-- -----------------------------
CREATE TABLE reading_sessions (
    session_id INT PRIMARY KEY,     -- Unique session identifier
    book_id INT,                    -- Foreign key reference to books
    reader_name VARCHAR(255),       -- Name of reader
    pages_read INT,                 -- Number of pages read in this session
    session_rating INT,             -- Rating given by reader (1-5 scale)
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);


-- -----------------------------
-- Insert sample data into books
-- -----------------------------
INSERT INTO books (book_id, title, author, genre, pages) VALUES
(1, 'The Great Gatsby', 'F. Scott', 'Fiction', 180),
(2, 'To Kill a Mockingbird', 'Harper Lee', 'Fiction', 281),
(3, '1984', 'George Orwell', 'Dystopian', 328),
(4, 'Pride and Prejudice', 'Jane Austen', 'Romance', 432),
(5, 'The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 277);


-- -----------------------------
-- Insert sample data into reading_sessions
-- Each row = one reading session
-- -----------------------------
INSERT INTO reading_sessions (session_id, book_id, reader_name, pages_read, session_rating) VALUES
(1, 1, 'Alice', 50, 5),
(2, 1, 'Bob', 60, 1),
(3, 1, 'Carol', 40, 4),
(4, 1, 'David', 30, 2),
(5, 1, 'Emma', 45, 5),
(6, 2, 'Frank', 80, 4),
(7, 2, 'Grace', 70, 4),
(8, 2, 'Henry', 90, 5),
(9, 2, 'Ivy', 60, 4),
(10, 2, 'Jack', 75, 4),
(11, 3, 'Kate', 100, 2),
(12, 3, 'Liam', 120, 1),
(13, 3, 'Mia', 80, 2),
(14, 3, 'Noah', 90, 1),
(15, 3, 'Olivia', 110, 4),
(16, 3, 'Paul', 95, 5),
(17, 4, 'Quinn', 150, 3),
(18, 4, 'Ruby', 140, 3),
(19, 5, 'Sam', 80, 1),
(20, 5, 'Tara', 70, 2);


-- ==========================================
-- Polarized Books Analysis Query
-- ==========================================
-- Step 1: Aggregate sessions by book in a CTE
-- Step 2: Count sessions, find min/max ratings
-- Step 3: Count "extreme ratings" (<=2 or >=4)
-- Step 4: Apply HAVING clause to filter candidates
-- Step 5: Join with books table to add metadata
-- Step 6: Calculate rating spread and polarization score
-- Step 7: Return only books with >= 60% extreme ratings
-- ==========================================

WITH session_stats AS (
    SELECT 
        book_id,
        COUNT(*) AS total_sessions,                -- how many sessions per book
        MAX(session_rating) AS highest_rating,     -- highest rating received
        MIN(session_rating) AS lowest_rating,      -- lowest rating received
        SUM(
            CASE 
                WHEN session_rating <= 2 OR session_rating >= 4 
                THEN 1 ELSE 0 
            END
        ) AS extreme_ratings                       -- count of extreme ratings
    FROM reading_sessions
    GROUP BY book_id
    HAVING 
        COUNT(*) >= 5              -- must have at least 5 sessions
        AND MAX(session_rating) >= 4 -- at least one high rating
        AND MIN(session_rating) <= 2 -- at least one low rating
)

SELECT 
    b.book_id,
    b.title,
    b.author,
    b.genre,
    b.pages,
    (s.highest_rating - s.lowest_rating) AS rating_spread,     -- difference between max & min ratings
    ROUND(
        CAST(s.extreme_ratings AS DECIMAL) / s.total_sessions, 
        2
    ) AS polarization_score                                    -- ratio of extreme ratings
FROM books b
JOIN session_stats s
    ON b.book_id = s.book_id
WHERE 
    CAST(s.extreme_ratings AS DECIMAL) / s.total_sessions >= 0.6 -- must have >= 60% extreme ratings
ORDER BY 
    polarization_score DESC,   -- most polarized first
    b.title DESC;              -- tie-breaker: sort by title (descending)
