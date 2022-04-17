-- any data inserted into a temporary table will disappear at some point (generally at the end of a transaction 
-- or when your database session is closed).

-- Here’s a simple example showing how actors whose last names start with J can be stored temporarily

CREATE TEMPORARY TABLE actors_j (
    actor_id SMALLINT(5),
    first_name VARCHAR(45),
    last_name VARCHAR(45)
);

INSERT INTO actors_j 
    SELECT actor_id , first_name, last_name FROM actor WHERE last_name LIKE 'J%';

SELECT * FROM actors_j ORDER BY first_name; 