
	
-- Create a table with the total number of customers, of all female and male customers, 
-- of the number of customers for each country and the number of men and women from each country.

SELECT gender, -- Extract information of a pivot table of gender and country for the number of customers
	   country,
	   COUNT(customer_id)
FROM customers
GROUP BY CUBE (country, gender)
ORDER BY country, gender;

-- List the number of movies for different genres and the year of release on all aggregation levels 
SELECT genre,
       year_of_release,
       COUNT(*)
FROM movies
GROUP BY CUBE(genre, year_of_release)
ORDER BY year_of_release, genre;

-- Prepare a table for a report about the national preferences of the customers from MovieNow comparing the 
-- average rating of movies across countries and genres.

SELECT 
	c.country, 
	m.genre, 
	AVG(r.rating) AS avg_rating 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY CUBE(c.country, m.genre)
ORDER BY country, genre;

-- You are asked to study the preferences of genres across countries. Are there particular genres 
-- which are more popular in specific countries? Evaluate the preferences of customers by averaging 
-- their ratings and counting the number of movies rented from each genre.

SELECT 
	c.country, 
	m.genre, 
	AVG(r.rating) AS avg_rating, 
	COUNT(*) AS num_rating
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY ROLLUP(c.country, m.genre)
ORDER BY c.country, m.genre;


-- investigate the preference of customers for movies depending on the year the movie was released. 
-- produce a table to see if customers give better ratings to recent movies, and if there is a 
-- difference across countries.

SELECT c.country,
	m.year_of_release,
	COUNT(*) AS n_rentals,
	COUNT(DISTINCT r.movie_id) AS n_movies,
	AVG(rating) AS avg_rating
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN 
	(SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 4)
	AND r.date_renting >= '2018-04-01'
GROUP BY ROLLUP (m.year_of_release, c.country)
ORDER BY c.country, m.year_of_release;

--  Now the management considers investing money in movies of the best rated genres.
SELECT genre,
	   AVG(rating) AS avg_rating,
	   COUNT(rating) AS n_rating,
       COUNT(*) AS n_rentals,     
	   COUNT(DISTINCT m.movie_id) AS n_movies 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 3 )
AND r.date_renting >= '2018-01-01'
GROUP BY genre
ORDER BY avg_rating DESC;

-- The last aspect you have to analyze are customer preferences for certain actors.

SELECT a.nationality,
       a.gender,
	   AVG(r.rating) AS avg_rating,
	   COUNT(r.rating) AS n_rating,
	   COUNT(*) AS n_rentals,
	   COUNT(DISTINCT a.actor_id) AS n_actors
FROM renting AS r
LEFT JOIN actsin AS ai
ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
ON ai.actor_id = a.actor_id
WHERE r.movie_id IN ( 
	SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(rating) >= 4)
AND r.date_renting >= '2018-04-01'
GROUP BY CUBE(a.nationality, a.gender)
ORDER BY a.nationality, a.gender; 
