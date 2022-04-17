-- This query includes a case expression to generate a value for the activity_type column, which returns the 
-- string “ACTIVE” or “INACTIVE” depending on the value of the customer.active column
SELECT first_name, last_name, 
    CASE 
        WHEN active = 1 THEN 'ACTIVE' 
        ELSE 'INACTIVE'
    END activity_type 
FROM customer;

-- example of a case expression with a subquery 
SELECT c.first_name, c.last_name, 
    CASE 
        WHEN active = 0 THEN 0
        ELSE 
          (SELECT count(*) FROM rental r 
           WHERE r.customer_id = c.customer_id)
    END num_rentals 
FROM customer c;

-- This version of the query uses a correlated subquery to retrieve the number of rentals for each active customer. 
-- Depending on the percentage of active customers, using this approach may be more efficient than joining the 
-- customer and rental tables and grouping on the customer_id column.

-- Transforming the result set

SELECT 
    SUM(CASE WHEN monthname(rental_date) = 'May' THEN 1 
    ELSE 0 END) May_rentals,
    SUM(CASE WHEN monthname(rental_date) = 'June' THEN 1
    ELSE 0 END) June_rentals,
    SUM(CASE WHEN monthname(rental_date) = 'July' THEN 1 
    ELSE 0 END) July_rentals 
FROM rental 
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01';

-- When the monthname() function returns the desired value for that column, the case expression returns the value 1; 
-- otherwise, it returns a 0. When summed over all rows, each column returns the number of accounts opened for 
-- that month. Obviously, such transformations are practical for only a small number of values


-- check existance using case statement

SELECT a.first_name, a.last_name, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM film_actor fa
                        INNER JOIN film f 
                        ON fa.film_id = f.film_id 
                     WHERE fa.actor_id = a.actor_id AND f.rating = 'G') THEN 'Y'
        ELSE 'N'
        END g_actor, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM film_actor fa
                        INNER JOIN film f 
                        ON fa.film_id = f.film_id 
                        WHERE fa.actor_id = a.actor_id AND f.rating = 'PG') THEN 'Y'
        ELSE 'N'
        END pg_actor, 
    CASE 
        WHEN EXISTS (SELECT 1 FROM film_actor fa
                        INNER JOIN film f 
                        ON fa.film_id = f.film_id 
                        WHERE fa.actor_id = a.actor_id AND f.rating = 'NC-17') THEN 'Y'
        ELSE 'N'
        END nc17_actor 
FROM actor a
WHERE a.last_name LIKE 'S%' OR a.first_name LIKE 'S%';

-- Each case expression includes a correlated subquery against the film_actor and film tables; one looks for 
-- films with a G rating, the second for films with a PG rating, and the third for films with a NC-17 rating. 
-- Since each when clause uses the exists operator, the conditions evaluate to true as long as the actor has 
-- appeared in at least one film with the proper rating.

-- Conditional Update example 
-- run a job every week that will set the customer.active column to 0 for any customers who haven’t 
-- rented a film in the last 90 days.

UPDATE customer 
SET active = CASE 
                WHEN 90 <= (SELECT datediff(now(), max(rental_date)) 
                            FROM rental r
                            WHERE r.customer_id = customer.customer_id)
                    THEN 0 
                ELSE 1 
             END 
WHERE active = 1;

-- This statement uses a correlated subquery to determine the number of days since the last rental date for 
-- each customer and compares the value to 90; if the number returned by the subquery is 90 or higher, the 
-- customer is marked as inactive.


-- changing null to some displaying string example

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


