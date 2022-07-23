-- Active: 1650155458576@@localhost@3306@medals

-- how to fetch values from different parts of the table into one row.

-- RELATIVE
-- LAG(column, n ) returns column's value at the row n rows before the current row
-- LEAD(column, n ) returns column's value at the row n rows after the current row

-- ABSOLUTE ( what they return isn't dependent on the current row,)
-- FIRST_VALUE(column) returns the first value in the table or partition
-- LAST_VALUE(column) returns the last value in the table or partition


-- LEAD

--  returns the cities in which each set of Olympic Games was held, as well as the next two cities. 

WITH Hosts AS (
    SELECT DISTINCT Year, City 
    FROM summer)
SELECT Year, City,
    LEAD(City, 1) OVER (ORDER BY Year ASC) AS Next_City,
    LEAD(City, 2) OVER (ORDER BY Year ASC) AS After_Next_City
FROM Hosts
ORDER BY Year ASC;

-- get the first and last cities in which the Olympic Games were held in this table.

WITH Hosts AS (
    SELECT DISTINCT Year, City 
    FROM summer)
SELECT Year, City, 
    FIRST_VALUE(City) OVER (ORDER BY Year ASC) AS First_City,
    LAST_VALUE(City) OVER 
        (ORDER BY Year ASC RANGE BETWEEN
            UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Last_City
FROM Hosts
ORDER BY Year ASC;

-- NOTE: By default a window starts at the beggining of the table or partition and ends at the current row
-- therefore is important to specify that we want the last value of the entire table

-- RANGE BETWEEN clause extends the window to the end of the table or partition

-- get next champion by event
WITH discus_gold AS (
    SELECT 
        Year,
        Event, 
        Country AS Champion
    FROM summer
    WHERE Event IN ('Discus Throw', 'Triple Jump')  
        AND Medal = 'Gold'
        AND Gender = 'Men') 
SELECT 
    Year, Event, Champion, 
    LEAD(Champion, 1)
        OVER(PARTITION BY Event
            ORDER BY Event ASC, Year ASC) AS Next_Champion
FROM discus_gold
ORDER BY Event ASC, Year ASC;


-- compare to the first champion by event 
WITH discus_gold AS (
    SELECT 
        Year,
        Event, 
        Country AS Champion
    FROM summer
    WHERE Event IN ('Discus Throw', 'Triple Jump')  
        AND Medal = 'Gold'
        AND Gender = 'Men') 
SELECT 
    Year, Event, Champion, 
    FIRST_VALUE(Champion)
        OVER(PARTITION BY Event
            ORDER BY Event ASC, Year ASC) AS First_Champion
FROM discus_gold
ORDER BY Event ASC, Year ASC;


-- For each year, fetch the current gold medalist and the gold medalist 3 competitions ahead of the current row.

WITH Discus_Medalists AS (
  SELECT DISTINCT
    Year,
    Athlete
  FROM summer
  WHERE Medal = 'Gold'
    AND Event = 'Discus Throw'
    AND Gender = 'Men'
    -- AND Year >= 2000
)
SELECT
  Year,
  Athlete,
  LEAD(Athlete, 3) OVER (ORDER BY Year ASC) AS Future_Champion
FROM Discus_Medalists
ORDER BY Year ASC;


-- RANKINGS

-- ROW_NUMBER always assigns unique numbers, even if two rows' values are the same; it chooses some other metric 
-- to assign numbers if the value by which it's ordering is the same.

-- RANK assigns the same number to rows with identical values, skipping over the next numbers in such cases. 
-- DENSE_RANK also assigns the same number to rows with identical values, but doesn't skip over the next numbers.


--  returns the number of Olympic games in which each of these countries has participated. 

CREATE TEMPORARY TABLE Country_Games AS (
    SELECT Country, COUNT(DISTINCT Year) AS Games 
    FROM summer
    WHERE Country IN ('GBR', 'ITA', 'DEN', 'FRA', 'AUT', 'BEL', 'NOR', 'POL', 'ESP', 'USA')
    GROUP BY Country
    ORDER BY Games DESC
);

-- Different ranking functions

SELECT Country, Games,
    ROW_NUMBER() OVER (ORDER BY Games DESC) AS Row_N,
    RANK() OVER (ORDER BY Games DESC) AS Rank_N,
    DENSE_RANK() OVER (ORDER BY Games DESC) AS Dense_Rank_N
FROM Country_Games
ORDER BY Games DESC, Country ASC;

-- rank Athletes sorted by medals earned from two countries 

WITH Country_Medals AS (
    SELECT Country, Athlete, COUNT(*) AS Medals
    FROM summer
    WHERE Country IN ('USA', 'GBR')
    GROUP BY Country, Athlete
    HAVING COUNT(*) > 1
    ORDER BY Country ASC, MEDALS DESC
)
SELECT Country, Athlete, 
    DENSE_RANK() OVER 
        (PARTITION BY Country ORDER BY Medals DESC) AS Rank_N
FROM Country_Medals
ORDER BY Country ASC, Medals DESC;


-- Rank each athlete by the number of medals they've earned -- the higher the count, the higher the rank 

WITH Athlete_Medals AS (
  SELECT
    Athlete,
    COUNT(*) AS Medals
  FROM summer
  GROUP BY Athlete)

SELECT
  Athlete,
  Medals,
  -- Rank athletes by the medals they've won
  RANK() OVER (ORDER BY medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Medals DESC;


-- Rank each country's athletes by the count of medals they've earned -- the higher the count, the higher the rank

WITH Athlete_Medals AS (
  SELECT
    Country, Athlete, COUNT(*) AS Medals
  FROM summer
  WHERE
    Country IN ('GER', 'FRA')
    -- AND Year >= 2000
  GROUP BY Country, Athlete
  HAVING COUNT(*) > 1)

SELECT
  Country,
  -- Rank athletes in each country by the medals they've won
  Athlete,
  DENSE_RANK() OVER (PARTITION BY Country
                ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Country ASC, RANK_N ASC;


-- PAGING 
-- Paging is splitting data into (approximately) equal chunks. How do you paginate data in SQL? 

-- NTILE is a window function that takes as input n, then splits the data into n approximately equal pages. 

WITH Disciplines AS (
    SELECT 
        DISTINCT Discipline 
    FROM summer
)
SELECT Discipline, NTILE(10) OVER() AS Page
FROM Disciplines
ORDER BY Page ASC;

-- Another use for NTILE is to split the data into thirds or quartiles

WITH Country_Medals AS (
    SELECT Country, COUNT(*) AS Medals
    FROM summer
    GROUP BY Country
)
SELECT Country, Medals,
    NTILE(3) OVER(ORDER BY Medals DESC) AS Third
FROM Country_Medals;

-- the query's results will be split into thirds, with the top 33% of countries by medals awarded in the top 
-- third (with the Third column's value being 1), the middle 33% in the middle third (with the Third column's 
-- value being 2), and the bottom 33% in the bottom third (with the Third column's value being 3)

-- THIRD AVERAGES

WITH Country_Medals AS (
    SELECT Country, COUNT(*) AS Medals
    FROM summer
    GROUP BY Country
), 
Thirds AS (
    SELECT Country, Medals,
    NTILE(3) OVER(ORDER BY Medals DESC) AS Third
    FROM Country_Medals
)
SELECT Third, 
    ROUND(AVG(Medals), 2) AS Avg_Medals
FROM Thirds
GROUP BY Third
ORDER BY Third ASC;


-- Split the distinct events into exactly 111 groups, ordered by event in alphabetical order.

WITH Events AS (
  SELECT DISTINCT Event
  FROM summer)
SELECT
  --- Split up the distinct events into 111 unique groups
  Event,
  NTILE(111) OVER (ORDER BY Event ASC) AS Page
FROM Events
ORDER BY Event ASC;


-- Split the athletes into top, middle, and bottom thirds based on their count of medals.

WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM summer
  GROUP BY Athlete
  HAVING COUNT(*) > 1)
SELECT
  Athlete,
  Medals,
  -- Split athletes into thirds by their earned medals
  NTILE(3) OVER(ORDER BY Medals DESC) AS Third
FROM Athlete_Medals
ORDER BY Medals DESC, Athlete ASC;

-- 

WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM summer
  GROUP BY Athlete
  HAVING COUNT(*) > 1),
  Thirds AS (
  SELECT
    Athlete,
    Medals,
    NTILE(3) OVER (ORDER BY Medals DESC) AS Third
  FROM Athlete_Medals)
SELECT
  -- Get the average medals earned in each third
  Third,
  AVG(Medals) AS Avg_Medals
FROM Thirds
GROUP BY Third
ORDER BY Third ASC;