SELECT customer_id, first_name, last_name 
FROM customer 
WHERE customer_id = (SELECT MAX(customer_id) FROM customer);

-- The subquery returns a single row with a single column, which allows it to be used as one of the expressions in an 
-- equality condition (if the subquery returned two or more rows, it could be compared to something but could not be 
-- equal to anything)

--  Filter using subquery 

SELECT city_id, city 
FROM city
WHERE country_id IN 
    (
    SELECT country_id 
    FROM country 
    WHERE country IN ('Canada','Mexico')
    );

-- Along with seeing whether a value exists within a set of values, you can check the converse using the not in 
-- operator.

-- Using the all operator 

    SELECT first_name, last_name 
    FROM customer 
    WHERE customer_id <> ALL 
        (SELECT customer_id -> FROM payment -> WHERE amount = 0);

-- other example

SELECT customer_id, count(*) 
FROM rental
GROUP BY customer_id 
HAVING count(*) > ALL 
    (
        SELECT count(*) 
        FROM rental r
            INNER JOIN customer c
            ON r.customer_id = c.customer_id INNER JOIN address a
            ON c.address_id = a.address_id INNER JOIN city ct
            ON a.city_id = ct.city_id INNER JOIN country co
            ON ct.country_id = co.country_id
        WHERE co.country IN ('United States','Mexico','Canada') 
        GROUP BY r.customer_id 
    );

-- The subquery in this example returns the total number of film rentals for all customers in North America, 
-- and the containing query returns all customers whose total number of film rentals exceeds any of the North 
-- American customers.

-- Example of the any operator 

-- find all customers whose total film rental payments exceed the total payments for all customers in Bolivia, 
-- Paraguay, or Chile:
SELECT customer_id, sum(amount) 
FROM payment
GROUP BY customer_id 
HAVING sum(amount) > ANY 
    (
        SELECT sum(p.amount) 
        FROM payment p 
        INNER JOIN customer c
        ON p.customer_id = c.customer_id INNER JOIN address a
        ON c.address_id = a.address_id INNER JOIN city ct
        ON a.city_id = ct.city_id INNER JOIN country co
        ON ct.country_id = co.country_id
        WHERE co.country IN ('Bolivia','Paraguay','Chile') 
        GROUP BY co.country
    );

-- The subquery returns the total film rental fees for all customers in Bolivia, Paraguay, and Chile, and the 
-- containing query returns all customers who outspent at least one of these three countries

-- Although most people prefer to use in, using = any is equivalent to using the in operator.

-- example , filter using two columns 
SELECT actor_id, film_id 
FROM film_actor 
WHERE (actor_id, film_id) IN 
    (
        SELECT a.actor_id, f.film_id 
        FROM actor a 
            CROSS JOIN film f
        WHERE a.last_name = 'MONROE' AND f.rating = 'PG'
    );

-- Exists operator example
    SELECT a.first_name, a.last_name  
    FROM actor a 
    WHERE NOT EXISTS 
        (SELECT 1 
        FROM film_actor fa
            INNER JOIN film f ON f.film_id = fa.film_id
        WHERE fa.actor_id = a.actor_id 
            AND f.rating = 'R');

UPDATE customer c SET c.last_update =
    (SELECT max(r.rental_date) FROM rental r 
    WHERE r.customer_id = c.customer_id) 
WHERE EXISTS
    (SELECT 1 FROM rental r 
    WHERE r.customer_id = c.customer_id);

-- Examle of  Subqueries as Data Sources

SELECT c.first_name, c.last_name, pymnt.num_rentals, pymnt.tot_payments 
FROM customer c 
    INNER JOIN 
        (SELECT customer_id, 
        count(*) num_rentals, sum(amount) tot_payments 
        FROM payment
        GROUP BY customer_id ) pymnt
    ON c.customer_id = pymnt.customer_id;


-- Example: Task-Oriented subqueries

SELECT c.first_name, c.last_name, 
    ct.city, 
    pymnt.tot_payments, pymnt.tot_rentals 
FROM 
 (SELECT customer_id, count(*) tot_rentals, sum(amount) tot_payments
  FROM payment 
  GROUP BY customer_id 
 ) pymnt 
    INNER JOIN customer c 
    ON pymnt.customer_id = c.customer_id 
    INNER JOIN address a 
    ON c.address_id = a.address_id 
    INNER JOIN city ct 
    ON a.city_id = ct.city_id;

-- CTEs examples

-- The following example includes three CTEs, where the second refers to the first, and the third refers 
-- to the second:

WITH actors_s AS 
    (SELECT actor_id, first_name, last_name 
     FROM actor 
     WHERE last_name LIKE 'S%' 
    ), 
    actors_s_pg AS 
    (SELECT s.actor_id, s.first_name, s.last_name,
        f.film_id, f.title
     FROM actors_s s
     INNER JOIN film_actor fa
     ON s.actor_id = fa.actor_id 
     INNER JOIN film f
     ON f.film_id = fa.film_id
     WHERE f.rating = 'PG' 
    ),
    actors_s_pg_revenue AS 
    (SELECT spg.first_name, spg.last_name, p.amount 
     FROM actors_s_pg spg
     INNER JOIN inventory i
     ON i.film_id = spg.film_id 
     INNER JOIN rental r
     ON i.inventory_id = r.inventory_id INNER JOIN payment p
     ON r.rental_id = p.rental_id 
    ) -- end of With clause
SELECT spg_rev.first_name, spg_rev.last_name, 
    sum(spg_rev.amount) tot_revenue 
FROM actors_s_pg_revenue spg_rev 
GROUP BY spg_rev.first_name, spg_rev.last_name 
ORDER BY 3 desc;


-- This query calculates the total revenues generated from PG-rated film rentals where the cast includes an 
-- actor whose last name starts with S. The first subquery (actors_s) finds all actors whose last name starts 
-- with S, the second subquery (actors_s_pg) joins that data set to the film table and filters on films having 
-- a PG rating, and the third subquery (actors_s_pg_revenue) joins that data set to the pay ment table to 
-- retrieve the amounts paid to rent any of these films. The final query simply groups the data from 
-- actors_s_pg_revenue by first/last names and sums the revenues.
