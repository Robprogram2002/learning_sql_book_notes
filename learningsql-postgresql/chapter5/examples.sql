-- INNER JOIN EXAMPLE 
SELECT c.first_name, c.last_name, a.address
FROM customer AS c
    INNER JOIN address AS a
    ON c.address_id = a.address_id;

-- or we can use the USING keyword

SELECT c.first_name, c.last_name, a.address
FROM customer AS c
    INNER JOIN address AS a
    USING (address_id);

-- Three tables join example

SELECT c.first_name, c.last_name, ct.city
FROM customer AS c
    INNER JOIN address AS a
    ON c.address_id = a.address_id
        INNER JOIN city AS ct
        ON ct.city_id = a.city_id;


-- indeed, the order in which the three tables are listed , doesn't matter. The following queries return the 
-- same result as the previus query.

SELECT c.first_name, c.last_name, ct.city 
FROM city ct
    INNER JOIN address a 
    ON a.city_id = ct.city_id 
        INNER JOIN customer c
        ON c.address_id = a.address_id;

SELECT c.first_name, c.last_name, ct.city 
FROM address a
    INNER JOIN city ct 
    ON a.city_id = ct.city_id 
        INNER JOIN customer c
        ON c.address_id = a.address_id;

-- The only difference you may see would be the order in which the rows are returned, since there is no order 
-- by clause to specify how the results should be ordered.


-- ## Using Subqueries as Tables

SELECT c.first_name, c.last_name, addr.address, addr.city
FROM customer AS c
    INNER JOIN (
        SELECT a.address_id, a.address, ct.city
        FROM address AS a
            INNER JOIN city AS ct
            ON a.city_id = ct.city_id
        WHERE a.district = 'California'
    ) AS addr
    ON c.address_id = addr.address_id
ORDER BY c.first_name , c.last_name;

-- The subquery finds all addresses that are in California. The outer query joins the subquery results to the 
-- customer table to return the first name, last name, street address, and city of all customers who live in 
-- California. While this query could have been written without the use of a subquery by simply joining the three 
-- tables, it can sometimes be advantageous from a performance and/or readability aspect to use one or more subqueries.


-- Using the Same Table Twice
-- If you want to find all of the films in which two specific actors appear, you could write a query such as this one

SELECT f.title 
FROM film f 
    INNER JOIN film_actor fa  
    ON f.film_id = fa.film_id 
        INNER JOIN actor a 
        ON fa.actor_id = a.actor_id
WHERE ((a.first_name = 'CATE' AND a.last_name = 'MCQUEEN') 
    OR (a.first_name = 'CUBA' AND a.last_name = 'BIRCH'));


-- Example of a self Join

SELECT f.title, f_prnt.title prequel
FROM film f
    INNER JOIN film f_prnt
    ON f_prnt.film_id = f.prequel_film_id
WHERE f.prequel_film_id IS NOT NULL;

