-- Data Analysis & Findings

-- Task 7. Retrieve All Books in a Specific Category:

select * from books 
where category= 'Classic'

-- Task 8: Find Total Rental Income by Category:

-- but note this is just book records..what if the book is issued 2-3 times or more like the sum will increase later
-- regardless of whether the book was issued or not 
select category , sum(rental_price)
from books 
group by category 
order by sum(rental_price)desc

--  thus we need to do the join here >>
select 
category,
sum(rental_price),
count(*)
from books as b
JOIN 
issued_status as ist
on ist.issued_book_isbn=b.isbn 
group by 1
order by sum(rental_price) desc

-- 9- List Members Who Registered in the Last 180 Days:

insert into members (member_id,member_name,member_address,reg_date) 
values 
('C120','Jessy Jay','348 China Town','2025-07-14'),
('C008','Ash Tea','231 Okhla Town','2025-06-04'),
('C007','Tom Good','001 Main St','2025-05-25')

select * from members
where reg_date >= CURRENT_DATE - INTERVAL '180 days'


-- 10. List Employees with Their Branch Manager's Name and their branch details

select * from branch
select * from employee

alter table employee 
add constraint fk_id
FOREIGN KEY (branch_id) REFERENCES branch(branch_id)

select 
e.*,
e2.emp_name as manager,
b.branch_id 
from employee as e 
JOIN 
branch as b 
on e.branch_id =b.branch_id
JOIN 
employee e2
on b.manager_id = e2.emp_id

-- 11. Create a Table of Books with Rental Price Above a Certain Threshold:
Create table expensive_books as
select * from books 
where rental_price > 6

select * from expensive_books

--12: Retrieve the List of Books Not Yet Returned
select * from issued_status
select * from return_status 

select * from issued_status as ist 
LEFT JOIN return_status as rst 
on ist.issued_id = rst.issued_id
where rst.return_id IS NULL;