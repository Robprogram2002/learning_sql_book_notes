-- Example: Union Operation

SELECT 'CUST' typ, c.first_name, c.last_name
FROM customer AS c 
UNION ALL
SELECT 'ACTR' typ, a.first_name, a.last_name 
FROM actor AS a;

-- Just to drive home the point that the union all operator doesn’t remove duplicates, here’s another version 
-- of the previous example, but with two identical queries against the actor table:

SELECT 'ACTR' typ, a.first_name, a.last_name 
FROM actor a 
UNION ALL
SELECT 'ACTR' typ, a.first_name, a.last_name 
FROM actor a;

-- As you can see by the results, the 200 rows from the actor table are included twice, for a total of 400 rows.

-- On the other hand, we can use only union to exclude duplicated rows

SELECT c.first_name, c.last_name 
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' 
UNION
SELECT a.first_name, a.last_name -> FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

-- Example: Intersection Operation
-- these sets are completely nonoverlapping, so the intersection of the two sets yields the empty set.
SELECT c.first_name, c.last_name FROM customer c
WHERE c.first_name LIKE 'D%' AND c.last_name LIKE 'T%' 
INTERSECT
SELECT a.first_name, a.last_name FROM actor a
WHERE a.first_name LIKE 'D%' AND a.last_name LIKE 'T%'; 

-- If we switch to the initials JD, however, the intersection will yield a single row:
SELECT c.first_name, c.last_name FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' 
INTERSECT
SELECT a.first_name, a.last_name FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

-- Example : Except Operation

SELECT a.first_name, a.last_name FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%' 
EXCEPT
SELECT c.first_name, c.last_name FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%';

-- In this version of the query, the result set consists of the three rows from the first query minus Jennifer Davis, 
-- who is found in the result sets from both queries. There is also an except all operator specified in the ANSI SQL 
-- specification,


-- Example: Sorting A Compound Query Result
SELECT a.first_name fname, a.last_name lname 
FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%' 
UNION ALL
SELECT c.first_name, c.last_name 
FROM customer c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' 
ORDER BY lname, fname;


-- The column names specified in the two queries are different in this example. If you specify a column name from 
-- the second query in your order by clause, you will see the following error: unknown column
-- I recommend giving the columns in both queries identical column aliases in order to avoid this issue.


-- MySQL does not yet allow parentheses in compound queries, but if you are using a different database server, 
-- you can wrap adjoining queries in parentheses to override the default top-to-bottom processing of compound 
-- queries, as in:

SELECT a.first_name, a.last_name FROM actor a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%' 
UNION 
    (
        SELECT a.first_name, a.last_name FROM actor a
        WHERE a.first_name LIKE 'M%' AND a.last_name LIKE 'T%' UNION ALL
        SELECT c.first_name, c.last_name FROM customer c
        WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%' 
    )

-- For this compound query, the second and third queries would be combined using the union all operator, then the 
-- results would be combined with the first query using the union operator.
