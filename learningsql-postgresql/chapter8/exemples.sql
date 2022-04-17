-- For example, let’s say that you are in charge of sending coupons for free rentals to your best customers.
-- To see how many films each customer rented, you can use an aggregate function in the select clause to count 
-- the number of rows in each group:

SELECT customer_id, count(*) FROM rental
GROUP BY customer_id
ORDER BY customer_id LIMIT 10;

-- The aggregate function count() counts the number of rows in each group, and the asterisk tells the server to 
-- count everything in the group

SELECT customer_id, count(*) FROM rental
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 8;

SELECT customer_id, count(*) FROM rental
GROUP BY customer_id
HAVING count(*) >= 40
ORDER BY customer_id;

-- Here’s a query that uses all of the common aggregate functions to analyze the data on film rental payments:
--  This query use an implicit group (the one made of all the rows in the table)
SELECT MAX(amount) max_amt, 
    MIN(amount) min_amt, 
    AVG(amount) avg_amt, 
    SUM(amount) tot_amt, 
    COUNT(*) num_payments 
FROM payment;

-- in order to add a column we must add a group by cloused
SELECT customer_id,
    MAX(amount) max_amt, 
    MIN(amount) min_amt, 
    AVG(amount) avg_amt, 
    SUM(amount) tot_amt, 
    COUNT(*) num_payments 
FROM payment
GROUP BY customer_id;

-- With the inclusion of the group by clause, the server knows to group together rows having the same value in the 
-- customer_id column first and then to apply the five aggregate functions to each of the 599 groups

-- We can use count function in two ways 

SELECT COUNT(customer_id) num_rows, 
    COUNT(DISTINCT customer_id) num_customers 
FROM payment;

-- using an expression like argument for an aggregation function 

SELECT MAX(datediff(return_date,rental_date)) FROM rental;

-- Single Column groups

-- find the number of films associated with each actor, 
SELECT actor_id, count(*) AS films_count
FROM film_actor 
GROUP BY actor_id
ORDER BY count(*) DESC;

-- combining group by and inner join
SELECT a.actor_id, j.films_count, CONCAT(a.first_name, ' ', a.last_name) AS name 
FROM actor AS a
    INNER JOIN (
        SELECT actor_id, count(*) AS films_count
        FROM film_actor 
        GROUP BY actor_id
        ORDER BY count(*) DESC
    ) AS j
    ON j.actor_id = a.actor_id
ORDER BY j.films_count DESC;


-- Multicolumn Grouping Example 

-- find the total number of films for each film rating (G, PG, ...) for each actor

SELECT fa.actor_id, f.rating, count(*) 
FROM film_actor fa 
    INNER JOIN film f 
    ON fa.film_id = f.film_id 
GROUP BY fa.actor_id, f.rating 
ORDER BY 1,2;

--  Let’s say, however, that along  with the total count for each actor/rating combination, you also want total 
-- counts for each distinct actor.

-- you could use the with rollup option to have the database server do the work for you. 

SELECT fa.actor_id, f.rating, count(*) 
FROM film_actor fa 
    INNER JOIN film f 
    ON fa.film_id = f.film_id 
GROUP BY fa.actor_id, f.rating WITH ROLLUP  
ORDER BY 1,2;

-- There are now 201 additional rows in the result set, one for each of the 200 distinct actors and one for the grand 
-- total (all actors combined)
-- For the 200 actor rollups, a null value is provided for the rating column, since the rollup is being performed 
-- across all ratings.


-- Using where and having in the same query 

SELECT fa.actor_id, f.rating, count(*) 
FROM film_actor fa 
    INNER JOIN film f 
    ON fa.film_id = f.film_id 
WHERE f.rating IN ('G','PG') 
GROUP BY fa.actor_id, f.rating 
HAVING count(*) > 9;

-- one of the filters acts on data before it is grouped, and the other filter acts on data after the groups have 
-- been created
