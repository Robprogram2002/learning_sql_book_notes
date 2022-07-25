
 
--  ---------------------NUMERIC DATA TYPES

-- here are 10 different numeric data types. 

-- INTEGERS

-- The base type is called integer, which can be shortened to int. 
-- It allows whole numbers between approximately negative 2 billion and positive 2 billion.

-- There are also smallint and bigint types that have different ranges.
-- Serial types are used for integer columns that autoincrement. They are used to generate ID columns for 
-- data that doesn't already contain a unique identifier.

-- NUMERIC
-- -- There are also 3 decimal types with different levels of precision. 

-- Decimal and numeric are two names for the same type. They can store numbers with very high precision.
-- Real and double precision types can store numbers with less precision, meaning fewer digits in the number.

-- Select average revenue per employee by sector
SELECT sector, 
       AVG(revenues/employees::numeric) AS avg_rev_employee
  FROM fortune500
 GROUP BY sector
 -- Use the column alias to order the results
 ORDER BY avg_rev_employee;
 
 -- Divide unanswered_count by question_count
SELECT unanswered_count/question_count::numeric AS computed_pct, 
       -- What are you comparing the above quantity to?
       unanswered_pct
  FROM stackoverflow
 -- Select rows where question_count is not 0
 WHERE question_count > 0
 LIMIT 10;
 
 -- Select min, avg, max, and stddev of fortune500 profits
SELECT min(profits),
       avg(profits),
       max(profits),
       stddev(profits)
  FROM fortune500;
  
--   what is the standard deviation across tags in the maximum number of Stack Overflow questions per day? 
-- What about the mean, min, and max of the maximums as well?

-- Compute standard deviation of maximum values
SELECT 
       STDDEV(maxval),
       MIN(maxval),
	   -- min
       MAX(maxval),
       -- max
       AVG(maxval)
       -- avg
  -- Subquery to compute max of question_count by tag
  FROM (SELECT MAX(question_count) AS maxval
          FROM stackoverflow
         -- Compute max by...
         GROUP BY tag) AS max_results; -- alias for subquery
		 
-- Understanding the distribution of a variable is crucial for finding errors, outliers, and other anomalies in the data.

-- For columns with a small number of discrete values, we can view the distribution by counting the number of observations 
-- with each distinct value. We group by, and order the results by, the column of interest.

SELECT unanswered_count, COUNT(*) 
FROM stackoverflow
WHERE tag='amazon-ebs'
GROUP BY unanswered_count
ORDER BY unanswered_count;

-- Truncate employees
SELECT trunc(employees, -5) AS employee_bin,
       -- Count number of companies with each truncated value
       count(*)
  FROM fortune500
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;
 
 -- Truncate employees
SELECT trunc(employees, -4) AS employee_bin,
       -- Count number of companies with each truncated value
       count(*)
  FROM fortune500
 -- Limit to which companies?
 WHERE employees < 100000
 -- Use alias to group
 GROUP BY employee_bin
 -- Use alias to order
 ORDER BY employee_bin;
 
-- Summarize the distribution of the number of questions with the tag "dropbox" on Stack Overflow per day by binning the data.

-- Bins created in Step 2
WITH bins AS (
      SELECT generate_series(2200, 3050, 50) AS lower,
             generate_series(2250, 3100, 50) AS upper),
     -- Subset stackoverflow to just tag dropbox (Step 1)
     dropbox AS (
      SELECT question_count 
        FROM stackoverflow
       WHERE tag='dropbox') 
-- Select columns for result
-- What column are you counting to summarize?
SELECT lower, upper, count(question_count) 
  FROM bins  -- Created above
       -- Join to dropbox (created above), 
       -- keeping all rows from the bins table in the join
       LEFT JOIN dropbox
       -- Compare question_count to lower and upper
         ON question_count >= lower 
        AND question_count < upper
 -- Group by lower and upper to count values in each bin
 GROUP BY lower, upper
 -- Order by lower to put bins in order
 ORDER BY lower;
 
-- Compute the mean (avg()) and median assets of Fortune 500 companies by sector.
-- Use the percentile_disc() function to compute the median:

-- What groups are you computing statistics by?
SELECT sector, 
       -- Select the mean of assets with the avg function
       avg(assets) AS mean,
       -- Select the median
       percentile_disc(0.5) WITHIN GROUP (ORDER BY assets) AS median
  FROM fortune500
 -- Computing statistics for each what?
 GROUP BY sector
 -- Order results by a value of interest
 ORDER BY mean;
 
 -- Correlation between revenues and profit
SELECT corr(revenues, profits) AS rev_profits,
	   -- Correlation between revenues and assets
       corr(revenues, assets) AS rev_assets,
       -- Correlation between revenues and equity
       corr(revenues, equity) AS rev_equity 
  FROM fortune500;
  
-- Find the Fortune 500 companies that have profits in the top 20% for their sector (compared to other Fortune 500 companies).
-- and save the results in a temporary table.

-- Code from previous step
DROP TABLE IF EXISTS profit80;

CREATE TEMP TABLE profit80 AS
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    FROM fortune500 
   GROUP BY sector;

-- Select columns, aliasing as needed
SELECT title, fortune500.sector, 
       fortune500.profits, fortune500.profits/profit80.pct80 AS ratio
-- What tables do you need to join?  
  FROM fortune500 
       LEFT JOIN profit80
-- How are the tables joined?
       ON fortune500.sector= profit80.sector
-- What rows do you want to select?
 WHERE fortune500.profits > profit80.pct80;
 
--  The Stack Overflow data contains daily question counts through 
-- 2018-09-25 for all tags, but each tag has a different starting date in the data.

-- Find out how many questions had each tag on the first date for which data for the tag is available, as well as how many 
-- questions had the tag on the last day. Also, compute the difference between these two values.

-- To clear table if it already exists
DROP TABLE IF EXISTS startdates;

CREATE TEMP TABLE startdates AS
SELECT tag, min(date) AS mindate
  FROM stackoverflow
 GROUP BY tag;
 
-- Select tag (Remember the table name!) and mindate
SELECT startdates.tag, 
       mindate, 
       -- Select question count on the min and max days
	   so_min.question_count AS min_date_question_count,
       so_max.question_count AS max_date_question_count,
       -- Compute the change in question_count (max- min)
       so_max.question_count - so_min.question_count AS change
  FROM startdates
       -- Join startdates to stackoverflow with alias so_min
       INNER JOIN stackoverflow AS so_min
          -- What needs to match between tables?
          ON startdates.tag = so_min.tag
         AND startdates.mindate = so_min.date
       -- Join to stackoverflow again with alias so_max
       INNER JOIN stackoverflow AS so_max
       	  -- Again, what needs to match between tables?
          ON startdates.tag = so_max.tag
         AND so_max.date = '2018-09-25';

-- Insert into a temp table
-- Compute the correlations between each pair of profits, profits_change, and revenues_change from the Fortune 500 data.
-- 

DROP TABLE IF EXISTS correlations;

CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'profits_change'::varchar AS measure,
       corr(profits_change, profits) AS profits,
       corr(profits_change, profits_change) AS profits_change,
       corr(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       corr(revenues_change, profits) AS profits,
       corr(revenues_change, profits_change) AS profits_change,
       corr(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Select each column, rounding the correlations
SELECT measure, 
       round(profits::numeric, 2) AS profits,
       round(profits_change::numeric, 2) AS profits_change,
       round(revenues_change::numeric, 2) AS revenues_change
  FROM correlations;
