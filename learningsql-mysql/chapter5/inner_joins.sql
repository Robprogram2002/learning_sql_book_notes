SELECT c.first_name, c.last_name, a.address 
FROM customer c 
    INNER JOIN address a 
    ON c.address_id = a.address_id;

-- If the names of the columns used to join the two tables are identical, you can use the using subclause 
-- instead of the on subclause,

SELECT c.first_name, c.last_name, a.address 
FROM customer c INNER JOIN address a 
    USING (address_id);


-- Joining Three or More Tables
SELECT c.first_name, c.last_name, ct.city 
FROM customer c 
    INNER JOIN address a 
    ON c.address_id = a.address_id 
    INNER JOIN city ct 
    ON a.city_id = ct.city_id;


-- Using Subqueries as Tables

-- The following query joins the customer table to a subquery against the address and city tables:
SELECT c.first_name, c.last_name, addr.address, addr.city 
FROM customer c 
    INNER JOIN 
        (SELECT a.address_id, a.address, ct.city
         FROM address a 
         INNER JOIN city ct 
         ON a.city_id = ct.city_id 
         WHERE a.district = 'California' 
        ) addr 
    ON c.address_id = addr.address_id;



-- The subquery finds all addresses that are in California. The outer query joins the subquery results to the 
-- customer table to return the first name, last name, street address, and city of all customers who live in 
-- California. 

-- While this query could have been written without the use of a subquery by simply joining the three tables, 
-- it can sometimes be advantageous from a performance and/or readability aspect to use one or more subqueries


-- Self-Joins
-- (ficticius example)
SELECT f.title, f_prnt.title prequel 
FROM film f 
    INNER JOIN film f_prnt
    ON f_prnt.film_id = f.prequel_film_id 
WHERE f.prequel_film_id IS NOT NULL;



