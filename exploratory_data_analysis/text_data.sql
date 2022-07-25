-- ----------------------------- CHARACTER DATA TYPES

-- Select the count of each level of priority
SELECT priority, COUNT(*)
  FROM evanston311
  GROUP BY priority;

-- Find values of zip that appear in at least 100 rows
-- Also get the count of each value
SELECT zip, COUNT(*)
  FROM evanston311
 GROUP BY zip
HAVING COUNT(*) >= 100; 

-- Find values of source that appear in at least 100 rows
-- Also get the count of each value
SELECT source, COUNT(*)
  FROM evanston311
 GROUP BY source
HAVING COUNT(*) >= 100;

-- Find the 5 most common values of street and the count of each
SELECT street, COUNT(*)
  FROM evanston311
 GROUP BY street
 ORDER BY 2 DESC
 LIMIT 5;
 
-- Trim digits 0-9, #, /, ., and spaces from the beginning and end of street.

SELECT distinct street,
       -- Trim off unwanted characters from street
       trim(street, '0123456789 #/.') AS cleaned_street
  FROM evanston311
 ORDER BY street;
 
-- Use ILIKE to count rows in evanston311 where the description contains 'trash' or 'garbage' regardless of case.

-- Count rows
SELECT COUNT(*)
  FROM evanston311
 -- Where description includes trash or garbage
 WHERE description ILIKE '%trash%'
    OR description ILIKE '%garbage%';

-- category values are in title case. Use LIKE to find category values with 'Trash' or 'Garbage' in them.

-- Select categories containing Trash or Garbage
SELECT category
  FROM evanston311
 -- Use LIKE
 WHERE category LIKE '%Trash%'
    OR category LIKE '%Garbage%';
	
-- Count rows
SELECT COUNT(*)
  FROM evanston311 
 -- description contains trash or garbage (any case)
 WHERE (description ILIKE '%trash%'
    OR description ILIKE '%garbage%') 
 -- category does not contain Trash or Garbage
   AND category NOT LIKE '%Trash%'
   AND category NOT LIKE '%Garbage%';
   
-- Find the most common categories for rows with a description about trash that don't have a trash-related category.

-- Count rows with each category
SELECT category, count(*)
  FROM evanston311 
 WHERE (description ILIKE '%trash%'
    OR description ILIKE '%garbage%') 
   AND category NOT LIKE '%Trash%'
   AND category NOT LIKE '%Garbage%'
 -- What are you counting?
 GROUP BY category
 --- order by most frequent values
 ORDER BY count DESC
 LIMIT 10;
 
 -- Concatenate house_num, a space, and street
-- and trim spaces from the start of the result
SELECT LTRIM(CONCAT(house_num, ' ', street)) AS address
  FROM evanston311;
  
-- Select the first word of the street value
SELECT split_part(street, ' ', 1) AS street_name, 
       count(*)
  FROM evanston311
 GROUP BY street_name
 ORDER BY count DESC
 LIMIT 20;
 
-- Select the first 50 chars when length is greater than 50
SELECT CASE WHEN length(description) > 50
            THEN LEFT(description, 50) || '...'
       -- otherwise just select description
       ELSE description
       END
  FROM evanston311
 -- limit to descriptions that start with the word I
 WHERE description LIKE 'I %'
 ORDER BY description;
 

-- Group and recode values
-- There are almost 150 distinct values of evanston311.category. But some of these categories are similar, with the form "Main Category - Details". 
-- We can get a better sense of what requests are common if we aggregate by the main category.
-- To do this, create a temporary table recode mapping distinct category values to new, standardized values. Make the standardized values 
-- the part of the category before a dash ('-').

-- You'll also need to do some additional cleanup of a few cases that don't fit this pattern.

-- Then the evanston311 table can be joined to recode to group requests by the new standardized category values.

DROP TABLE IF EXISTS recode;
CREATE TEMP TABLE recode AS
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
  FROM evanston311;
UPDATE recode SET standardized='Trash Cart' 
 WHERE standardized LIKE 'Trash%Cart';
UPDATE recode SET standardized='Snow Removal' 
 WHERE standardized LIKE 'Snow%Removal%';
UPDATE recode SET standardized='UNUSED' 
 WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart', 
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash', 'NO LONGER IN USE');

-- Select the recoded categories and the count of each
SELECT standardized, COUNT(*)
-- From the original table and table with recoded values
  FROM evanston311 
       LEFT JOIN recode 
       -- What column do they have in common?
       ON evanston311.category = recode.category 
 -- What do you need to group by to count?
 GROUP BY standardized
 -- Display the most common val values first
 ORDER BY count(*) desc;


-- Determine whether medium and high priority requests in the evanston311 data are more likely to contain requesters' 
-- contact information: an email address or phone number.

-- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the temp table
CREATE TEMP TABLE indicators AS
  SELECT id, 
         CAST (description LIKE '%@%' AS integer) AS email,
         CAST (description LIKE '%___-___-____%' AS integer) AS phone 
    FROM evanston311;

-- Select the column you'll group by
SELECT priority, 
       -- Compute the proportion of rows with each indicator
       sum(email)/count(*)::numeric AS email_prop, 
       sum(phone)/count(*)::numeric AS phone_prop 
  -- Tables to select from
  FROM evanston311
       LEFT JOIN indicators
       -- Joining condition
       ON evanston311.id=indicators.id
 -- What are you grouping by?
 GROUP BY priority;
