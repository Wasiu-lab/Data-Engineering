-- 2. Aggregations Using GROUPING SETS
-- Game details table assumed to have columns: player_name, team_name, season, pts, wins
WITH game_details AS (
    SELECT player_name, team_name, season, SUM(pts) AS total_pts, SUM(wins) AS total_wins
    FROM player_seasons
    GROUP BY player_name, team_name, season
)
SELECT
    player_name,
    team_name,
    season,
    SUM(total_pts) AS total_points,
    SUM(total_wins) AS total_wins
FROM game_details
GROUP BY GROUPING SETS (
    (player_name, team_name),
    (player_name, season),
    (team_name)
)
ORDER BY total_points DESC;