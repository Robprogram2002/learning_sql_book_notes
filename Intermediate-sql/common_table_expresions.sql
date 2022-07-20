-- Active: 1658280730769@@127.0.0.1@3306

-- CTEs have numerous benefits over a subquery written inside your main query. 
-- First, the CTE is run only once, and then stored in memory, so it often leads to an improvement in the 
-- amount of time it takes to run your query. 
-- Second, CTEs are an excellent tool for organizing long and complex CTEs. You can declare as many CTEs 
-- as you need, one after another. 
-- You can also reference information in CTEs declared earlier
-- Finally, a CTE can reference itself in a special kind of table called a recursive CTE.


-- Clean Up with CTEs
-- generated a list of countries and the number of matches in each country with more than 10 total goals. 

-- Set up your CTE
WITH match_list AS (
    SELECT 
  		country_id, 
  		id
    FROM Match
    WHERE (home_team_goal + away_team_goal) >= 10)
-- Select league and count of matches from the CTE
SELECT
    l.name AS league,
    COUNT(match_list.id) AS matches
FROM League AS l
-- Join the CTE to the league table
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;


--  let's expand on the exercise by looking at details about matches with very high scores using CTEs

-- Set up your CTE
WITH match_list AS (
  -- Select the league, date, home, and away goals
    SELECT 
  		l.name AS league, 
     	m.date, 
  		m.home_team_goal, 
  		m.away_team_goal,
       (m.home_team_goal + m.away_team_goal) AS total_goals
    FROM Match AS m
    LEFT JOIN League as l ON m.country_id = l.id)
-- Select the league, date, home, and away goals from the CTE
SELECT league, date, home_team_goal, away_team_goal
FROM match_list
-- Filter by total goals
WHERE total_goals >= 10;


-- If you list multiple subqueries in the FROM clause with nested statement, your query will likely become 
-- long, complex, and difficult to read.

-- Arranging subqueries as CTEs will save you time, space, and confusion in the long run!

-- Set up your CTE
WITH match_list AS (
    SELECT 
  		country_id,
  	   (home_team_goal + away_team_goal) AS goals
    FROM Match
  	-- Create a list of match IDs to filter data in the CTE
    WHERE id IN (
       SELECT id
       FROM Match
       WHERE season = '2013/2014' AND strftime('%m', date) = '08'))
-- Select the league name and average of goals in the CTE
SELECT 
	l.name,
    ROUND(AVG(match_list.goals), 3) AS avg_august_goals
FROM League AS l
-- Join the CTE onto the league table
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;


-- How do you get both the home and away team names into one final query result?

WITH home AS (
  SELECT m.id, m.date, 
  		 t.team_long_name AS hometeam, m.home_team_goal
  FROM Match AS m
  LEFT JOIN Team AS t 
  ON m.home_team_api_id = t.team_api_id),
-- Declare and set up the away CTE
away AS (
  SELECT m.id, m.date, 
  		 t.team_long_name AS awayteam, m.away_team_goal
  FROM Match AS m
  LEFT JOIN Team AS t 
  ON m.away_team_api_id = t.team_api_id)
-- Select date, home_goal, and away_goal
SELECT 
	home.date,
    home.hometeam,
    away.awayteam,
    home.home_team_goal,
    away.away_team_goal
-- Join away and home on the id column
FROM home
INNER JOIN away
ON home.id = away.id;

