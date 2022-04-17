SELECT c.first_name, c.last_name, a.address, ct.city
FROM customer AS c 
    INNER JOIN address AS a  
        ON c.address_id = a.address_id 
    INNER JOIN city AS ct 
        ON a.city_id = ct.city_id
WHERE a.district = 'California';

-- Write a query that returns the title of every film in which an actor with the first name JOHN appeared.
SELECT f.title 
FROM film AS f 
    INNER JOIN film_actor AS fa
        ON f.film_id = fa.film_id
    INNER JOIN actor a 
        ON fa.actor_id = a.actor_id
WHERE a.fisrt_name = 'JOHN'
ORDER BY f.title;

-- Construct a query that returns all addresses that are in the same city. You will need to join the address table to 
-- itself, and each row should include two different addresses.




