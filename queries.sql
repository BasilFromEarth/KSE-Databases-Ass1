-- Query to find the top goal scorers for Shakhtar Donetsk
WITH shakhtar_players AS (
    SELECT player_id
    FROM players
    WHERE team = 'Shakhtar Donetsk'
), shakhtar_goals AS (
    SELECT *
    FROM goals g
    JOIN games gm ON g.game_id = gm.game_id
    WHERE g.scoring_team_id = 2)  -- Shakhtar Donetsk team_id
SELECT p.name, p.surname, COUNT(sg.goal_id) AS goals_scored
FROM shakhtar_goals sg
LEFT JOIN players p ON sg.player_id = p.player_id
WHERE sg.player_id IS NOT NULL
GROUP BY p.player_id, p.name, p.surname
ORDER BY goals_scored DESC, p.surname, p.name;


-- Query to find the top 3 teams with the highest average goals scored per game
WITH team_goals AS (
    SELECT t.team_id, t.team_name,
           SUM(CASE WHEN gm.home_team_id = t.team_id THEN gm.home_goals
                    WHEN gm.away_team_id = t.team_id THEN gm.away_goals
                    ELSE 0 END) AS total_goals,
           COUNT(gm.game_id) AS games_played
    FROM teams t
    LEFT JOIN games gm ON t.team_id = gm.home_team_id OR t.team_id = gm.away_team_id
    GROUP BY t.team_id, t.team_name
)
SELECT team_name,
       ROUND(CAST(total_goals AS DECIMAL) / NULLIF(games_played, 0), 2) AS avg_goals_per_game
FROM team_goals
WHERE games_played > 0
ORDER BY avg_goals_per_game DESC, team_name
LIMIT 3;


-- Query to find most common positions among players united with number of goals scored
WITH position_goals AS (
    SELECT p.preferred_pos, COUNT(g.goal_id) AS goals_scored
    FROM players p
    LEFT JOIN goals g ON p.player_id = g.player_id
    GROUP BY p.preferred_pos
)