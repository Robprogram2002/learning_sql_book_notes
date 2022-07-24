-- string concatenation operator

SELECT first_name, last_name, 
	first_name || ' ' || last_name AS full_name
FROM customer;

SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM customer;

-- we can concatened non-string values
SELECT (customer_id || ': ' || first_name || ' ' || last_name) AS full_name
FROM customer;

-- changing the style of the text
SELECT UPPER(title), LOWER(title), INITCAP(title) FROM film;

-- replace characters in a string
SELECT 
	REPLACE(description, 'A Astounding', 'An Astounding') AS description
FROM film;

-- reversing the text

SELECT title, REVERSE(title) FROM film;

-- Concatenate the first_name and last_name and email 
SELECT first_name || ' ' || last_name || ' <' || email || '>' AS full_email 
FROM customer;

SELECT 
  -- Concatenate the category name to coverted to uppercase
  -- to the film title converted to title case
  UPPER(c.name)  || ': ' || INITCAP(title) AS film_category, 
  -- Convert the description column to lowercase
  LOWER(description) AS description
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;


  -- Replace whitespace in the film title with an underscore
SELECT 
  REPLACE(title, ' ', '_') AS title
FROM film; 

-- determinig the length of a string
SELECT title, LENGTH(title) ,CHAR_LENGTH(title) FROM film;

-- finding the position of a character
SELECT email, STRPOS(email, '@'), POSITION('@' IN email) FROM customer;

-- parsing string data
SELECT LEFT(description, 50), RIGHT(description, 50) FROM film;

-- extracting substrings
SELECT SUBSTRING(description, 10, 50), SUBSTR(description, 10, 50) FROM film;

SELECT SUBSTRING(email FROM 0 FOR POSITION('@' IN email)) FROM customer;
SELECT SUBSTRING(email FROM POSITION('@' IN email)+1 FOR LENGTH(email)) FROM customer;

SELECT 
  -- Select the title and description columns
  title,
  description,
  -- Determine the length of the description column
  LENGTH(description) AS desc_len
FROM film;


-- Extract only the street address without the street number from the address column.
SELECT 
  -- Select only the street name from the address table
  SUBSTRING(address FROM POSITION(' ' IN address)+1 FOR LENGTH(address))
FROM address;
  
SELECT
  -- Extract the characters to the left of the '@'
  LEFT(email, POSITION('@' IN email)-1) AS username,
  -- Extract the characters to the right of the '@'
  SUBSTRING(email FROM POSITION('@' IN email)+1 FOR LENGTH(email)) AS domain
FROM customer;

-- Removing characters from a string
	-- TRIM([leading | trailing | both] [characters] from string)
	
-- default behavior is [both] and [' ']
SELECT TRIM('  padded  '), LTRIM('  padded  '), RTRIM('  padded  ');

-- padding 
SELECT LPAD('padded', 10, '#'), RPAD('padded', 10, '#');

-- Concatenate the first_name and last_name 
SELECT 
	RPAD(first_name, LENGTH(first_name)+1) 
    || RPAD(last_name, LENGTH(last_name)+2, ' <') 
    || RPAD(email, LENGTH(email)+1, '>') AS full_email
FROM customer; 

-- Concatenate the uppercase category name and film title
SELECT 
  CONCAT(UPPER(c.name), ': ', f.title) AS film_category, 
  -- Truncate the description remove trailing whitespace
  TRIM(LEFT(description, 50)) AS film_desc
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;
	
SELECT 
  UPPER(c.name) || ': ' || f.title AS film_category, 
  -- Truncate the description without cutting off a word
  LEFT(description, 50 - 
    -- Subtract the position of the first whitespace character
    POSITION(
      ' ' IN REVERSE(LEFT(description, 50))
    )
  ) 
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;