-- Active: 1650155458576@@localhost@3306@medals

-- The Summer Olympics dataset contains the results of the games between 1896 and 2012.


-- Row numbers allow you to reference a row by its position or index 
-- as opposed to its values

SELECT Year, Event, Country, 
    ROW_NUMBER() OVER() AS Row_N      -- The OVER clause indicates that it's a window function
FROM summer 
WHERE Medal = 'Gold';


-- Two ways of generate the same output

SELECT
  *,
  COUNT(Athlete) OVER(ROWS BETWEEN 
    UNBOUNDED PRECEDING AND CURRENT ROW) AS Row_N
FROM summer
ORDER BY Row_N ASC;

-- and

SELECT
  *,
  ROW_NUMBER() OVER() AS Row_N
FROM summer
ORDER BY Row_N ASC;


-- Assign a number to each year in which Summer Olympic games were held.
-- in which year the 13th Summer Olympics were held? 

SELECT
  Year,
  ROW_NUMBER() OVER() AS Row_N
FROM summer
GROUP BY Year
ORDER BY Year ASC;

-- ORDER BY is a subclause of OVER. It orders the rows related to the current row that the 
-- window function will use. Taking the row numbering query, if you order by year in descending 
-- order within the OVER clause, the function will assign 1 to the first row in that window.

SELECT Year, Event, Country, 
    ROW_NUMBER() OVER(ORDER BY Year DESC) AS Row_N      
FROM summer 
WHERE Medal = 'Gold';

-- using multiple columns

SELECT Year, Event, Country, 
    ROW_NUMBER() OVER(ORDER BY Year DESC, Event ASC) AS Row_N      
FROM summer 
WHERE Medal = 'Gold';

-- You can ORDER both inside and outside OVER at the same time.
-- the ORDER inside OVER takes effect before the ORDER outside of it.

SELECT Year, Event, Country, 
    ROW_NUMBER() OVER(ORDER BY Year DESC, Event ASC) AS Row_N      
FROM summer 
WHERE Medal = 'Gold'
ORDER BY Country ASC, Row_N ASC;

-- First, ROW_NUMBER will assign numbers based on the order within OVER. So the row numbers are given 
-- after sorting the table by year and event. After that, the ORDER outside of OVER takes over, and 
-- sorts the results of the table by Country and row number.

-------------------------------------------------

-- A reigning champion is a champion who's won both the previous and current years' competitions. 
-- To determine if a champion is a reigning champion, the previous and the current years' champions 
-- need to be in the same row,

-- LAG is a window function that takes a column and a number n and returns the column's value n 
-- rows before the current row. Passing 1 as n returns the previous row's value.

WITH discus_gold AS (
    SELECT Year, Country AS Champion
    FROM summer
    WHERE Event = 'Discus Throw' 
        AND Medal = 'Gold'
        AND Gender = 'Men') 
SELECT Year, Champion, 
    LAG(Champion, 1) OVER(ORDER BY Year ASC) AS Last_Champion
FROM discus_gold
ORDER BY Year DESC;

-- Number Olympic games in descending order

SELECT
  Year,
  ROW_NUMBER() OVER 
    (ORDER BY Year DESC) AS Row_N
FROM 
    (SELECT DISTINCT Year 
    FROM summer) AS Years
ORDER BY Year;

-- Numbering Olympic athletes by medals earned

WITH athlete_medals AS (
  SELECT
    -- Count the number of medals each athlete has earned
    Athlete,
    COUNT(*) AS Medals
  FROM summer
  GROUP BY Athlete)
SELECT
  -- Number each athlete by how many medals they've earned
  Athlete,
  Medals,
  ROW_NUMBER() OVER (ORDER BY Medals DESC) AS Row_N
FROM athlete_medals
ORDER BY Medals DESC;

-- Reigning weightlifting champions

WITH Weightlifting_Gold AS (
  SELECT
    -- Return each year's champions' countries
    Year,
    Country AS champion
  FROM summer
  WHERE
    Discipline = 'Weightlifting' AND
    Event = '69KG' AND
    Gender = 'Men' AND
    Medal = 'Gold')

SELECT
  Year, Champion,
  -- Fetch the previous year's champion
  LAG(Champion, 1) OVER
    (ORDER BY Year ASC) AS Last_Champion
FROM Weightlifting_Gold
ORDER BY Year ASC;

-- How do you tell LAG to separate the champions from different events

-- PARTITION BY splits the table into partitions based on a column's unique values, similar to GROUP BY. 
-- Unlike GROUP BY, however, the results of a window function with PARTITION BY aren't rolled into one 
-- column. Partitions are operated on separately by the window function.

-- Adding PARTITION BY Event in the OVER clause before ORDER will separate the table

-- in this query the events are mixed: when Event changes from 'Discus Throw' to 'Triple Jump'
-- LAG fetched Discus Throw's last champion as opposed to null
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
    Year, 
    Event, 
    Champion, 
    LAG(Champion, 1)
        OVER(ORDER BY Event ASC, Year ASC) AS Last_Champion
FROM discus_gold
ORDER BY Event ASC, Year ASC;

-- correct way

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
    LAG(Champion, 1)
        OVER(PARTITION BY Event
            ORDER BY Event ASC, Year ASC) AS Last_Champion
FROM discus_gold
ORDER BY Event ASC, Year ASC;

-- row numbering of Chinese and Japanese gold medals awarded to women. The row numbering extends across 
-- countries and events, and the goal is to reset it per country and year.

WITH Country_Gold AS (
    SELECT 
        DISTINCT Year, Country, Event
    FROM summer
    WHERE Country IN ('USA', 'FRA') AND 
        Medal = 'Gold'AND Gender = 'Women') 
SELECT 
    Year, Country, Event, 
    ROW_NUMBER() OVER(PARTITION BY Year, Country) AS Row_N
FROM Country_Gold
ORDER BY Year DESC;

-- Reigning champions by gender: Return the previous champions of each year's event by gender.

WITH Tennis_Gold AS (
  SELECT DISTINCT
    Gender, Year, Country
  FROM summer
  WHERE
    -- Year >= 2000 AND
    Event = 'Javelin Throw' AND
    Medal = 'Gold')
SELECT
  Gender, Year,
  Country AS Champion,
  -- Fetch the previous year's champion by gender
  LAG(Country, 1) OVER (PARTITION BY Gender
            ORDER BY Year ASC) AS Last_Champion
FROM Tennis_Gold
ORDER BY Gender ASC, Year ASC;

-- Reigning champions by gender and event: Return the previous champions of each year's events by gender and event.

WITH Athletics_Gold AS (
  SELECT DISTINCT
    Gender, Year, Event, Country
  FROM summer
  WHERE
    -- Year >= 2000 AND
    Discipline = 'Athletics' AND
    Event IN ('100M', '10000M') AND
    Medal = 'Gold')

SELECT
  Gender, Year, Event,
  Country AS Champion,
  -- Fetch the previous year's champion by gender and event
  LAG(Country) OVER (PARTITION BY Gender, Event
            ORDER BY Year ASC) AS Last_Champion
FROM Athletics_Gold
ORDER BY Event ASC, Gender ASC, Year ASC;

