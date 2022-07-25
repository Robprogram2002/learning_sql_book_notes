-- what's in the DB?
SELECT * FROM company LIMIT 5;

-- Select the count of the number of rows
SELECT COUNT(*) FROM fortune500;

-- Select the count of ticker, subtract from the total number of rows, 
SELECT count(*) - COUNT(ticker) AS missing
  FROM fortune500;
  
SELECT COUNT(*) - COUNT(profits_change) as missing
FROM fortune500;

SELECT COUNT(*) - COUNT(industry) as missing 
FROM fortune500;

SELECT company.name
  FROM company
       INNER JOIN fortune500
       ON company.ticker=fortune500.ticker;

-- Count the number of tags with each type
SELECT type, count(*) AS count
  FROM tag_type
 -- To get the count for each type, what do you need to do?
 GROUP BY type
 -- Order the results with the most common
 -- tag types listed first
 ORDER BY count DESC;
 
 -- Select the 3 columns desired
SELECT name, tag_type.tag, tag_type.type
  FROM company
  	   -- Join the tag_company and company tables
       INNER JOIN tag_company 
       ON company.id = tag_company.company_id
       -- Join the tag_type and company tables
       INNER JOIN tag_type
       ON tag_company.tag = tag_type.tag
  -- Filter to most common type
  WHERE type='cloud';
  

-- In the fortune500 data, industry contains some missing values. Use coalesce() to use the value of sector as the industry 
-- when industry is NULL. Then find the most common industry.

-- Use coalesce
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       -- Don't forget to count!
       count(*) 
  FROM fortune500 
-- Group by what? (What are you counting by?)
 GROUP BY industry2
-- Order results to see most common first
 ORDER BY count DESC
-- Limit results to get just the one value you want
 LIMIT 1;

-- Join company to itself to add information about a company's parent to the original company's information.
-- Use coalesce to get the parent company ticker if available and the original company ticker otherwise.

SELECT company_original.name, title, rank
  -- Start with original company information
  FROM company AS company_original
       -- Join to another copy of company with parent
       -- company information
	   LEFT JOIN company AS company_parent
       ON company_original.parent_id = company_parent.id 
       -- Join to fortune500, only keep rows that match
       INNER JOIN fortune500 
       -- Use parent ticker if there is one, 
       -- otherwise original ticker
       ON coalesce(company_parent.ticker, 
                   company_original.ticker) = 
             fortune500.ticker
 -- For clarity, order by rank
 ORDER BY rank; 
 