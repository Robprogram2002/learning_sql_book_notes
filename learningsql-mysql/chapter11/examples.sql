-- Checking for Existence

-- Sometimes you will want to determine whether a relationship exists between two 
-- entities without regard for the quantity
-- For example, you might want to know whether an actor has appeared in at least 
-- one G-rated film, without regard for the actual number of films. 

SELECT a.first_name, a.last_name, 
    CASE 
     WHEN EXISTS (SELECT 1 FROM film_actor fa 
                    INNER JOIN film f ON fa.film_id = f.film_id 
                  WHERE fa.actor_id = a.actor_id 
                    AND f.rating = 'G') THEN 'Y'
     ELSE 'N'
    END g_actor, 
    CASE 
     WHEN EXISTS (SELECT 1 FROM film_actor fa 
                    INNER JOIN film f ON fa.film_id = f.film_id 
                  WHERE fa.actor_id = a.actor_id 
                    AND f.rating = 'PG') THEN 'Y'
     ELSE 'N'
    END pg_actor, 
    CASE 
     WHEN EXISTS (SELECT 1 FROM film_actor fa
                    INNER JOIN film f ON fa.film_id = f.film_id 
                  WHERE fa.actor_id = a.actor_id 
                    AND f.rating = 'NC-17') THEN 'Y'
     ELSE 'N'
    END nc17_actor 
FROM actor a
WHERE a.last_name LIKE 'S%' OR a.first_name LIKE 'S%';

-- In other cases, you may care how many rows are encountered, but only up to a point.

SELECT f.title, 
    CASE (SELECT count(*) FROM inventory i 
          WHERE i.film_id = f.film_id)
        WHEN 0 THEN 'Out Of Stock' 
        WHEN 1 THEN 'Scarce' 
        WHEN 2 THEN 'Scarce' 
        WHEN 3 THEN 'Available' 
        WHEN 4 THEN 'Available'
        ELSE 'Common'
    END film_availability 
FROM film f;

-- To safeguard your calculations from encountering errors or, even worse, from being mysteriously set to null, 
-- you should wrap all denominators in conditional logic,

SELECT c.first_name, c.last_name, 
    sum(p.amount) tot_payment_amt, 
    count(p.amount) num_payments, sum(p.amount) / 
        CASE WHEN count(p.amount) = 0 THEN 1
         ELSE count(p.amount) 
        END avg_payment
FROM customer c 
    LEFT OUTER JOIN payment p 
    ON c.customer_id = p.customer_id 
GROUP BY c.first_name, c.last_name;

-- Conditional Updates

UPDATE customer 
SET active = 
    CASE 
     WHEN 90 <= (SELECT datediff(now(), max(rental_date)) 
                 FROM rental r
                 WHERE r.customer_id = customer.customer_id)
     THEN 0 
     ELSE 1 
    END 
WHERE active = 1;

-- This statement uses a correlated subquery to determine the number of days since the last rental date 
-- for each customer and compares the value to 90; if the number returned by the subquery is 90 or higher, 
-- the customer is marked as inactive.

-- While null values are the appropriate thing to store in a table if the value for a column is unknown, 
-- it is not always appropriate to retrieve null values for display or to take part in expressions.

SELECT c.first_name, c.last_name, 
    CASE 
     WHEN a.address IS NULL THEN 'Unknown' 
     ELSE a.address 
    END address, 
    CASE
     WHEN ct.city IS NULL THEN 'Unknown' 
     ELSE ct.city 
    END city, 
    CASE
     WHEN cn.country IS NULL THEN 'Unknown' 
     ELSE cn.country 
    END country 
FROM customer c
    LEFT OUTER JOIN address a 
    ON c.address_id = a.address_id 
    LEFT OUTER JOIN city ct 
    ON a.city_id = ct.city_id 
    LEFT OUTER JOIN country cn 
    ON ct.country_id = cn.country_id;

    