--  ADVANCED SQL QUERIES >>
-- Task 13: Identify Members with Overdue Books
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

select 
ist.issued_member_id,
bk.book_title,
ist.issued_date,
rst.return_date,
m.member_name,
CURRENT_DATE - ist.issued_date as overdue_days
from issued_status as ist
LEFT JOIN return_status as rst
on ist.issued_id = rst.issued_id 
JOIN members AS m
  ON m.member_id = ist.issued_member_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
where rst.return_id IS NULL
AND CURRENT_DATE - ist.issued_date >30
ORDER BY ist.issued_member_id

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

select * from books
select * from return_status

CREATE OR REPLACE PROCEDURE add_status (p_return_id VARCHAR(10),p_issued_id VARCHAR(30))
LANGUAGE plpgsql 
AS $$
DECLARE 
v_isbn VARCHAR(50);
v_book_name VARCHAR(80);
BEGIN 
	INSERT INTO return_status(return_id,issued_id,return_date)
	values 
(
	p_return_id, p_issued_id,CURRENT_DATE
);
SELECT 
issued_book_isbn,
issued_book_name
into
v_isbn,
v_book_name
FROM issued_status 
WHERE issued_ID = p_issued_id ;

UPDATE books 
SET status = 'yes'
WHERE isbn = v_isbn;

RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$

-- TESTING FUNCTIONS >>>

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';


SELECT * FROM return_status
WHERE issued_id = 'IS135';

CALL add_status('RS138', 'IS135');

-- DROP PROCEDURE IF EXISTS add_status;


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE branch_reports as
SELECT 
b.branch_id,
b.manager_id,
count (ist.issued_id) as issued_books,
count (rst.return_id) as returned_books,
sum(bk.rental_price) as total_rental_price
from issued_status as ist 
JOIN 
employee as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN 
return_status as rst 
ON ist.issued_id = rst.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id,b.manager_id 

SELECT * FROM branch_reports;


-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 year 

select * from members 
select * from issued_status 

CREATE TABLE active_members 
as 
SELECT * from members 
where member_id in 
(select DISTINCT issued_member_id from issued_status as ist 
where issued_date >= CURRENT_DATE - INTERVAL '2 year'
)
-- ORR USING JOINS >>>>>>>
SELECT DISTINCT m.*
FROM members AS m
JOIN issued_status AS ist
  ON m.member_id = ist.issued_member_id
WHERE ist.issued_date >= CURRENT_DATE - INTERVAL '2 year';


-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employee as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2


-- Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$


-- TASK-20 >>Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

CREATE TABLE overdue_fines_summary AS
SELECT 
  ist.issued_member_id AS member_id,
  COUNT(*) AS overdue_books,
  SUM((CURRENT_DATE - ist.issued_date - 30) * 0.5) AS total_fine,
  (
    SELECT COUNT(*) 
    FROM issued_status 
    WHERE issued_member_id = ist.issued_member_id
  ) AS total_books_issued
FROM issued_status ist
LEFT JOIN return_status rst ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL
  AND CURRENT_DATE - ist.issued_date > 30
GROUP BY ist.issued_member_id;

select * from overdue_fines_summary 