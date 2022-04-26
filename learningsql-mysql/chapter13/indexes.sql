-- An index is simply a mechanism for finding a specific item within a resource.

-- a database server uses indexes to locate rows in a table. Indexes are special 
-- tables that are kept in a specific order. An index contains only 
-- the column (or columns) used to locate rows in the data table, along with information 
-- describing where the rows are physically located. Therefore, the role of indexes is to 
-- facilitate the retrieval of a subset of a table’s rows and columns without the need to 
-- inspect every row in the table.

ALTER TABLE customer 
ADD INDEX idx_email (email);

-- With the index in place, the query optimizer can choose to use the index if it is deemed 
-- beneficial to do so. If there is more than one index on a table, the optimizer must decide 
-- which index will be the most beneficial for a particular SQL statement.

SHOW INDEX FROM customer;

-- If, after creating an index, you decide that the index is not proving useful, you can remove it 
-- via the following:

ALTER TABLE customer DROP INDEX idx_email;

-- Unique indexes

-- along with providing all the benefits of a regular index, it also serves as a mechanism for 
-- disallowing duplicate values in the indexed column. 
-- Whenever a row is inserted or when the indexed column is modified, the database server checks 
-- the unique index to see whether the value already exists in another row in the table

ALTER TABLE customer 
ADD UNIQUE idx_email (email);

-- Multicolumn indexes

-- you may also build indexes that span multiple columns.

ALTER TABLE customer ADD INDEX idx_full_name (last_name, first_name);

-- This index will be useful for queries that specify the first and last names or just the last name, 
-- but it would not be useful for queries that specify only the customer’s first name

-- you should think carefully about which column to list first, which column to list second, and so on, 
-- to help make the index as useful as possible

-- To see how MySQL’s query optimizer decides to execute the query, I use the explain statement to ask 
-- the server to show the execution plan for the query rather than executing the query:

EXPLAIN
SELECT customer_id, first_name, last_name 
FROM customer
WHERE first_name LIKE 'S%' AND last_name LIKE 'P%';


-- every time a row is added to or removed from a table, all indexes on that table must be modified. 
-- When a row is updated, any indexes on the column or columns that were affected need to be modified 
-- as well.

-- Therefore, the more indexes you have, the more work the server needs to do to keep all schema 
-- objects up-to-date, which tends to slow things down.

-- Indexes also require disk space as well as some amount of care from your administrators, so the 
-- best strategy is to add an index when a clear need arises. If you need an index for only special purposes, 
-- you can always add the index, run the routine, and then drop the index until you need it again.

