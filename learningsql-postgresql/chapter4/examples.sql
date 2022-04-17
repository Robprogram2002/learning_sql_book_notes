-- equality condition 
SELECT c.email FROM customer AS c
    INNER JOIN rental r
    ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14';

-- inequality condition 
SELECT c.email FROM customer AS c
    INNER JOIN rental r
    ON c.customer_id = r.customer_id
WHERE date(r.rental_date) <> '2005-06-14';

-- Range condition
SELECT customer_id, rental_date 
FROM rental
WHERE rental_date <= '2005-06-16'
    AND rental_date >= '2005-06-14';


-- When you have both an upper and lower limit for your range, you may choose to use a single condition that utilizes 
-- the between operator rather than using two separate conditions,

SELECT customer_id, rental_date 
FROM rental
WHERE rental_date BETWEEN '2005-06-14' AND '2005-06-16';
-- remember that your upper and lower limits are inclusive, 

-- Along with dates, you can also build conditions to specify ranges of numbers.
SELECT customer_id, payment_date, amount 
FROM payment 
WHERE amount BETWEEN 10.0 AND 11.99;


-- Membership Condition 
SELECT title, rating 
FROM film
WHERE rating IN ('G','PG');

-- using subqueries : if you can assume that any film whose title includes the string 'PET' would be safe for family 
-- viewing, you could execute a subquery against the film table to retrieve all ratings associated with these films and 
-- then retrieve all films having any of these ratings

SELECT title, rating
FROM film,
WHERE rating IN (SELECT rating FROM film WHERE title LIKE '%PET%');

-- The subquery returns the set 'G' and 'PG', and the main query checks to see whether the value of the rating column
--  can be found in the set returned by the subquery

-- Using not in

SELECT title, rating 
FROM film
WHERE rating NOT IN ('PG-13','R', 'NC-17');


-- Matching Condition 
-- Task : find all customers whose last name begins with Q.

--  You could use a built-in function to strip off the first letter of the last_name column

SELECT last_name, first_name
FROM customer
WHERE left(last_name, 1) = 'Q';

-- or you can use wildcard characters to build search expressions

SELECT last_name, first_name
FROM customer 
WHERE last_name LIKE '_A_T%S';

-- The underscore character takes the place of a single character, while the percent sign can take the place of a 
-- variable number of characters (including 0)

-- if your needs are a bit more sophisticated, however, you can use multiple search expressions,

SELECT last_name, first_name
FROM customer 
WHERE last_name LIKE 'Q%' OR last_name LIKE 'Y%';

-- Using regular expressions
SELECT last_name, first_name
FROM customer 
WHERE last_name REGEXP '^[QY]';

-- The regexp operator takes a regular expression and applies it to the expression on the lefthand side of the condition 

-- Null conditions

SELECT rental_id, customer_id
FROM rental
WHERE return_date IS NULL;

SELECT rental_id, customer_id, return_date
FROM rental
WHERE return_date IS NOT NULL;