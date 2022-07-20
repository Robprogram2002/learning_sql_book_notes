-- Active: 1658280730769@@127.0.0.1@3306
SELECT 
	team_long_name, 
	team_api_id
FROM teams_germany
WHERE team_long_name IN ('FC Schalke 04', 'FC Bayern Munich');

-- Basic Case Statement

-- identify matches played between FC Schalke 04 and FC Bayern Munich
SELECT 
	CASE WHEN home_team_api_id = 10189 THEN 'FC Schalke 04'
        WHEN home_team_api_id = 9823 THEN 'FC Bayern Munich'
        ELSE 'Other' END AS home_team,
	COUNT(id) AS total_matches
FROM matches_germany
-- WHERE season IN ('2011/2012', '2012/2013', '2013/2014', '2014/2015')
-- Group by the CASE statement alias
GROUP BY home_team;


-- CASE statements comparing column values

--  create a list of matches in the 2011/2012 season where Barcelona was the home team.
-- identifies a match's winner, identifies the identity of the opponent, and finally 
-- filters for Barcelona as the home team

SELECT 
	m.date,
	t.team_long_name AS opponent,
    -- Complete the CASE statement with an alias
	CASE WHEN m.home_team_goal > m.away_team_goal THEN 'Barcelona win!'
        WHEN m.home_team_goal < m.away_team_goal THEN 'Barcelona loss :(' 
        ELSE 'Tie' END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.away_team_api_id = t.team_api_id
-- Filter for Barcelona as the home team
WHERE m.home_team_api_id = 8634 AND m.season = '2011/2012'
ORDER BY date;


-- Now construct a query to determine the outcome of Barcelona's matches where they played as the away team.

-- Select matches where Barcelona was the away team
SELECT 
	m.date,
	t.team_long_name AS opponent,
    -- Complete the CASE statement with an alias
	CASE WHEN m.home_team_goal < m.away_team_goal THEN 'Barcelona win!'
        WHEN m.home_team_goal > m.away_team_goal THEN 'Barcelona loss :(' 
        ELSE 'Tie' END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.home_team_api_id = t.team_api_id
-- Filter for Barcelona as the home team
WHERE m.away_team_api_id = 8634 AND m.season = '2011/2012'
ORDER BY date;


-- query a list of matches played between Barcelona and Real Madrird
SELECT 
	date,
	CASE WHEN home_team_api_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as home,
	CASE WHEN away_team_api_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as away,
	-- Identify all possible match outcomes
	CASE WHEN home_team_goal > away_team_goal AND home_team_api_id = 8634 THEN 'Barcelona win!'
        WHEN home_team_goal > away_team_goal AND home_team_api_id = 8633 THEN 'Real Madrid win!'
        WHEN home_team_goal < away_team_goal AND away_team_api_id = 8634 THEN 'Barcelona win!'
        WHEN home_team_goal < away_team_goal AND away_team_api_id = 8633 THEN 'Real Madrid win!'
        ELSE 'Tie!' END AS outcome
FROM (
    SELECT * FROM matches_spain
    WHERE (away_team_api_id = 8634 OR home_team_api_id = 8634)
      AND (away_team_api_id = 8633 OR home_team_api_id = 8633))
WHERE season IN ('2011/2012', '2012/2013', '2013/2014', '2014/2015')
ORDER BY date;


-- CASE statements allow you to categorize data that you're interested in -- and exclude data you're 
-- not interested in. In order to do this, you can use a CASE statement as a filter in the WHERE 
-- statement to remove output you don't want to see.

-- Let's generate a list of matches won by Italy's Bologna team
SELECT 
	season,
	date,
	home_team_goal,
	away_team_goal
FROM matches_italy
WHERE
-- Exclude games not won by Bologna
	CASE WHEN home_team_api_id = 9857 AND home_team_goal > away_team_goal THEN 'Bologna Win'
         WHEN away_team_api_id = 9857 AND away_team_goal > home_team_goal THEN 'Bologna Win' 
         END IS NOT NULL
ORDER BY date;

-- COUNT using CASE WHEN

-- Using the country and unfiltered match table, count the number of matches played in each country 
-- during the 2012/2013, 2013/2014, and 2014/2015 match seasons

SELECT 
	c.name AS country,
    -- Count matches in each of the 3 seasons
	COUNT(CASE WHEN m.season = '2012/2013' THEN m.id END) AS matches_2012_2013,
	COUNT(CASE WHEN m.season = '2013/2014' THEN m.id END) AS matches_2013_2014,
	COUNT(CASE WHEN m.season = '2014/2015' THEN m.id END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
GROUP BY country
ORDER BY country;

-- In R or Python, you have the ability to calculate a SUM of logical values (i.e., TRUE/FALSE) directly. 
-- In SQL, you have to convert these values into 1 and 0 before calculating a sum. 
-- This can be done using a CASE statement.

-- Your goal here is to use the country and match table to determine the total number of matches won by 
-- the home team in each country during the 2012/2013, 2013/2014, and 2014/2015 seasons.

SELECT 
	c.name AS country,
    -- Sum the total records in each season where the home team won
	SUM(CASE WHEN m.season = '2012/2013' AND m.home_team_goal > m.away_team_goal 
        THEN 1 ELSE 0 END) AS matches_2012_2013,
 	SUM(CASE WHEN m.season = '2013/2014' AND m.home_team_goal > m.away_team_goal 
        THEN 1 ELSE 0 END) AS matches_2013_2014,
	SUM(CASE WHEN m.season = '2014/2015' AND m.home_team_goal > m.away_team_goal 
        THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
GROUP BY country
ORDER BY country;


-- Calculating percent with CASE and AVG

-- using CASE inside an AVG function to calculate a percentage of information in your database. Template:

-- AVG(CASE WHEN condition_is_met THEN 1
        --  WHEN condition_is_not_met THEN 0 END)

SELECT 
	c.name AS country,
    -- Round the percentage of tied games to 2 decimal points
	ROUND(AVG(CASE WHEN m.season='2013/2014' AND m.home_team_goal = m.away_team_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_team_goal != m.away_team_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	ROUND(AVG(CASE WHEN m.season='2014/2015' AND m.home_team_goal = m.away_team_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_team_goal != m.away_team_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM Country AS c
LEFT JOIN Match AS m
ON c.id = m.country_id
GROUP BY country;