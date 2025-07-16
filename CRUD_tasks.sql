select * from books
select * from branch 
select * from employee 
select * from issued_status
select * from members 
select * from return_status

-- TASK-1 
-- CREATE A NEW BOOK RECORD >>

INSERT INTO books (isbn,book_title,category,rental_price,status,author,publisher)
values 
('101000000000','The Count of Monte Cristo','fantasy',100,'yes','Alexandre Dumas','Oxford')
select * from books

-- Task 2: Update an Existing Member's Address
UPDATE members 
SET member_address= '125 Main St'
WHERE member_id='C101'

select * from members

-- Task 3: Delete a Record from the Issued Status Table
DELETE FROM issued_status 
WHERE   issued_id =   'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
select * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 

select * from issued_status

select issued_emp_id, count(issued_book_name) as total_issued
from issued_status
group by issued_emp_id
HAVING COUNT(issued_book_name) > 1; 


