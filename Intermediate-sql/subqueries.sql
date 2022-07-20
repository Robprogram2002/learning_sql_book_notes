-- Active: 1658280730769@@127.0.0.1@3306

-- Subqueries are incredibly powerful for performing complex filters and transformations.
-- You can filter data based on single, scalar values using a subquery in ways you 
-- cannot by using WHERE statements or joins. 

SELECT 
	-- Select the date, home goals, and away goals scored
    date,
	home_team_goal,
	away_team_goal
FROM  Match
-- Filter for matches where total goals exceeds 3x the average
WHERE (home_team_goal + away_team_goal) > 
       (SELECT 3 * AVG(home_team_goal + away_team_goal)
        FROM Match
        WHERE season = '2013/2014') AND season = '2013/2014'; 

-- Filtering using a subquery with a list

-- In addition to filtering using a single-value (scalar) subquery, you can create a list of values in a subquery to 
-- filter data based on a complex set of conditions.
-- generate a list of teams that never played a game in their home city

SELECT 
	-- Select the team long and short names
	team_long_name,
	team_short_name
FROM Team
-- Exclude all values from the subquery
WHERE team_api_id  NOT IN
     (SELECT DISTINCT home_team_api_id  FROM match);


-- create a list of teams that scored 8 or more goals in a home match.
SELECT
	team_long_name,
	team_short_name
FROM team
-- Filter for teams with 8 or more home goals
WHERE team_api_id IN
	  (SELECT home_team_api_id  
       FROM Match
       WHERE home_team_goal >= 8);

-- The match does not contain country or team names. You can get this information by joining 
-- it to the country table, and use this to aggregate information,

-- If you're interested in filtering data from one of these tables, you can also create a 
-- subquery from one of the tables, and then join it to an existing table in the database. 
-- A subquery in FROM is an effective way of answering detailed questions that requires 
-- filtering or transforming data before including it in your final results.

