-- Active: 1658280730769@@127.0.0.1@3306

-- Limitation: you have to group results when using aggregate functions and If you try to retrieve additional 
-- information without grouping by every single non-aggregate value, your query will return an error. 

-- Window functions are a class of functions that perform calculations on a result set that has already been 
-- generated, also referred to as a "window". You can use window functions to perform aggregate calculations 
-- without having to group your data,


-- The OVER() clause allows you to pass an aggregate function down a data set

SELECT 
	m.id, 
    c.name AS country, 
    m.season,
	m.home_team_goal,
	m.away_team_goal,
    -- Use a window to include the aggregate average in each row
	AVG(m.home_team_goal + m.away_team_goal) OVER() AS overall_avg
FROM Match AS m
LEFT JOIN Country AS c ON m.country_id = c.id;


-- The OVER() clause offers significant benefits over subqueries in select -- namely, your queries will run faster, 
-- and the OVER() clause has a wide range of additional functions and clauses you can include with it

-- Window functions allow you to create a RANK of information according to any variable you want to use to sort 
-- your data.

SELECT 
	-- Select the league name and average goals scored
	l.name AS league,
    AVG(m.home_team_goal + m.away_team_goal) AS avg_goals,
    -- Rank each league according to the average goals
    RANK() OVER(ORDER BY AVG(m.home_team_goal + m.away_team_goal) DESC) AS league_rank
FROM League AS l
LEFT JOIN Match AS m 
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
-- Order the query by the rank you created
ORDER BY league_rank;


-- One important statement you can add to your OVER clause is PARTITION BY. A partition allows you to calculate 
-- separate values for different categories established in a partition. This is one way to calculate different 
-- aggregate values within one column of data, 

-- How many goals were scored in each match, and how did that compare to the season's average?

SELECT 
    date, 
    (home_team_goal + away_team_goal) AS goals,
    AVG(home_team_goal + away_team_goal) OVER(PARTITION BY season) AS season_avg
FROM Match;

-- You can also use PARTITION to calculate values broken out by multiple columns

-- returns the average goals scored broken out by season and country. 

SELECT 
    c.name,
    m.date,
    m.season, 
    (home_team_goal + away_team_goal) AS goals,
    AVG(home_team_goal + away_team_goal) OVER(PARTITION BY m.season, c.name) AS season_ctry_avg
FROM Country AS c
LEFT JOIN Match AS m
    ON c.id = m.country_id;


-- create a data set of games played by Legia Warszawa (Warsaw League) and compare their individual game 
-- performance to the overall average for that season.

SELECT
	date,
	season,
	home_team_goal,
	away_team_goal,
	CASE WHEN home_team_api_id = 8673 THEN 'home' 
		 ELSE 'away' END AS warsaw_location,
    -- Calculate the average goals scored partitioned by season
    AVG(home_team_goal) OVER(PARTITION BY season) AS season_homeavg,
    AVG(away_team_goal) OVER(PARTITION BY season) AS season_awayavg
FROM Match
-- Filter the data set for Legia Warszawa matches only
WHERE 
	home_team_api_id = 8673 
    OR away_team_api_id = 8673
ORDER BY (home_team_goal + away_team_goal) DESC;


-- calculate the average number home and away goals scored Legia Warszawa, and their opponents, 
-- partitioned by the month in each season.


SELECT 
	date,
	season,
	home_team_goal,
	away_team_goal,
	CASE WHEN home_team_api_id = 8673 THEN 'home' 
         ELSE 'away' END AS warsaw_location,
	-- Calculate average goals partitioned by season and month
    AVG(home_team_goal) OVER(PARTITION BY  season, 
         	strftime('%m', date)) AS season_mo_home,
    AVG(away_team_goal) OVER(PARTITION BY  season, 
         	strftime('%m', date)) AS season_mo_away
FROM Match
WHERE 
	home_team_api_id = 8673
    OR away_team_api_id = 8673
ORDER BY (home_team_goal + away_team_goal) DESC;


-- Sliding windows are functions that perform calculations relative to the current row of a data set.

-- You can use sliding windows to calculate a wide variety of information that aggregates one row 
-- at a time down your data set -- running totals, sums, counts, and averages in any order you need.

-- The general syntax looks like this
    -- ROWS BETWEEN <start> AND <finish>
-- For the start and finish you can specify a number of keywords as

-- PRECEDING and FOLLOWING are used to specify the number of rows before, or after, the current row 
-- that you want to include in a calculation.

-- UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING tell SQL that you want to include every row since the 
-- beginning, or the end, of the data set in your calculations.

-- Finally, CURRENT ROW tells SQL that you want to stop your calculation at the current row.


-- calculate a sum of goals scored when Manchester City played as the home team during the 2011/2012 season.
-- turn this calculation into a running total, ordered by the date of the match from oldest to most recent 
-- and calculated from the beginning of the data set to the current row
SELECT 
    date, 
    home_team_goal,
    away_team_goal, 
    SUM(home_team_goal) 
        OVER(ORDER BY date ROWS BETWEEN 
            UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM Match
WHERE home_team_api_id = 8456 AND season = '2011/2012';


-- Now calculates the sum of Manchester City's goals in the current and previous match

SELECT 
    date, 
    home_team_goal,
    away_team_goal, 
    SUM(home_team_goal) 
        OVER(ORDER BY date ROWS BETWEEN 
            1 PRECEDING AND CURRENT ROW) AS last2_goals
FROM Match
WHERE home_team_api_id = 8456 AND season = '2011/2012';

-- Sliding windows allow you to create running calculations between any two points in a window

-- calculate the running total of goals scored by the FC Utrecht when they were the home team 
-- during the 2011/2012 season

SELECT 
	date,
	home_team_goal,
	away_team_goal,
    -- Create a running total and running average of home goals
    SUM(home_team_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(home_team_goal) OVER(ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE 
	home_team_api_id = 9908 
	AND season = '2011/2012';


-- Now let's see how FC Utrecht performs when they're the away team
-- sorting the data set in reverse order and calculating a backward 
-- running total from the CURRENT ROW to the end of the data set (earliest record).

SELECT 
	-- Select the date, home goal, and away goals
	date,
    home_team_goal,
    away_team_goal,
    -- Create a running total and running average of home goals
    SUM(home_team_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_total,
    AVG(home_team_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE 
	away_team_api_id = 9908 
    AND season = '2011/2012';