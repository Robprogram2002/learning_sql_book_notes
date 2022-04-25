-- Union operator 

SELECT 'CUST' typ, c.first_name, c.last_name 
FROM customer c 
UNION ALL
SELECT 'ACTR' typ, a.first_name, a.last_name 
FROM actor a;

SELECT c.first_name, c.last_name 
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' 
UNION ALL
SELECT a.first_name, a.last_name 
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

-- the last query has repeated rows. We can use only UNION to remove them

SELECT c.first_name, c.last_name 
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' 
UNION 
SELECT a.first_name, a.last_name 
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';



-- If you want the results of your compound query to be sorted, you can add an order by 
-- clause after the last query (you will need to choose from the column names in the first 
-- query of the compound query.)
-- Frequently, the column names are the same for both queries in a compound query, but 
-- this does not need to be the case

SELECT a.first_name fname, a.last_name lname 
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%' 
UNION ALL
SELECT c.first_name, c.last_name 
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' 
ORDER BY lname, fname;




