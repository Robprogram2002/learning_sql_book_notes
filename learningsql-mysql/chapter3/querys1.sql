-- You can add several things to the select statement (not only column names) such as:
-- • Literals, such as numbers or strings 
-- • Expressions, such as transaction.amount * −1 • Built-in function calls, such as ROUND(transaction.amount, 2) 
-- • User-defined function calls

-- For example, the following query
SELECT language_id, 
    'COMMON' language_usage,
    language_id * 3.1415927 lang_pi_value,
    UPPER(name) lnaguage_name
FROM language;

SELECT name, last_update FROM language;

SELECT version(), user(), database();

-- slect distintic values 
SELECT DISTINCT actor_id FROM film_actor ORDER BY actor_id;

-- Derived (subquery-generated) tables
-- (The data in cust is held in memory for the duration of the query and is then discarded)
SELECT concat(cust.last_name, ', ', cust.first_name) AS full_name , email 
FROM (
    SELECT first_name, last_name, email FROM customer
    WHERE first_name = 'JESSIE'
) cust;

-- Linked Tables 
SELECT c.first_name, c.last_name, 
    time(r.rental_date) rental_time 
FROM customer AS c 
    INNER JOIN rental AS r
    ON c.customer_id = r.customer_id 
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY c.last_name, c.first_name;

-- TOP 5 customer rentals for a given date
SELECT c.first_name, c.last_name, 
    time(r.rental_date) rental_time 
FROM customer AS c 
    INNER JOIN rental AS r
    ON c.customer_id = r.customer_id 
WHERE date(r.rental_date) = '2005-06-14'
ORDER BY rental_time DESC
LIMIT 5;

-- Filters

SELECT title FROM film WHERE rating = 'G' AND rental_duration >= 7;

SELECT title, rating, rental_duration 
FROM film
WHERE (rating = 'G' AND rental_duration >= 7) 
    OR (rating = 'PG-13' AND rental_duration < 4);


-- Group by and Having Clauses

SELECT t.customer_id, first_name, last_name, email, rentals  
FROM ( SELECT customer_id, COUNT(*) AS rentals 
    FROM rental 
    GROUP BY customer_id 
    HAVING rentals >= 40 ) t 
    INNER JOIN customer AS c ON t.customer_id = c.customer_id;






