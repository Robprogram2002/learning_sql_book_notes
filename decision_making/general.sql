-- we will work with a Postgres database from a fictional movie rental company called MovieNow. 
-- MovieNow offers an online platform for streaming movies. Customers can rent a movie for 24 hours. 
-- For all movies, the company stores additional information
-- MovieNow also stores information about customers and movie ratings.

-- Objectives of data driven decision making

-- We can extract valuable information from data to support operational short-term decisions. For example,
-- 	* the popularity of certain actors helps MovieNow decide whether to purchase certain movies
--  * last month's revenue can be important information supporting decisions regarding short-term investments.

-- For long-term decisions, data-driven support can provide information regarding customer growth and successes 
-- in certain regions in the past, which can inform company decisions regarding when and where the market can be 
-- expanded in the future. 
-- Also, knowing the long-term development of overall revenue helps MovieNow plan long-term investments.

-- Key performance indicators help a company (or its subdivisions) define and monitor success
-- Revenue is a trivial indicator of success. For MovieNow, this is calculated as the sum of the price for rented movies. 
-- For the subdivision customer relations management, the KPI 'customer satisfaction' could be quantified by the average 
-- rating of all movies or the KPI 'customer engagement' as the number of active customers in a certain time period. 

-- CODE ECXAMPLES

-- Select all records of movie rentals between beginning of April 2018 till end of August 2018.
SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-04-01' AND '2018-08-31'
ORDER BY date_renting; -- Order by recency in decreasing order

-- Select all movies which are not dramas.
SELECT *
FROM movies
WHERE genre <> 'Drama';

-- Select all movies with the given titles
SELECT *
FROM movies
WHERE title IN ('Showtime', 'Love Actually', 'The Fighter'); 

-- Order the movies by increasing renting price7
SELECT *
FROM movies
ORDER BY renting_price DESC;

-- select all movie rentals from 2018 where a rating exists
SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31' -- Renting in 2018
AND rating IS NOT NULL; 

-- Count the number of france customers born in the 80s 
SELECT COUNT(*)
FROM customers
WHERE (date_of_birth BETWEEN '1980-01-01' AND '1989-12-31') AND country = 'France';

-- Count the number of countries where MovieNow has customers.
SELECT COUNT(DISTINCT country)    
FROM customers;
