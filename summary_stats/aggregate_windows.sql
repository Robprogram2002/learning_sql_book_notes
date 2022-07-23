CREATE TEMP TABLE IF NOT EXISTS Brazil_Medals AS (
	SELECT Year, COUNT(*) AS Medals
	FROM public.events
	WHERE Country = 'BRA' 
		AND Medal = 'Gold'
		AND Year >= 1992
	GROUP BY Year
	ORDER BY Year ASC
);

-- You can use both MAX and SUM, as well as the other aggregate functions COUNT, MIN, and AVG, as window functions

SELECT SUM(Medals) AS Total_Medals
FROM Brazil_Medals;

-- using MAX on the Medals column and defining a window ordered by year in ascending order will show the 
-- max medals earned so far for each row

SELECT Year, Medals, 
	MAX(Medals) OVER(ORDER BY YEAR ASC) AS Max_Medals
FROM Brazil_Medals;

-- With the same window that was defined for MAX used for SUM, SUM calculates 
-- the cumulative sum, or running total, of the medals earned so far

SELECT Year, Medals, 
	SUM(Medals) OVER(ORDER BY YEAR ASC) AS Medals_RT
FROM Brazil_Medals;

-- Just like any other window function, you can partition with aggregate functions.

WITH Medals AS (
	SELECT Year, Country, COUNT(*) AS Medals
	FROM public.events
	WHERE Country IN ('BRA', 'CUB') 
		AND Medal = 'Gold'
		AND Year >= 1992
	GROUP BY Year, Country
	ORDER BY Year ASC)
SELECT Year, Country, Medals, 
	SUM(Medals) OVER(PARTITION BY Country 
					 ORDER BY Year ASC) AS Medals_RT
FROM medals;

-- Running totals of athlete medals

WITH Athlete_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM public.events
  WHERE
    Country = 'USA' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)

SELECT
  -- Calculate the running total of athlete medals
  Athlete,
  Medals,
  SUM(Medals) OVER (ORDER BY Athlete ASC) AS Medals_RT
FROM Athlete_Medals
ORDER BY Athlete ASC;

-- Maximum country medals by year
-- Return the year, country, medals, and the maximum/minimum medals earned so far for 
-- each country, ordered by year in ascending order.

WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM public.events
  WHERE
    Country IN ('CHN', 'KOR', 'JPN')
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year, Country)
SELECT
  Year,
  Country,
  Medals,
  MAX(Medals) OVER (PARTITION BY Country
                ORDER BY Year ASC) AS Max_Medals,
  MIN(Medals) OVER (PARTITION BY Country
				   ORDER BY YEAR ASC) AS Min_Medals
FROM Country_Medals
ORDER BY Country ASC, Year ASC;

-- FRAMES 

-- With the PARTITION and ORDER subclauses, you can change the basis on which window functions operate. 
-- Another way to change a window function's behavior is to define a frame.

-- by default, a frame starts at the beginning of a table or partition and ends at the current row

-- The frame clause is used to customized it extends.
-- A frame always starts with RANGE BETWEEN or ROWS BETWEEN.
	-- ROWS BETWEEN [START] AND [FINISH]

-- Start and finish can be one of 3 clauses: PRECEDING, CURRENT ROW, and FOLLOWING

--  n PRECEDING defines the frame as either starting or finishing n rows before the current row. 
-- CURRENT ROW is to set the start or finish at the current row,
-- n following is to set it at n rows after the current row. 

WITH Russia_Medals AS (
	SELECT Year, COUNT(*) AS Medals
	FROM public.events
	WHERE Country = 'RUS' 
		AND Medal = 'Gold'
	GROUP BY Year
	ORDER BY Year ASC)
SELECT Year, Medals,
	MAX(Medals) OVER(ORDER BY Year ASC) AS Max_Medals,
	MAX(Medals) OVER(ORDER BY Year ASC 
					 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) 
					 AS Max_Medals_Last,
	MAX(Medals) OVER(ORDER BY Year ASC 
					 ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) 
					 AS Max_Medals_Next
