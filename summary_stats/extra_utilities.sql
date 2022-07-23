
-- PIVOTING 

-- Pivoting transforms a table by making columns out of the unique values of one of its columns. 

-- How do you do this in SQL, though?
-- CROSSTAB allows you to pivot a table by a certain column. You'll need to use the CREATE EXTENSION 
-- statement before using CROSSTAB. CREATE EXTENSION makes extra functions in an extension available 
-- for use. The tablefunc extension contains the CROSSTAB function.

-- Create the correct extention to enable CROSSTAB
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  SELECT
    Gender, Year, Country
  FROM public.events
  WHERE
    Year IN (2008, 2012)
    AND Medal = 'Gold'
    AND Event = 'Gymnastics'
  ORDER By Gender ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Gender VARCHAR,
           "2008" VARCHAR,
           "2012" VARCHAR)

ORDER BY Gender ASC;

-- pivoting with ranking

SELECT * FROM CROSSTAB($$
  WITH Country_Awards AS (
    SELECT
      Country,
      Year,
      COUNT(*) AS Awards
    FROM public.events
    WHERE
      Country IN ('FRA', 'GBR', 'GER')
      AND Year IN (2004, 2008, 2012)
      AND Medal = 'Gold'
    GROUP BY Country, Year)
  SELECT
    Country,
    Year,
    RANK() OVER
      (PARTITION BY Year
       ORDER BY Awards DESC) :: INTEGER AS rank
  FROM Country_Awards
  ORDER BY Country ASC, Year ASC;
$$) AS ct (Country VARCHAR,
           "2004" INTEGER,
           "2008" INTEGER,
           "2012" INTEGER)
Order by Country ASC;


-- CUBE AND ROLL UP

--  ROLLUP is a GROUP BY subclause that includes extra rows for group-level aggregations.

-- ROLLUP is hierarchical; the order of the columns in the ROLLUP clause affects the output. If you ROLLUP Country 
-- then Medal, you'll get Country-level totals, but if you reverse the columns, you'll get Medal-level totals.

SELECT 
	Country, Medal, COUNT(*) AS Awards
FROM public.events
WHERE Year = 2008
	AND Country IN ('CHN', 'RUS')
GROUP BY ROLLUP(Country, Medal)
ORDER BY Country ASC, Medal ASC;

-- CUBE is much like its cousin ROLLUP, except that it's not hierarchical. It generates all possible group-level aggregations. 
-- CUBE-ing Country and Medal counts Country-level, Medal-level, and grand totals.

SELECT 
	Country, Medal, COUNT(*) AS Awards
FROM public.events
WHERE Year = 2008
	AND Country IN ('CHN', 'RUS')
GROUP BY CUBE(Country, Medal)
ORDER BY Country ASC, Medal ASC;

-- ROLLUP VS CUBE
-- use ROLLUP when you have hierarchical data in your columns, such as date parts, because in such cases, only some 
-- group-level aggregations make sense. Use CUBE when you want all possible group-level aggregations.


-- Count the gold medals awarded per country and gender.
SELECT
  Country,
  Gender,
  COUNT(*) AS Gold_Awards
FROM public.events
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
GROUP BY ROLLUP(Country, Gender)
ORDER BY Country ASC, Gender ASC;

-- Count the medals per gender and medal type
SELECT
  Gender,
  Medal,
  Count(*) AS Awards
FROM public.events
WHERE
  Year = 2012
  AND Country = 'RUS'
-- Get all possible group-level subtotals
GROUP BY CUBE(Gender, Medal)
ORDER BY Gender ASC, Medal ASC;

--  What if you want to replace the nulls with something that actually indicates that these rows are group totals?

-- COALESCE takes a list of values and returns the first non-null value, going from left to right. COALESCE is 
-- useful when using SQL operations that return nulls, such as ROLLUP and CUBE. Other operations that return nulls are pivoting 
--  and positional operations like LAG, which always returns a null for the first row, because it has no previous row.


-- In the previous queries The Country column is null when it's the grand total, so the string should be Both countries, 
-- whereas the Medal column is null when it's the count of all medals, so it should be All medals.
SELECT
  COALESCE(Country, 'Both countries') AS Country ,
  COALESCE(Medal, 'All Medals') AS Medal,
  Count(*) AS Awards
FROM public.events
WHERE
  Year = 2008
  AND Country IN ('CHN', 'RUS')
GROUP BY CUBE(Country, Medal)
ORDER BY Country ASC, Medal ASC;

--  How can you compress data in SQL?

-- STRING_AGG takes all the values of a column and concatenates them, with a separator in between each value. 
-- STRING_AGG is useful when you need to reduce the number of rows returned.

WITH Country_Medals AS (
	SELECT Country, COUNT(*) AS Medals
	FROM public.events
	WHERE Year = 2012
		AND Country IN ('CHN', 'RUS', 'USA')
		AND Medal = 'Gold'
		AND Sport = 'Gymnastics'
	GROUP BY Country
), Country_Rank AS (
	SELECT Country, 
		RANK() OVER (ORDER BY Medals DESC) AS Rank
	FROM Country_Medals
	ORDER BY Rank ASC
)
SELECT STRING_AGG(Country, ', ')
FROM Country_Rank;

-- Return the top 3 countries by medals awarded on 2000
WITH Country_Medals AS (
  SELECT
    Country,
    COUNT(*) AS Medals
  FROM public.events
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country),

  Country_Ranks AS (
  SELECT
    Country,
    RANK() OVER (ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC)

-- Compress the countries column
SELECT STRING_AGG(Country, ', ')
FROM Country_Ranks
-- Select only the top three ranks
WHERE Rank <= 3;