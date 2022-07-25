
-- get total number of movie rentals, the total number of ratings and the average rating of all movies since the beginning of 2019.

SELECT 
	COUNT(*) AS number_renting,
	AVG(rating) AS average_rating, 
	COUNT(rating) AS number_ratings -- Add the total number of ratings here.
FROM renting
WHERE date_renting >= '2019-01-01';

-- now for each movie
SELECT m.title, 
	m.movie_id, 
	mf.number_renting, 
	mf.average_rating, 
	mf.number_ratings 
FROM (
	SELECT 
		movie_id,	
		COUNT(*) AS number_renting,
		AVG(rating) AS average_rating, 
		COUNT(rating) AS number_ratings
	FROM renting
	WHERE date_renting >= '2019-01-01'
	GROUP BY movie_id
	HAVING COUNT(*) > 1) AS mf
LEFT JOIN movies AS m
ON mf.movie_Id = m.movie_id
ORDER BY 3 DESC;

-- now for each customer
SELECT c.name, 
	c.customer_id,
	cif.n_renting,
	cif.avg_rating,
	cif.n_rating
FROM (
	SELECT customer_id, 
      AVG(rating) AS avg_rating,
      COUNT(rating) AS n_rating,  
      COUNT(*) AS n_renting
	FROM renting
	GROUP BY customer_id
	HAVING COUNT(*) > 7 -- Select only customers with more than 7 movie rentals
) AS cif
LEFT JOIN customers AS c
ON c.customer_id = cif.customer_id
ORDER BY 3 DESC;

-- To evaluate the success and the potential of a company, it is often desirable to look at groups 
-- of customers or groups of products jointly. 

-- We could be interested in 
-- 	preferences of customers by country or gender 
-- 	the popularity of movies by genre or year of release.
-- 	the average price of movies by genre


-- when the first customer accounts were created for each country?

SELECT country, -- For each country report the earliest date when an account was created
	MIN(date_account_start) AS first_account
FROM customers
GROUP BY country
ORDER BY first_account;

-- Average ratings of customers from Belgium
SELECT AVG(r.rating) 
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
WHERE c.country='Belgium';

-- measure the financial successes as well as user engagement. Important KPIs are, therefore, 
-- the profit coming from movie rentals, the number of movie rentals and the number of active customers.

SELECT 
	SUM(m.renting_price) AS profit, 
	COUNT(*) AS rentals, 
	COUNT(DISTINCT r.customer_id) AS act_customers
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id
-- Only look at movie rentals in 2018
WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31' ;

-- give an overview of which actors play in which movie.
SELECT m.title, -- Create a list of movie titles and actor names
       a.name
FROM actsIn AS ai
LEFT JOIN movies AS m
ON m.movie_id = ai.movie_id
LEFT JOIN actors AS a
ON a.actor_id = ai.actor_id;

--  calculate how much money each customer spent on MovieNow rentals by using sub-queries.
SELECT rm.customer_id,
	SUM(rm.renting_price) AS spends
FROM (
	SELECT r.customer_id, m.renting_price
	FROM renting AS r 
	LEFT JOIN movies AS m
	ON r.movie_id = m.movie_id
) AS rm
GROUP BY rm.customer_id
ORDER BY spends DESC;

-- How much income did each movie generate? 

SELECT title, -- Report the income from movie rentals for each movie 
       SUM(renting_price) AS income_movie
FROM
       (SELECT m.title,  
               m.renting_price
       FROM renting AS r
       LEFT JOIN movies AS m
       ON r.movie_id=m.movie_id) AS rm
GROUP BY title
ORDER BY income_movie DESC;

-- Report the date of birth of the oldest and youngest US actor and actress.
SELECT a.gender,  
       MIN(a.year_of_birth), -- The year of birth of the oldest actor
       MAX(a.year_of_birth) -- The year of birth of the youngest actor
FROM
   (SELECT * 
   FROM actors 
   WHERE nationality = 'USA')
   AS a
GROUP BY 1;

-- explore What makes an actor the favorite actor?

-- 1. for each actor, count how often their movies are watched by male customers.
-- 2. and the average rating of movies wich he appears

SELECT a.name,
	COUNT(*) AS number_views,
	AVG(r.rating) AS avg_rating
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = r.customer_id
LEFT JOIN actsin AS ai
ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
ON ai.actor_id = a.actor_id
WHERE c.gender = 'male'
GROUP BY a.name
HAVING AVG(r.rating) IS NOT NULL
ORDER BY avg_rating DESC, number_views DESC;

-- Which is the favorite movie on MovieNow? Answer this question for a specific group of customers: 
-- for all customers born in the 70s.

SELECT m.title, 
COUNT(*),
AVG(r.rating)
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title
HAVING COUNT(*) > 1 AND AVG(r.rating) IS NOT NULL -- Remove movies with only one rental
ORDER BY 3 DESC; -- Order with highest rating first


-- Identify favorite actors for Spain

SELECT a.name,  c.gender,
       COUNT(*) AS number_views, 
       AVG(r.rating) AS avg_rating
FROM renting as r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
LEFT JOIN actsin as ai
ON r.movie_id = ai.movie_id
LEFT JOIN actors as a
ON ai.actor_id = a.actor_id
WHERE c.country = 'Spain' -- Select only customers from Spain
GROUP BY a.name, c.gender
HAVING AVG(r.rating) IS NOT NULL 
  AND COUNT(*) > 5 
ORDER BY avg_rating DESC, number_views DESC;

-- get total number of movie rentals, the average rating of all movies and the total revenue for each country since 
-- the beginning of 2019.

SELECT 
	c.country,                      -- For each country report
	COUNT(*) AS number_renting,   -- The number of movie rentals
	AVG(r.rating) AS average_rating,  -- The average rating
	SUM(m.renting_price) AS revenue  -- The revenue from movie rentals
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE date_renting >= '2019-01-01'
GROUP BY c.country
ORDER BY 2 DESC;

