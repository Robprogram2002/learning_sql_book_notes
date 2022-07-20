-- Who defeated Manchester United in the 2013/2014 season?

-- Set up the home and away team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_team_goal > m.away_team_goal THEN 'MU Win'
		   WHEN m.home_team_goal < m.away_team_goal THEN 'MU Loss' 
  		   ELSE 'Tie' END AS outcome
  FROM Match AS m
  LEFT JOIN Team AS t ON m.home_team_api_id = t.team_api_id),
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_team_goal > m.away_team_goal THEN 'MU Loss'
		   WHEN m.home_team_goal < m.away_team_goal THEN 'MU Win' 
  		   ELSE 'Tie' END AS outcome
  FROM Match AS m
  LEFT JOIN Team AS t ON m.away_team_api_id = t.team_api_id)
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_team_goal, m.away_team_goal,
    -- rank the matches by goal difference
    RANK() OVER(ORDER BY ABS(home_team_goal - away_team_goal) DESC) as match_rank
-- Join the CTEs onto the match table
FROM Match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'))
ORDER BY match_rank;