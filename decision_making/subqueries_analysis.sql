
-- which customers were really disappointed by a movie they watched.
SELECT name
FROM customers
WHERE customer_id IN
	(SELECT DISTINCT customer_id
	FROM renting
	WHERE rating <= 3);

-- report only countries where the date of the first account is smaller than the date of the first 
-- account created in Austria

SELECT country, 
	MIN(date_account_start)
FROM customers
GROUP BY country
HAVING MIN(date_account_start) < 
	(SELECT MIN(date_account_start)
	FROM customers 
	WHERE country = 'Austria');
	
-- who are the actors in the movie Ray?
SELECT name FROM actors
WHERE actor_id IN (
	SELECT actor_id
	FROM actsin 
	WHERE movie_id =
		(SELECT movie_id 
		FROM movies 
		WHERE title = 'Ray')
);

-- Select all information about movies with more than 5 views.

SELECT *
FROM movies
WHERE movie_id IN  -- Select movie IDs from the inner query
	(SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(*) > 5);
	
-- List all customer information for customers who rented more than 10 movies.
SELECT *
FROM customers
WHERE customer_id IN            -- Select all customers with more than 10 movie rentals
	(SELECT customer_id
	FROM renting
	GROUP BY customer_id
	HAVING COUNT(*) > 10);
	
-- Report the movie titles of all movies with average rating higher than the total average.
SELECT title
FROM movies
WHERE movie_id IN
	(SELECT movie_id
	 FROM renting
     GROUP BY movie_id
     HAVING AVG(rating) > 
		(SELECT AVG(rating)
		 FROM renting));

-- Select customers with less than 5 movie rentals
SELECT *
FROM customers as c
WHERE  5 >
	(SELECT count(*)
	FROM renting as r
	WHERE r.customer_id = c.customer_id);

-- Select all customers with a minimum rating smaller than 4 
SELECT *
FROM customers as c
WHERE 4 > 
	(SELECT MIN(rating)
	FROM renting AS r
	WHERE r.customer_id = c.customer_id);
	
-- Select all movies with an average rating higher than 8
SELECT *
FROM movies AS m
WHERE 8 < 
	(SELECT AVG(rating)
	FROM renting AS r
	WHERE r.movie_id = m.movie_id);

-- EXISTS is a special case of a correlated nested query and allows us the check whether the result of a 
-- correlated nested query is empty or not. The EXISTS function returns a boolean value.
-- TRUE is returned if the result of the correlated nested query has at least one row, that means it is not empty. 
-- FALSE is returned if the query returns an empty table.


-- select movies with at least one rating 
SELECT * FROM movies AS m
WHERE EXISTS 
	(SELECT * FROM renting AS r
	WHERE rating IS NOT NULL AND
		r.movie_id = m.movie_id);

-- select movies without a rating
SELECT * FROM movies AS m
WHERE NOT EXISTS 
	(SELECT * FROM renting AS r
	WHERE rating IS NOT NULL AND
		r.movie_id = m.movie_id);
		
-- Having active customers is a key performance indicator for MovieNow. Make a list of customers who gave at least one rating.

SELECT *
FROM customers as c
WHERE EXISTS
	(SELECT *
	FROM renting AS r
	WHERE rating IS NOT NULL 
	AND r.customer_id = c.customer_id);

-- report a list of actors who play in comedies and then, the number of actors for each nationality playing in comedies.
SELECT *
FROM actors as a
WHERE EXISTS
	(SELECT *
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id);
	 
SELECT a.nationality, COUNT(*) -- Report the nationality and the number of actors for each nationality
FROM actors AS a
WHERE EXISTS
	(SELECT ai.actor_id
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id)
GROUP BY a.nationality
ORDER BY 2 DESC;

-- Identify actors who are not from the USA and actors who were born after 1990.

SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'
INTERSECT -- Select all actors who are not from the USA and who are also born after 1990
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;

SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'
UNION -- Select all actors who are not from the USA and all actors who are born after 1990
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;

-- Make a list of all movies that are in the drama genre and have an average rating higher than 9.
SELECT *
FROM movies
WHERE movie_id IN -- Select all movies of genre drama with average rating higher than 9
   (SELECT movie_id
    FROM movies
    WHERE genre = 'Drama'
    INTERSECT
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING AVG(rating)>9);