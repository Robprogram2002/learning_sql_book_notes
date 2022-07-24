-- LIKE operator

SELECT title 
FROM film
WHERE title LIKE '%ELF';

SELECT title
FROM film
WHERE title LIKE 'ELF%';

SELECT title
FROM film
WHERE title LIKE '%ELF%';


SELECT title
FROM film
WHERE title LIKE '%elf%';

-- The LIKE operator is case sensitive, is better to use a full-text search
-- Because full text search accounts for variations of the search string and is case insensitive 
-- notice that you get the expected results.
SELECT title , description FROM film 
WHERE to_tsvector(title) @@ to_tsquery('elf');

-- Full text search provides a means for performing natural language queries of text data by using stemming, 
-- fuzzy string matching to handle spelling mistakes and a mechanism to rank results by similarity to the search string.

-- Select the film description as a tsvector
SELECT to_tsvector(description)
FROM film;

-- PostgreSQL also provides you with the ability to create your own custom data types, functions and operators to 
-- extend the functionality of your database.

-- A user-defined data type is created using the CREATE TYPE command which registers the type in a system table 
-- and makes it available to be used anywhere PostgreSQL expects a type name. 

-- CREATE TYPE dateofweek AS ENUM (
-- 	'Monday', 
-- 	'Tuesday', 
-- 	'Wednesday',
-- 	'Thursday',
-- 	'Friday',
-- 	'Saturday',
-- 	'Sunday'
-- );

-- Once your custom data type has been created, you can query the system table called pg_type to get information 
-- about all data types available in your database both user-defined and built-in. 

SELECT typname, typcategory
FROM pg_type
WHERE typname = 'dateofweek';

-- You can also use the INFORMATION_SCHEMA system database, as we learned about earlier in this course, 
-- to get information about user-defined data types.

SELECT column_name, data_type, udt_name
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'film';

-- Another way to extend the capabilities of your PostgreSQL database is with user-defined functions. A user-defined 
-- function is the PostgeSQL equivalent of a stored procedure where you can bundle several SQL queries and statements 
-- together into a single package using the CREATE FUNCTION command

-- CREATE FUNCTION squared(i integer) RETURNS integer AS $$
-- 	BEGIN 
-- 		RETURN i * i;
-- 	END;
-- $$ LANGUAGE plpgsql;

SELECT squared(10);

-- chech the user-defined functions in the pagila DB



-- ---------------------
-- Create an enumerated data type, compass_position
-- CREATE TYPE compass_position AS ENUM (
--   	-- Use the four cardinal directions
--   	'North', 
--   	'South',
--   	'East', 
--   	'West'
-- );
-- Confirm the new data type is in the pg_type system table
SELECT *
FROM pg_type
WHERE typname='compass_position';

-- Select the column name, data type and udt name columns
SELECT column_name, data_type, udt_name
FROM INFORMATION_SCHEMA.COLUMNS 
-- Filter by the rating column in the film table
WHERE table_name ='film' AND column_name='rating';

SELECT *
FROM pg_type
WHERE typname='mpaa_rating';

-- using a user defined function
-- Select the film title and inventory ids
SELECT 
	f.title, 
    i.inventory_id,
    -- Determine whether the inventory is held by a customer
    inventory_held_by_customer(i.inventory_id) as held_by_cust
FROM film as f 
	INNER JOIN inventory AS i ON f.film_id=i.film_id 
WHERE
	-- Only include results where the held_by_cust is not null
    inventory_held_by_customer(i.inventory_id) IS NOT NULL;
	

-- COMMONLY USED EXTENSIONS
-- PostGIS
-- PostPic
-- fuzzystrmatch
-- pg_trgm

-- Most PostgreSQL distributions come bundled with a common set of widely used and supported extensions from 
-- the community that can be used by simply enabling them

-- PostGIS adds support for allowing location queries to be run in SQL. PostPic allows for image processing 
-- within the database. fuzzystrmatch and pg_trgm provide functions that extend full text search capabilities 
-- by finding similarities between strings.

-- determine a list of extensions that are available to be installed and enabled for use. 
SELECT name FROM pg_available_extensions;

-- A similar query of the pg_extension system table will tell you which extensions have already 
-- been enabled in your database and are currently available for your use.

SELECT extname FROM pg_extension;

-- Any of the extensions that are returned from the pg_available_extensions system view can be loaded 
-- into your database and enabled with a simple query using the CREATE EXTENSION command

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
SELECT extname FROM pg_extension;

-- When preforming a full text search based on user input or looking to perform an analysis and comparison 
-- of text data in a natural language processing exercise, a function that you will use often is levenshtein 
-- from the fuzzystrmatch extension. The levenshtein function calculates the levenshtein distance between two 
-- strings which is the number of edits required for the strings to be a perfect match.

SELECT levenshtein('GUMBO', 'GAMBOL');

-- The pg_trgm extension provides functions and operators to determine the similarity of two strings using trigram 
-- matchings. Trigrams are groups of 3 consecutive characters in a string and based on the number of matching 
-- trigrams in two strings will provide a measurement of how similar they are

-- The similarity function accepts two parameters; the first being the string you wish to compare and the second 
-- being the string you wish to compare against.

CREATE EXTENSION IF NOT EXISTS pg_trgm;

SELECT similarity('GUMBO', 'GAMBOL');

-- Select the title and description columns
SELECT 
  title, 
  description, 
  -- Calculate the similarity
  similarity(title, description)
FROM film;

-- Select the title and description columns
SELECT  
  title, 
  description, 
  -- Calculate the levenshtein distance
  levenshtein(title, 'JET NEIGHBOR') AS distance
FROM film
ORDER BY 3;

-- Select the title and description columns
SELECT 
  title, 
  description, 
  -- Calculate the similarity
  similarity(description, 'Astounding & Drama')
FROM 
  film 
WHERE 
  to_tsvector(description) @@ 
  to_tsquery('Astounding & Drama') 
ORDER BY 3 DESC;