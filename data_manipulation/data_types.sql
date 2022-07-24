-- PostgreSQL stores information about all database objects in a system database called INFORMATION_SCHEMA. 
-- By querying certain tables in this database, you can determine information about the database including 
-- data types of columns.

SELECT column_name, data_type FROM INFORMATION_SCHEMA.COLUMNS
WHERE column_name IN ('title', 'description', 'special_features')
	AND TABLE_NAME = 'film';
	
 -- Select all columns from the TABLES system database
 SELECT * 
 FROM INFORMATION_SCHEMA.TABLES
 -- Filter by schema
 WHERE table_schema = 'public';
 
  -- Select all columns from the COLUMNS system database
 SELECT * 
 FROM INFORMATION_SCHEMA.COLUMNS 
 WHERE table_name = 'actor';
 
 -- Get the column name and data type
SELECT
    column_name,
    data_type
-- From the system database information schema
FROM INFORMATION_SCHEMA.COLUMNS 
-- For the customer table
WHERE table_name = 'customer';

-- DATE AND TIME DATATYPES

-- TIMESTAMPs contain both a date value and a time value with microsecond precision. These data types are very common 
-- because they can be used to record an exact point in time 

-- TIMESTAMPs in PostgreSQL use the ISO 8601 format which is a four digit year followed by a two digit month 
-- and day separated by dashes. 

SELECT payment_date FROM payment;

-- DATE and TIME types are essentially the date and time values of the TIMESTAMP. 

-- INTERVAL types store date and time data as a period of time in years, months, days, hours, seconds, etc.
-- INTERVALs are useful when you want to do arithmetic on date and time columns. 

SELECT
 	-- Select the rental and return dates
	rental_date,
	return_date,
 	-- Calculate the expected_return_date
	rental_date + INTERVAL '3 days' AS expected_return_date
FROM rental;

--  To create an ARRAY type, you simply need to add "square brackets" to the end of the data type that you want to make an array.
CREATE TABLE IF NOT EXISTS grades (
	student_id int,
	email text[][],
	test_scores int[]
);

-- INSERT INTO grades 
-- 	VALUES (1, '{{"work", "work1@datacamp.com"}, {"other", "other1@datacamp.com"}}',
-- 		   '{92,85,96,88}');

-- Notice how arrays are represented in the SQL with curly brackets and single quotations for email and comma separated list of 
-- whole numbers for test_scores.

SELECT email[1][1] AS type, email[1][2] AS address, test_scores[1] FROM grades;

-- Note that PostgreSQL array indexes start with one and not zero.

-- Searching ARRAYs
-- The same notation used to access ARRAYs in the SELECT statement, can also be used in the WHERE clause as a filter

SELECT email[1][1] AS type, 
	email[1][2] AS address, 
	test_scores[1] 
FROM grades
WHERE email[1][1] = 'work';

-- The ANY function allows you to search an array for a value and return a record if it finds a match.

SELECT email[1][1] AS type, 
	email[1][2] AS address, 
	test_scores[1] 
FROM grades
WHERE 'other' = ANY (email);

-- An alternative to the ANY function is the contains operator. 


SELECT email[1][1] AS type, 
	email[1][2] AS address, 
	test_scores[1] 
FROM grades
WHERE email @> Array['other'];


-- Select all films that have a special feature Trailers
SELECT 
-- Select the title and special features column 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[1] = 'Trailers';

SELECT 
  title, 
  special_features 
FROM film
WHERE special_features[2] = 'Deleted Scenes';

-- Match 'Trailers' in any index of the special_features ARRAY regardless of position.
SELECT
  title, 
  special_features 
FROM film 
-- Modify the query to use the ANY function 
WHERE 'Trailers' = Any (special_features);

SELECT 
  title, 
  special_features 
FROM film 
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];