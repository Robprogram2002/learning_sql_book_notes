-- Active: 1658280730769@@127.0.0.1@3306

CREATE VIEW matches_germany AS 
    SELECT id, country_id, league_id, season, stage, 
    date, match_api_id, home_team_api_id, away_team_api_id, home_team_goal,
    away_team_goal
    FROM Match
    WHERE country_id = (SELECT id FROM Country WHERE name = "Germany");

CREATE VIEW teams_germany AS 
    SELECT id, team_api_id, 
        team_long_name, team_short_name
    FROM Team
    WHERE team_api_id IN (SELECT away_team_api_id FROM matches_germany);

SELECT * FROM teams_germany;
SELECT * FROM matches_germany;

CREATE VIEW matches_spain AS 
    SELECT id, country_id, league_id, season, stage, 
    date, match_api_id, home_team_api_id, away_team_api_id, home_team_goal,
    away_team_goal
    FROM Match
    WHERE country_id = (SELECT id FROM Country WHERE name = "Spain");

CREATE VIEW teams_spain AS 
    SELECT id, team_api_id, 
        team_long_name, team_short_name
    FROM Team
    WHERE team_api_id IN (SELECT away_team_api_id FROM matches_spain);


CREATE VIEW matches_italy AS 
    SELECT id, country_id, league_id, season, stage, 
    date, match_api_id, home_team_api_id, away_team_api_id, home_team_goal,
    away_team_goal
    FROM Match
    WHERE country_id = (SELECT id FROM Country WHERE name = "Italy") AND 
        season IN ('2011/2012', '2012/2013', '2013/2014', '2014/2015');
    

CREATE VIEW teams_italy AS 
    SELECT id, team_api_id, 
        team_long_name, team_short_name
    FROM Team
    WHERE team_api_id IN (SELECT away_team_api_id FROM matches_italy);