-- calculate information about matches with 10 or more goals in total gruped by country
SELECT
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM Country AS c
-- Inner join the subquery onto country
-- Select the country id and match id columns
INNER JOIN (SELECT country_id, id 
           FROM Match
           -- Filter the subquery by matches with 10+ goals
           WHERE (home_team_goal + away_team_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY country_name
ORDER BY country_name;


-- Let's find out some more details about those matches -- when they were played, during which seasons, 
-- and how many of the goals were home versus away goals.

SELECT
    country,
    date,
    home_team_goal,
    away_team_goal
FROM 
	(SELECT c.name AS country, 
     	    m.date, 
     		m.home_team_goal, 
     		m.away_team_goal,
           (m.home_team_goal + m.away_team_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
-- Filter by total goals scored in the main query
WHERE total_goals >= 10
ORDER BY date;


-- Subqueries in SELECT statements generate a single value that allow you to pass an aggregate value down a data frame. 
-- This is useful for performing calculations on data within your database.
SELECT 
	l.name AS league,
    -- Select and round the league's total goals
    ROUND(AVG(m.home_team_goal + m.away_team_goal), 2) AS avg_goals,
    -- Select & round the average total goals for the season
    (SELECT ROUND(AVG(home_team_goal + away_team_goal), 2) 
     FROM Match
     WHERE season = '2013/2014') AS overall_avg
FROM League AS l
LEFT JOIN Match AS m
ON l.country_id = m.country_id
-- Filter for the 2013/2014 season
WHERE m.season = '2013/2014' 
GROUP BY league;


-- Subqueries in SELECT are a useful way to create calculated columns in a query. A subquery in SELECT 
-- can be treated as a single numeric value to use in your calculations. 

SELECT
	-- Select the league name and average goals scored
	l.name AS league,
	ROUND(AVG(m.home_team_goal + m.away_team_goal),2) AS avg_goals,
    -- Subtract the overall average from the league average
	ROUND(AVG(m.home_team_goal + m.away_team_goal) - 
		(SELECT AVG(home_team_goal + away_team_goal)
		 FROM Match
         WHERE season = '2013/2014'),2) AS diff
FROM League AS l
LEFT JOIN Match AS m
ON l.country_id = m.country_id
-- Only include 2013/2014 results
WHERE season = '2013/2014'
GROUP BY l.name;

-- Correlated subqueries are subqueries that reference one or more columns in the main query. Correlated 
-- subqueries depend on information in the main query to run, and thus, cannot be executed on their own.

-- Correlated subqueries are evaluated in SQL once per row of data retrieved -- a process that takes a 
-- lot more computing power and time than a simple subquery.

-- examine matches with scores that are extreme outliers for each country -- above 3 times the average score

SELECT 
	main.country_id,
    main.date,
    main.home_team_goal, 
    main.away_team_goal
FROM (SELECT * FROM Match WHERE season = '2013/2014') AS main
WHERE 
	-- Filter the main query by the subquery
	(home_team_goal + away_team_goal) > 
        (SELECT AVG((sub.home_team_goal + sub.away_team_goal) * 3)
         FROM Match AS sub
         -- Join the main query to the subquery in WHERE
         WHERE main.country_id = sub.country_id);


-- Correlated subqueries are useful for matching data across multiple columns.

-- what was the highest scoring match for each country, in each season?

SELECT 
	main.country_id,
    main.date,
    main.home_team_goal,
    main.away_team_goal
FROM Match AS main
WHERE 
	-- Filter for matches with the highest number of goals scored
	(home_team_goal + away_team_goal) = 
        (SELECT MAX(sub.home_team_goal + sub.away_team_goal)
         FROM Match AS sub
         WHERE main.country_id = sub.country_id
               AND main.season = sub.season);


-- Nested simple subqueries

-- Nested subqueries can be either simple or correlated.

-- examine the highest total number of goals in each season, overall, and during July across all seasons.
SELECT
	season,
    MAX(home_team_goal + away_team_goal) AS max_goals,
    -- Select the overall max goals scored in a match
   (SELECT MAX(home_team_goal + away_team_goal) FROM Match) AS overall_max_goals,
   -- Select the max number of goals scored in any match in July
   (SELECT MAX(home_team_goal + away_team_goal) 
    FROM Match
    WHERE id IN (
          SELECT id FROM Match WHERE  strftime('%m', date) = '07')) AS july_max_goals
FROM Match
GROUP BY season;


-- What's the average number of matches per season where a team scored 5 or more goals? 
-- How does this differ by country?

SELECT
	c.name AS country,
    -- Calculate the average matches per season
	AVG(outer_s.matches) AS avg_seasonal_high_scores
FROM Country AS c
-- Left join outer_s to country
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
	FROM Match
	WHERE home_team_goal >= 5 OR away_team_goal >= 5) AS inner_s
  -- Close parentheses and alias the subquery
  GROUP BY country_id, season) AS outer_s
ON c.id = outer_s.country_id
GROUP BY Country;


-- How do you get both the home and away team names into one final query result?

-- using simple subqueries

SELECT
	m.date,
    home.hometeam,
    away.awayteam,
    m.home_team_goal,
    m.away_team_goal
FROM Match AS m
-- Join the home subquery to the match table
LEFT JOIN (
  SELECT Match.id, team.team_long_name AS hometeam
  FROM Match
  LEFT JOIN Team AS team
  ON Match.home_team_api_id = team.team_api_id) AS home
ON home.id = m.id
-- Join the away subquery to the match table
LEFT JOIN (
  SELECT match.id, team.team_long_name AS awayteam
  FROM Match AS match
  LEFT JOIN Team AS team
  -- Get the away team ID in the subquery
  ON match.away_team_api_id = team.team_api_id) AS away
ON away.id = m.id;


-- using correated subqueries

SELECT
    m.date,
    (SELECT team_long_name
     FROM Team AS t
     WHERE t.team_api_id = m.home_team_api_id) AS hometeam,
    -- Connect the team to the match table
    (SELECT team_long_name
     FROM Team AS t
     WHERE t.team_api_id = m.away_team_api_id) AS awayteam,
    -- Select home and away goals
     m.home_team_goal,
     m.away_team_goal
FROM Match AS m;