SELECT *
FROM games;


-- Queary that incorporates all
WITH top3_team_scorers AS (
	SELECT team_name
	FROM teams t
	JOIN goals g ON t.team_id = g.scoring_team_id
	GROUP BY team_name
	ORDER BY COUNT(g.goal_id) DESC
	LIMIT 3
)
SELECT g.game_date,
	   s.stadium_name,
       t1.team_name AS 'Home Team', 
       t2.team_name AS 'Away Team',
       g.home_goals,
       g.away_goals,
       SUM(gl.is_penalty) AS penalties_scored
FROM games g
JOIN teams t1 ON t1.team_id = g.home_team_id
JOIN teams t2 ON t2.team_id = g.away_team_id
JOIN goals gl ON g.game_id = gl.game_id
JOIN stadiums s ON g.stadium_id = s.stadium_id
WHERE (t1.team_name IN (SELECT team_name FROM top3_team_scorers)
   OR t2.team_name IN (SELECT team_name FROM top3_team_scorers))
   AND g.game_date = (
        SELECT MAX(g2.game_date)
        FROM games g2
        WHERE g2.stadium_id = g.stadium_id
      )
GROUP BY g.game_id
HAVING penalties_scored > 0
ORDER BY g.game_date DESC
LIMIT 1;


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