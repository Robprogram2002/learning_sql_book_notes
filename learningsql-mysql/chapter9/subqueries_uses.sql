-- Subqueries as Data Sources
SELECT c.first_name, c.last_name, 
    pymnt.num_rentals, pymnt.tot_payments 
FROM customer c 
    INNER JOIN 
        (SELECT customer_id, count(*) num_rentals, 
            sum(amount) tot_payments 
        FROM payment
        GROUP BY customer_id 
        ) pymnt 
    ON c.customer_id = pymnt.customer_id;


-- Data fabrication
-- you can use subqueries to generate data that doesn’t exist in any form within your database. For example, 
-- you may wish to group your customers by the amount of money spent on film rentals, but you want to use 
-- group definitions that are not stored in your database. 

SELECT pymnt_grps.name, count(*) num_customers 
FROM 
    (SELECT customer_id,
        count(*) num_rentals, sum(amount) tot_payments
    FROM payment 
    GROUP BY customer_id 
    ) pymnt
    INNER JOIN 
    (SELECT 'Small Fry' name, 0 low_limit, 74.99 high_limit 
    UNION ALL 
    SELECT 'Average Joes' name, 75 low_limit, 149.99 high_limit 
    UNION ALL 
    SELECT 'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit 
    ) pymnt_grps 
    ON pymnt.tot_payments
        BETWEEN pymnt_grps.low_limit AND pymnt_grps.high_limit 
GROUP BY pymnt_grps.name;

-- Task-oriented subqueries

-- generate a report showing each customer’s name, along with their city, 
-- the total number of rentals, and the total payment amount

SELECT c.first_name, c.last_name, ct.city, 
    sum(p.amount) tot_payments, count(*) tot_rentals 
FROM payment p 
    INNER JOIN customer c 
    ON p.customer_id = c.customer_id 
    INNER JOIN address a 
    ON c.address_id = a.address_id 
    INNER JOIN city ct 
    ON a.city_id = ct.city_id
GROUP BY c.first_name, c.last_name, ct.city;


-- the customer, address, and city tables are needed only for display purposes and 
-- that the payment table has everything needed to generate the groupings (customer_id 
-- and amount). Therefore, you could separate out the task of generating the groups 
-- into a subquery and then join the other three tables to the table generated by 
-- the subquery to achieve the desired end result

SELECT c.first_name, c.last_name, 
    ct.city, 
    pymnt.tot_payments, pymnt.tot_rentals 
FROM 
    (SELECT customer_id, 
        count(*) tot_rentals, sum(amount) tot_payments
    FROM payment 
    GROUP BY customer_id 
    ) pymnt 
    INNER JOIN customer c 
    ON pymnt.customer_id = c.customer_id 
    INNER JOIN address a 
    ON c.address_id = a.address_id 
    INNER JOIN city ct 
    ON a.city_id = ct.city_id;

-- Common table expressions (CTEs)

-- A CTE is a named subquery that appears at the top of a query in a with clause, which can contain multiple 
-- CTEs separated by commas. Along with making queries more understandable, this feature also allows each CTE 
-- to refer to any other CTE defined above it in the same with clause

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
    ON i.inventory_id = r.inventory_id 
    INNER JOIN payment p
    ON r.rental_id = p.rental_id 
) -- end of With clause
SELECT spg_rev.first_name, spg_rev.last_name, 
    sum(spg_rev.amount) tot_revenue 
FROM actors_s_pg_revenue spg_rev 
GROUP BY spg_rev.first_name, spg_rev.last_name 
ORDER BY 3 desc;

-- This query calculates the total revenues generated from PG-rated film rentals 
-- where the cast includes an actor whose last name starts with S.

-- Those who tend to utilize temporary tables to store query results for use in 
-- subsequent queries may find CTEs an attractive alternative.


-- Subqueries as Expression Generators

-- Along with being used in filter conditions, scalar subqueries may be used wherever an 
-- expression can appear, including the select and order by clauses of a query and the 
-- values clause of an insert statement.

SELECT a.actor_id, a.first_name, a.last_name 
FROM actor a 
ORDER BY 
    (SELECT count(*) FROM film_actor fa 
    WHERE fa.actor_id = a.actor_id) DESC;

-- The query uses a correlated scalar subquery in the order by clause to return just the 
-- number of film appearances, and this value is used solely for sorting purposes.

SELECT 
    (SELECT c.first_name FROM customer c 
     WHERE c.customer_id = p.customer_id 
    ) first_name, 
    (SELECT c.last_name FROM customer c 
     WHERE c.customer_id = p.customer_id 
    ) last_name, 
    (SELECT ct.city 
     FROM customer c 
        INNER JOIN address a 
        ON c.address_id = a.address_id
        INNER JOIN city ct ->
        ON a.city_id = ct.city_id
     WHERE c.customer_id = p.customer_id 
    ) city, 
    sum(p.amount) tot_payments, 
    count(*) tot_rentals 
FROM payment p
GROUP BY p.customer_id;

-- correlated scalar subqueries are used in the select clause to look up the customer’s first/last names and city.
-- The customer table is accessed three times because scalar subqueries can return only a single column and row

-- you can use noncorrelated scalar subqueries to generate values for an insert statement

INSERT INTO film_actor (actor_id, film_id, last_update) 
VALUES (
 (SELECT actor_id FROM actor
  WHERE first_name = 'JENNIFER' AND last_name = 'DAVIS'), 
 (SELECT film_id FROM film 
  WHERE title = 'ACE GOLDFINGER'), 
 now() 
 );

-- Using a single SQL statement, you can create a row in the film_actor table and look up two foreign key 
-- column values at the same time.








