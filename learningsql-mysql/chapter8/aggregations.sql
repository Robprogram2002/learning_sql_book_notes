-- how data can be grouped and aggregated to allow users to interact with it at 
-- some higher level of granularity than what is stored in the database.

-- get customers with more films rental (top customers)

SELECT customer_id, count(*) AS rentals 
FROM rental 
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 10;

-- suppose you want to give a coupon code to all customers who has rent more than 40 films 

SELECT customer_id, count(*) AS rentals 
FROM rental 
GROUP BY customer_id
HAVING count(*) >= 40
ORDER BY 2 DESC;


-- get customers with more films rental (top customers) for a given year and month

SELECT customer_id, count(*) AS rentals 
FROM rental 
WHERE extract(year FROM rental_date) = '2005' AND extract(month FROM rental_date) = '05'
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 10;


-- Aggregate Functions -------------------------------

SELECT MAX(amount) max_amt, 
    MIN(amount) min_amt, 
    AVG(amount) avg_amt, 
    SUM(amount) tot_amt, 
    COUNT(*) num_payments 
FROM payment;

-- same result but by customer

SELECT customer_id, MAX(amount) max_amt, 
    MIN(amount) min_amt, 
    AVG(amount) avg_amt, 
    SUM(amount) tot_amt, 
    COUNT(*) num_payments 
FROM payment
GROUP BY customer_id
ORDER BY 4 DESC;


-- Count distinct
SELECT COUNT(customer_id) num_rows, 
COUNT(DISTINCT customer_id) num_customers 
FROM payment;

-- find the maximum number of days between when a film was rented and subsequently returned
SELECT MAX(datediff(return_date,rental_date)) 
FROM rental;

-- find the number of films associated with each actor
-- two ways of doing this. What is more efficient ?

SELECT fa.actor_id, a.first_name, a.last_name, count(fa.film_id) films 
FROM film_actor fa 
    INNER JOIN actor a
    USING (actor_id)
GROUP BY fa.actor_id; 

SELECT fa.actor_id, a.first_name, a.last_name, fa.films
FROM actor a
    INNER JOIN (
        SELECT actor_id, count(film_id) films 
        FROM film_actor 
        GROUP BY actor_id) fa
    USING (actor_id); 


-- find the total number of films for each film rating (G, PG, ...) for each actor
SELECT fa.actor_id, a.first_name, a.last_name, fa.rating, fa.films 
FROM actor a 
    INNER JOIN (
        SELECT actor_id, rating, count(film_id) films 
        FROM film_actor 
            INNER JOIN film 
            USING (film_id)
        GROUP BY actor_id, rating) fa
    USING (actor_id)
ORDER BY actor_id, fa.films;

-- Generating Rollups
-- along with the total count for each actor/rating combination, you also want 
-- total counts for each distinct actor. You can use the WITH ROLLUP sentence.
SELECT fa.actor_id, a.first_name, a.last_name, fa.rating, fa.films 
FROM actor a 
    RIGHT JOIN (
        SELECT actor_id, rating, count(film_id) films 
        FROM film_actor 
            INNER JOIN film 
            USING (film_id)
        GROUP BY actor_id, rating WITH ROLLUP) fa
    USING (actor_id)
ORDER BY actor_id, fa.films;

-- There are now 201 additional rows in the result set, one for each of the 200 distinct 
-- actors and one for the grand total (all actors combined). For the 200 actor rollups, a 
-- null value is provided for the rating column, since the rollup is being performed across 
-- all ratings.

-- Grouping via Expressions

SELECT extract(YEAR FROM rental_date) year, 
    COUNT(*) rentals 
FROM rental
GROUP BY extract(YEAR FROM rental_date);





