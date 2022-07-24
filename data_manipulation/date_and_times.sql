-- arithmetic operations with dates 

SELECT date '2018-02-11 00:00:00' - date '2018-02-9 12:00:00' ;

-- The AGE function takes two timestamp arguments and subtracts the first argument from the 
-- second and returns an INTERVAL as a result. 

SELECT AGE(timestamp '2018-02-11 00:00:00' , timestamp '2018-02-9 12:00:00');

SELECT AGE(rental_date), rental_date FROM rental;

SELECT rental_date, 
	return_date, 
	rental_date + INTERVAL '3 days' AS expected_return
FROM rental;

-- You can also perform multiplication and division on date and time data types using intervals 
-- which is another useful tool when you have relative date and time data. 

SELECT timestamp '2019-05-02' + 21 * INTERVAL '1 day';

SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
    r.return_date - r.rental_date AS days_rented,
	AGE(r.return_date, r.rental_date) AS days_rented2
FROM film AS f
     INNER JOIN inventory AS i ON f.film_id = i.film_id
     INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

SELECT
	f.title,
 	-- Convert the rental_duration to an interval
    INTERVAL '1' day * f.rental_duration,
 	-- Calculate the days rented as we did previously
    r.return_date - r.rental_date AS days_rented
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
-- Filter the query to exclude outstanding rentals
WHERE r.return_date IS NOT NULL
ORDER BY f.title;

-- Calculating the expected return date
SELECT
    f.title,
	r.rental_date,
    f.rental_duration,
    -- Add the rental duration to the rental date
    INTERVAL '1' day * f.rental_duration + r.rental_date AS expected_return_date,
    r.return_date
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

-- Retrieving the current timestamp
--  NOW() allows you to retrieve a timestamp value for the current date and time at the microsecond precision with time zone.

-- timestamp with time zone
SELECT NOW();

-- timestamp without time zone (by explicitly casting it )
SELECT NOW()::timestamp;

-- Casting allows you to convert one data type to another
-- This syntax which uses the double colon operator is specific to PostgreSQL and non-conforming to the SQL standard. 
-- You can also use the CAST() function to achieve the same result

SELECT CAST(NOW() AS timestamp);

-- The CURRENT_TIMESTAMP function returns the same result of the NOW() function
-- One difference between CURRENT_TIMESTAMP and NOW() is that with CURRENT_TIMESTAMP you can specify a precision parameter
SELECT CURRENT_TIMESTAMP;
SELECT CURRENT_TIMESTAMP(2)::timestamp;

SELECT CURRENT_TIMESTAMP(2)::timestamp, CURRENT_DATE, CURRENT_TIME(2)::time;

-- next, additional built-in functions that will help us transform timestamp and interval data types and create 
-- new fields that will help us prepare data for analysis.

-- This type of data manipulation is useful when the precision of a timestamp is not useful for analysis and you 
-- want to use date parts like year or month in your queries but the underlying data only contains a standard 
-- timestamp value. You may also not care about certain precision like time of day in some analyses and 
-- truncating timestamps may be necessary.

SELECT EXTRACT(quarter FROM timestamp '2005-01-24 05:12:00') AS quarter1,
	DATE_PART('quarter',timestamp '2005-01-24 05:12:00' ) AS quarter2;
	
SELECT 
	EXTRACT(quarter FROM payment_date) AS quarter,
	EXTRACT(year FROM payment_date) AS year,
	SUM(amount) AS total_payments
FROM payment
GROUP BY 1,2;

-- The DATE_TRUNC() function will truncate timestamp or interval data types to return a timestamp or interval at a 
-- specified precision. The precision values are a subset of the field identifiers that can be used with the 
-- EXTRACT() and DATE_PART() functions

SELECT DATE_TRUNC('year', timestamp '2005-05-21 15:30:30');
SELECT DATE_TRUNC('month', timestamp '2005-05-21 15:30:30');

SELECT 
  -- Extract day of week from rental_date
  EXTRACT(dow FROM rental_date) AS dayofweek 
FROM rental 
LIMIT 100;

SELECT 
  c.first_name || ' ' || c.last_name AS customer_name,
  f.title,
  r.rental_date,
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM r.rental_date) AS dayofweek,
  AGE(r.return_date, r.rental_date) AS rental_days,
  -- Use DATE_TRUNC to get days from the AGE function
  CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rental_date)) > 
  -- Calculate number of d
    f.rental_duration * INTERVAL '1' day 
  THEN TRUE 
  ELSE FALSE END AS past_due 
FROM 
  film AS f 
  INNER JOIN inventory AS i 
  	ON f.film_id = i.film_id 
  INNER JOIN rental AS r 
  	ON i.inventory_id = r.inventory_id 
  INNER JOIN customer AS c 
  	ON c.customer_id = r.customer_id 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  r.rental_date BETWEEN CAST('2005-05-01' AS DATE) 
  AND CAST('2005-05-01' AS DATE) + INTERVAL '90 day';