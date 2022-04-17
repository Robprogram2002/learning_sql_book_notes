-- Retrieve the actor ID, first name, and last name for all actors. Sort by last name and then by first name.
SELECT actor_id, first_name, last_name 
FROM actor
ORDER BY last_name, first_name;

-- Retrieve the actor ID, first name, and last name for all actors whose last name equals 'WILLIAMS' or 'DAVIS'.
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name IN ('WILLIAMS', 'DAVIS');
-- WHERE last_name = 'WILLIAMS' or last_name = 'DAVIS';

-- Write a query against the rental table that returns the IDs of the customers who rented a film on 
-- July 5, 2005 (use the rental.rental_date column, and you can use the date() function to ignore the 
-- time component). Include a single row for each distinct customer ID.

SELECT customer_id FROM rental WHERE date(rental.rental_date) = '2005-07-05';

-- 
SELECT c.email, r.return_date 
FROM customer AS c
    INNER JOIN rental AS r
    ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY 2 DESC;

