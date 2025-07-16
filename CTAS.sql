-- CTAS >>>

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_count
AS
(
select 
b.isbn,
b.book_title,
count(*)
from books as b
JOIN 
issued_status as ist
on ist.issued_book_isbn=b.isbn 
group by b.isbn,b.book_title
)
select * from book_count

