-- Equallity conditions 

SELECT c.email 
FROM customer c 
    INNER JOIN rental r 
    ON c.customer_id = r.customer_id 
WHERE date(r.rental_date) = '2005-06-14';

DELETE FROM rental WHERE year(rental_date) = 2004;

-- Example: actors that appears in a given film query by its title
SELECT t.actor_id, a.first_name, a.last_name FROM film_actor AS t 
    INNER JOIN actor AS a
    ON a.actor_id = t.actor_id
WHERE t.film_id = (SELECT film_id FROM film WHERE title = 'RIVER OUTLAW');


-- Inequality conditions
SELECT c.email 
FROM customer c 
    INNER JOIN rental r 
    ON c.customer_id = r.customer_id 
WHERE date(r.rental_date) <> '2005-06-14';


-- Range Conditions
SELECT customer_id, rental_date 
FROM rental
WHERE rental_date BETWEEN '2005-06-14' AND '2005-06-16';

-- (You should always specify the lower limit  and the upper limit. Also remember that your upper and lower limits 
-- are inclusive )

SELECT customer_id, payment_date, amount 
FROM payment
WHERE amount BETWEEN 10.0 AND 11.99;

SELECT last_name, first_name 
FROM customer
WHERE last_name BETWEEN 'FA' AND 'FR'
ORDER BY last_name;


-- Membership Conditions
SELECT title, rating FROM film
WHERE rating IN ('G','PG');

-- you can use a subquery to generate a set for you on the fly.

-- Example: any film whose title includes the string 'PET' would be safe for family viewing,
-- execute a subquery against the film table to retrieve all ratings associated with these 
-- films and then retrieve all films having any of these ratings

SELECT title, rating 
FROM film 
WHERE rating IN (SELECT rating FROM film WHERE title LIKE '%PET%');

-- we can do the same but to get films where is rating differens from films that contains the word SEX in its title

SELECT title, rating 
FROM film 
WHERE rating NOT IN (SELECT rating FROM film WHERE title LIKE '%SEX%');

SELECT title, rating FROM film
WHERE rating NOT IN ('PG-13','R', 'NC-17');


-- Matching Conditions

-- the final condition type deals with partial string matches.
-- find all customers whose last name begins with Q (use a built-in 
-- function to strip off the first letter of the last_name column)

SELECT last_name, first_name 
FROM customer
WHERE left(last_name, 1) = 'Q';

SELECT last_name, first_name 
FROM customer
WHERE left(last_name, 1) IN ('Q', 'Y', 'L');

-- When searching for partial string matches, you might be interested in:
-- • Strings beginning/ending with a certain character 
-- • Strings beginning/ending with a substring 
-- • Strings containing a certain character anywhere within the string 
-- • Strings containing a substring anywhere within the string 
-- • Strings with a specific format, regardless of individual characters

SELECT last_name, first_name 
FROM customer
WHERE last_name LIKE '_A_T%S';   -- A in second position, T in fourth and end in S

SELECT last_name, first_name 
FROM customer
WHERE last_name LIKE 'F%';  -- Begin with F

SELECT last_name, first_name 
FROM customer
WHERE last_name LIKE '%T';  -- End with T

SELECT last_name, first_name 
FROM customer
WHERE last_name LIKE '%BAS%'; --  contains the substring 'BAS'

SELECT last_name, first_name 
FROM customer
WHERE last_name LIKE '__T_';  -- Four-character strings with a t in the third position


-- Using regular expressions
SELECT last_name, first_name 
FROM customer
WHERE last_name REGEXP '^[QY]';  -- start with Q or Y


-- When working with null, you should remember:
-- • An expression can be null, but it can never equal null. 
-- • Two nulls are never equal to each other.

SELECT rental_id, customer_id 
FROM rental
WHERE return_date IS NULL;  -- finds all film rentals that were never returned

SELECT rental_id, customer_id, return_date 
FROM rental
WHERE return_date IS NOT NULL; -- all rentals that were returned

    