FROM Russia_Medals
ORDER BY Year ASC;

-- Moving maximum of Scandinavian athletes' medals
-- Return the year, medals earned, and the maximum medals earned, comparing only the current year and the next year.

WITH Scandinavian_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM public.events
  WHERE
    Country IN ('DEN', 'NOR', 'FIN', 'SWE', 'ISL')
    AND Medal = 'Gold'
  GROUP BY Year)
SELECT
  -- Select each year's medals
  Year,
  Medals,
  -- Get the max of the current and next years'  medals
  MAX(Medals) OVER (ORDER BY Year ASC
             ROWS BETWEEN CURRENT ROW
             AND 1 FOLLOWING) AS Max_Medals
FROM Scandinavian_Medals
ORDER BY Year ASC;

-- Now for chinesse athletes

WITH Chinese_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM public.events
  WHERE
    Country = 'CHN' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)
SELECT
  -- Select the athletes and the medals they've earned
  Athlete,
  Medals,
  -- Get the max of the last two and current rows' medals 
  MAX(Medals) OVER (ORDER BY Athlete ASC
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW) AS Max_Medals
FROM Chinese_Medals
ORDER BY Athlete ASC;


--  A moving average is the average of the last n periods of a column's values.

-- in sales, the 10-day moving average is the average of the last ten days' units sold per day. It's used to indicate 
-- momentum and trends; if a day's units sold is higher than its moving average, then the next day, more units are 
-- likely to be sold. 

-- A moving total, on the other hand, is the sum of the last n periods of a column's values. 
-- It's used to indicate performance in the recent periods; if the sum is going down, overall performance is going down, 
-- and vice-versa.

-- US 3-MA: average of medals earned in the last two and the current sets of Olympic games for each year

WITH US_Medals AS (
	SELECT Year, COUNT(*) AS Medals
	FROM public.events
	WHERE Country = 'USA' 
	AND Medal = 'Gold'
	AND Year >= 1980
	GROUP BY Year
	ORDER BY Year ASC
)
SELECT Year, Medals, 
	ROUND(AVG(Medals) OVER (ORDER BY Year ASC 
					 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) 
					 AS Medals_MA	
FROM US_Medals
ORDER BY Year ASC;

-- US 3-MT

WITH US_Medals AS (
	SELECT Year, COUNT(*) AS Medals
	FROM public.events
	WHERE Country = 'USA' 
	AND Medal = 'Gold'
	AND Year >= 1980
	GROUP BY Year
	ORDER BY Year ASC
)
SELECT Year, Medals, 
	SUM(Medals) OVER (ORDER BY Year ASC 
					 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) 
					 AS Medals_MT	
FROM US_Medals
ORDER BY Year ASC;


-- ROWS vs RANGE

-- RANGE treats duplicates in the columns in the ORDER BY subclause as single entities, whereas ROWS does not.

-- They both arrive at the same cumulative sum, but how they get there is different. 
-- In practice, ROWS BETWEEN is almost always used over RANGE BETWEEN.

-- Moving average of Russian medals

WITH Russian_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM public.events
  WHERE
    Country = 'RUS'
    AND Medal = 'Gold'
    AND Year >= 1980
  GROUP BY Year)

SELECT
  Year, Medals,
  --- Calculate the 3-year moving average of medals earned
  AVG(Medals) OVER
    (ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Russian_Medals
ORDER BY Year ASC;

-- Calculate the 3-year moving sum of medals earned per country.

WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM public.events
  GROUP BY Year, Country)

SELECT
  Year, Country, Medals,
  -- Calculate each country's 3-game moving total
  SUM(Medals) OVER
    (PARTITION BY Country
     ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MT
FROM Country_Medals
ORDER BY Country ASC, Year ASC;

