SELECT c.first_name, c.last_name, a.address, ct.city 
FROM customer c 
    INNER JOIN address a
    ON c.address_id = a.address_id 
    INNER JOIN city ct 
    ON a.city_id = ct.city_id
WHERE a.district = 'California';

-- Write a query that returns the title of every film in which an actor with the first name JOHN appeared

SELECT fa.film_id, fa.actor_id, a.first_name, f.title 
FROM film_actor AS fa
    INNER JOIN (
        SELECT first_name, actor_id 
        FROM actor 
        WHERE first_name = 'JOHN') AS a
    USING (actor_id) 
    INNER JOIN film AS f
    USING (film_id)
ORDER BY f.title;

-- Construct a query that returns all addresses that are in the same city. You will need to join the 
-- address table to itself, and each row should include two different addresses.

SELECT COUNT(*) counts 
FROM address 
GROUP BY city_id 
HAVING counts > 1;

SELECT a1.address, a2.address, city_id 
FROM address AS a1 
    INNER JOIN address AS a2 
    USING (city_id) 
WHERE a1.address <> a2.address;


