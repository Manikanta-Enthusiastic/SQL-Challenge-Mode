-- ==========================================
-- Library Books Borrowing Analysis 📚
-- ==========================================
-- This script:
--   1. Creates schema for library books and borrowing records
--   2. Inserts sample data
--   3. Runs an analysis query to find books that are:
--        - Currently borrowed (active borrow with NULL return_date)
--        - AND have zero available copies left
--
-- Final output:
--   book_id, title, author, genre, publication_year, 
--   and current number of borrowers.
-- ==========================================


-- -----------------------------
-- Drop existing tables (safety)
-- -----------------------------
DROP TABLE IF EXISTS borrowing_records;
DROP TABLE IF EXISTS library_books;


-- -----------------------------
-- Table: library_books
-- Stores information about each book in the library
-- -----------------------------
CREATE TABLE library_books (
    book_id INT PRIMARY KEY,            -- Unique identifier for each book
    title VARCHAR(255) NOT NULL,        -- Title of the book
    author VARCHAR(255) NOT NULL,       -- Author name
    genre VARCHAR(100),                 -- Genre classification
    publication_year INT,               -- Year of publication
    total_copies INT NOT NULL           -- Total number of copies available
);


-- -----------------------------
-- Table: borrowing_records
-- Tracks who borrowed a book, and when it was returned
-- -----------------------------
CREATE TABLE borrowing_records (
    record_id INT PRIMARY KEY,          -- Unique borrowing record
    book_id INT,                        -- Reference to library_books
    borrower_name VARCHAR(255),         -- Name of the borrower
    borrow_date DATE,                   -- Date book was borrowed
    return_date DATE,                   -- NULL if not yet returned
    FOREIGN KEY (book_id) REFERENCES library_books(book_id)
);


-- -----------------------------
-- Insert sample data into library_books
-- -----------------------------
TRUNCATE TABLE library_books;

INSERT INTO library_books (book_id, title, author, genre, publication_year, total_copies) VALUES
(1, 'The Great Gatsby', 'F. Scott', 'Fiction', 1925, 3),
(2, 'To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 3),
(3, '1984', 'George Orwell', 'Dystopian', 1949, 1),
(4, 'Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 2),
(5, 'The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 1951, 1),
(6, 'Brave New World', 'Aldous Huxley', 'Dystopian', 1932, 4);


-- -----------------------------
-- Insert sample data into borrowing_records
-- -----------------------------
TRUNCATE TABLE borrowing_records;

INSERT INTO borrowing_records (record_id, book_id, borrower_name, borrow_date, return_date) VALUES
(1, 1, 'Alice Smith', '2024-01-15', NULL),
(2, 1, 'Bob Johnson', '2024-01-20', NULL),
(3, 2, 'Carol White', '2024-01-10', '2024-01-25'),
(4, 3, 'David Brown', '2024-02-01', NULL),
(5, 4, 'Emma Wilson', '2024-01-05', NULL),
(6, 5, 'Frank Davis', '2024-01-18', '2024-02-10'),
(7, 1, 'Grace Miller', '2024-02-05', NULL),
(8, 6, 'Henry Taylor', '2024-01-12', NULL),
(9, 2, 'Ivan Clark', '2024-02-12', NULL),
(10, 2, 'Jane Adams', '2024-02-15', NULL);


-- ==========================================
-- Analysis Query: Books with all copies borrowed
-- ==========================================
-- Step 1: Build a CTE that counts how many copies 
--         are currently borrowed (return_date IS NULL).
-- Step 2: Join with library_books to calculate availability.
-- Step 3: Only return books where (total_copies - borrowed) = 0.
-- Step 4: Order by current borrowers (descending) then title (ascending).
-- ==========================================

WITH available_copies AS (
    SELECT 
        book_id, 
        COUNT(book_id) AS borrowed_copies
    FROM borrowing_records
    WHERE return_date IS NULL
    GROUP BY book_id
)
SELECT 
    lb.book_id,
    lb.title,
    lb.author,
    lb.genre,
    lb.publication_year,
    ac.borrowed_copies AS current_borrowers
FROM library_books lb
INNER JOIN available_copies ac
    ON lb.book_id = ac.book_id
WHERE (lb.total_copies - ac.borrowed_copies) = 0
ORDER BY current_borrowers DESC, lb.title ASC;
