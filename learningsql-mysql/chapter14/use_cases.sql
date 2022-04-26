-- Security 
CREATE VIEW active_customer_vw 
    (customer_id, first_name, 
    last_name, email) AS 
SELECT customer_id, first_name, last_name, 
    concat(substr(email,1,2), '*****', substr(email, -4)) email 
FROM customer 
WHERE active = 1;

-- If you provide this view to your marketing department, they will be able to avoid sending information 
-- to inactive customers,


-- Data Aggregation
-- let’s say that an application generates a report each month showing the total sales for each film category 
-- so that the managers can decide what new films to add to inventory. Rather than allowing the application 
-- developers to write queries against the base tables, you could provide them with the following view:

CREATE VIEW sales_by_film_category 
AS
SELECT 
    c.name AS category,
    SUM(p.amount) AS total_sales 
FROM payment AS p
    INNER JOIN rental AS r ON p.rental_id = r.rental_id 
    INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id 
    INNER JOIN film AS f ON i.film_id = f.film_id 
    INNER JOIN film_category AS fc ON f.film_id = fc.film_id 
    INNER JOIN category AS c ON fc.category_id = c.category_id 
GROUP BY c.name
ORDER BY total_sales DESC;

-- Using this approach gives you a great deal of flexibility as a database designer. If you decide at some point 
-- in the future that query performance would improve dramatically if the data were preaggregated in a table rather 
-- than summed using a view, you could create a film_category_sales table, load it with aggregated data, and modify 
-- the sales_by_film_category view definition to retrieve data from this table. Afterward, all queries that use the 
-- sales_by_film_category view will retrieve data from the new film_category_sales table, meaning that users will 
-- see a performance improvement without needing to modify their queries.


-- Hiding Complexity

-- let’s say that a report is created each month showing information about all of the films, along with the film 
-- category, the number of actors appearing in the film, the total number of copies in inventory, and the number 
-- of rentals for each film. Rather than expecting the report designer to navigate six different tables to gather 
-- the necessary data, you could provide a view that looks as follows:

CREATE VIEW film_stats 
AS
SELECT f.film_id, f.title, f.description, f.rating, 
    (SELECT c.name 
    FROM category c
        INNER JOIN film_category fc 
        ON c.category_id = fc.category_id 
    WHERE fc.film_id = f.film_id
    ) category_name, 
    (SELECT count(*) 
    FROM film_actor fa
    WHERE fa.film_id = f.film_id 
    ) num_actors, 
    (SELECT count(*) 
    FROM inventory i
    WHERE i.film_id = f.film_id 
    ) inventory_cnt, 
    (SELECT count(*) 
    FROM inventory i 
        INNER JOIN rental r
        ON i.inventory_id = r.inventory_id 
    WHERE i.film_id = f.film_id 
    ) num_rentals 
FROM film f;

-- This view definition is interesting because even though data from six different tables can be retrieved through 
-- the view, the from clause of the query has only one table (film). Data from the other five tables is generated 
-- using scalar subqueries. If someone uses this view but does not reference the category_name, num_actors, 
-- inventory_cnt, or num_rentals column, then none of the subqueries will be executed. This approach allows 
-- the view to be used for supplying descriptive information from the film table without unnecessarily joining 
-- five other tables.


-- Joining Partitioned Data

CREATE VIEW payment_all 
    (payment_id, 
    customer_id, 
    staff_id, 
    rental_id, 
    amount,
    payment_date, 
    last_update
) AS
SELECT payment_id, customer_id, staff_id, rental_id, 
    amount, payment_date, last_update 
FROM payment_historic 
UNION ALL
SELECT payment_id, customer_id, staff_id, rental_id, 
    amount, payment_date, last_update 
FROM payment_current;


-- Updatable Views

-- The customer_vw view queries a single table, and only one of the four columns is derived via an expression. 
-- This view definition doesn’t violate any of the restrictions listed earlier, so you can use it to modify 
-- data in the customer table.

UPDATE customer_vw
SET last_name = 'SMITH-ALLEN' 
WHERE customer_id = 1;

-- While you can modify most of the columns in the view in this fashion, you will not be able to modify the 
-- email column, since it is derived from an expression:

UPDATE customer_vw
SET email = 'MARY.SMITH-ALLEN@sakilacustomer.org' 
WHERE customer_id = 1;

-- views that contain derived columns cannot be used for inserting data, even if the derived columns are 
-- not included in the statement.

-- Updating Complex Views
-- The next view joins the customer, address, city, and country tables so that all the data for customers 
-- can be easily queried

CREATE VIEW customer_details 
AS
SELECT c.customer_id, 
    c.store_id, 
    c.first_name, 
    c.last_name, 
    c.address_id, 
    c.active,
    c.create_date, 
    a.address, 
    ct.city, 
    cn.country, 
    a.postal_code 
FROM customer c
    INNER JOIN address a
    ON c.address_id = a.address_id 
    INNER JOIN city ct 
    ON a.city_id = ct.city_id
    INNER JOIN country cn 
    ON ct.country_id = cn.country_id;

-- You may use this view to update data in either the customer or address table:

UPDATE customer_details
SET last_name = 'SMITH-ALLEN', active = 0 
WHERE customer_id = 1;

UPDATE customer_details
SET address = '999 Mockingbird Lane' 
WHERE customer_id = 1;

UPDATE customer_details
SET last_name = 'SMITH-ALLEN', active = 0, 
    address = '999 Mockingbird Lane' 
WHERE customer_id = 1;

-- As you can see, you are allowed to modify both of the underlying tables separately, 
-- but not within a single statement

INSERT INTO customer_details 
    (customer_id, store_id, first_name, last_name, 
    address_id, active, create_date)
VALUES (9998, 1, 'BRIAN', 'SALAZAR', 5, 1, now());

-- This statement, which only populates columns from the customer table, works fine. 

INSERT INTO customer_details 
    (customer_id, store_id, first_name, last_name, 
    address_id, active, create_date, address) 
VALUES (9999, 2, 'THOMAS', 'BISHOP', 7, 1, now(), 
    '999 Mockingbird Lane');

-- This version, which includes columns spanning two different tables, raises an exception. In order to 
-- insert data through a complex view, you would need to know from where each column is sourced. Since 
-- many views are created to hide complexity from end users, this seems to defeat the purpose if the 
-- users need to have explicit knowledge of the view definition.

