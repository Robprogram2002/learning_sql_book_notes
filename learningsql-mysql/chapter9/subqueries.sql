-- Subqueries are a powerful tool that you can use in all four SQL data statements

-- A subquery is always enclosed within parentheses, and it is usually executed 
-- prior to the containing statement.

-- The type of result set returned by the subquery determines how it may be used and 
-- which operators the containing statement may use to interact with the data the 
-- subquery returns. 

-- When the containing statement has finished executing, the data returned by any 
-- subqueries is discarded, making a subquery act like a temporary table with 
-- statement scope 

SELECT customer_id, first_name, last_name 
FROM customer 
WHERE customer_id = (SELECT MAX(customer_id) FROM customer);

-- Noncorrelated Subqueries -------------------------------
-- it may be executed alone and does not reference anything from the containing statement.

-- scalar subquery
SELECT city_id, city 
FROM city
WHERE country_id <> (SELECT country_id FROM country WHERE country = 'India');
-- this query returns all cities that are not in India

-- one column subqueries and
SELECT city_id, city 
FROM city
WHERE country_id IN 
    (SELECT country_id 
    FROM country 
    WHERE country IN ('Canada','Mexico'));

-- the all operator allows you to make comparisons between a single value and every value in a set. 
-- To build such a condition, you will need to use one of the comparison operators (=, <>, <, >, etc.) 
-- in conjunction with the all operator

-- the next query finds all customers who have never gotten a free film rental
SELECT first_name, last_name 
FROM customer 
WHERE customer_id <> ALL 
    (SELECT customer_id 
    FROM payment 
    WHERE amount = 0);


-- you must be careful to ensure that the set of values does not contain a null value, because the 
-- server equates the value on the lefthand side of the expression to each member of the set, and 
-- any attempt to equate a value to null yields unknown

SELECT customer_id, count(*) 
FROM rental
GROUP BY customer_id 
HAVING count(*) > ALL 
    (SELECT count(*) 
    FROM rental r 
        INNER JOIN customer c
        ON r.customer_id = c.customer_id 
        INNER JOIN address a
        ON c.address_id = a.address_id 
        INNER JOIN city ct
        ON a.city_id = ct.city_id 
        INNER JOIN country co
        ON ct.country_id = co.country_id
    WHERE co.country IN ('United States','Mexico','Canada') 
    GROUP BY r.customer_id 
    );

-- The subquery in this example returns the total number of film rentals for all customers in North 
-- America, and the containing query returns all customers whose total number of film rentals exceeds 
-- any of the North American customers


-- Multicolumn Subqueries 

-- The following two subqueries can be merge into one subquery with two result columns. Then we can use 
-- the two columns to make the same filter condition
SELECT fa.actor_id, fa.film_id 
FROM film_actor fa
WHERE fa.actor_id IN 
    (SELECT actor_id FROM actor WHERE last_name = 'MONROE') 
    AND fa.film_id IN 
    (SELECT film_id FROM film WHERE rating = 'PG');


SELECT actor_id, film_id 
FROM film_actor 
WHERE (actor_id, film_id) IN 
    (SELECT a.actor_id, f.film_id 
    FROM actor a ->
        CROSS JOIN film f
    WHERE a.last_name = 'MONROE' 
        AND f.rating = 'PG');



-- Correlated Subqueries -------------------------------

-- It is dependent on its containing statement from which it references one or more columns. 
-- A correlated subquery is not executed once prior to execution of the containing statement; instead, 
-- the correlated subquery is executed once for each candidate row (rows that might be 
-- included in the final results).


-- the following query uses a correlated subquery to count the number of film rentals for each customer, 
-- and the containing query then retrieves those customers who have rented exactly 20 films

SELECT c.first_name, c.last_name 
FROM customer c 
WHERE 20 = 
    (SELECT count(*) 
    FROM rental r 
    WHERE r.customer_id = c.customer_id);

-- The reference to c.customer_id at the very end of the subquery is what makes the subquery correlated; 
-- the containing query must supply values for c.customer_id for the subquery to execute. In this case, 
-- the containing query retrieves all 599 rows from the customer table and executes the subquery once 
-- for each customer, passing in the appropriate customer ID for each execution. If the subquery returns 
-- the value 20, then the filter condition is met, and the row is added to the result set.

-- since the correlated subquery will be executed once for each row of the containing query, the use of 
-- correlated subqueries can cause performance issues if the containing query returns a large number of 
-- rows.

SELECT c.first_name, c.last_name 
FROM customer c 
WHERE 
    (SELECT sum(p.amount) FROM payment p 
    WHERE p.customer_id = c.customer_id) 
    BETWEEN 180 AND 240;

-- the correlated subquery is executed 599 times (once for each customer row), and each execution of the 
-- subquery returns the total account balance for the given customer

-- EXIST operator.
-- You use the exists operator when you want to identify that a relationship exists without 
-- regard for the quantity


-- find all the customers who rented at least one film prior to May 25, 2005, without regard for 
-- how many films were rented

SELECT c.first_name, c.last_name 
FROM customer c 
WHERE EXISTS 
    (SELECT 1 FROM rental r 
    WHERE r.customer_id = c.customer_id 
        AND date(r.rental_date) < '2005-05-25');


-- You may also use not exists to check for subqueries that return no rows,
-- This query finds all actors who have never appeared in an R-rated film.
SELECT a.first_name, a.last_name 
FROM actor a 
WHERE NOT EXISTS 
    (SELECT 1 
    FROM film_actor fa 
        INNER JOIN film f 
        ON f.film_id = fa.film_id
    WHERE fa.actor_id = a.actor_id
        AND f.rating = 'R');


-- Data Manipulation Using Correlated Subqueries -------------

-- modify the last_update column in the customer table by finding the latest rental 
-- date for each customer in the rental table
UPDATE customer c 
SET c.last_update =
    (SELECT max(r.rental_date) 
    FROM rental r 
    WHERE r.customer_id = c.customer_id);  

-- last query may set column to null if there is no rental for the customer
-- The next version made one more filter to avoid this.
UPDATE customer c 
SET c.last_update =
    (SELECT max(r.rental_date) 
    FROM rental r 
    WHERE r.customer_id = c.customer_id) 
WHERE EXISTS        
    (SELECT 1 
    FROM rental r 
    WHERE r.customer_id = c.customer_id);

-- you may run a data maintenance script at the end of each month that removes unnecessary data.
-- Example: removes rows from the customer table where there have been no film rentals in the past year:
DELETE FROM customer 
WHERE 365 < ALL
    (SELECT datediff(now(), r.rental_date) days_since_last_rental 
    FROM rental r
    WHERE r.customer_id = customer.customer_id);

-- other way of do it may be
DELETE FROM customer 
WHERE 365 < 
    (SELECT MAX(datediff(now(), r.rental_date)) 
    FROM rental r
    WHERE r.customer_id = customer.customer_id
    GROUP BY customer_id);


-- in MySQL table aliases are not allowed when using delete.

