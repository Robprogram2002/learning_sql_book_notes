-- a simple example showing how actors whose last names start with J can be stored temporarily

CREATE TEMPORARY TABLE actors_j
    (
        actor_id INTEGER,
        first_name varchar(45),
        last_name varchar(45)
    );

INSERT INTO actors_j 
    SELECT actor_id, first_name, last_name 
    FROM actor WHERE last_name LIKE 'J%';

SELECT * FROM actors_j ORDER BY first_name;

-- These seven rows are held in memory temporarily and will disappear after your session is closed.


-- here’s a view definition that queries the employee table and includes four of the available columns
CREATE VIEW cust_vw AS 
    SELECT customer_id, first_name, last_name, active
    FROM customer;

-- Now that the view exists, you can issue queries against it, as in:
SELECT first_name, last_name FROM cust_vw WHERE active = 0;