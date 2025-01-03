-- 3. Window Functions on Game Details
-- Most games won by a team in a 90-game stretch
WITH game_win_stretch AS (
    SELECT
        team_name,
        season,
        wins,
        SUM(wins) OVER (PARTITION BY team_name ORDER BY season ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS stretch_wins
    FROM player_seasons
)
SELECT team_name, season, stretch_wins
FROM game_win_stretch
ORDER BY stretch_wins DESC
LIMIT 1;

-- Longest streak of games with LeBron James scoring over 10 points
WITH lebron_streaks AS (
    SELECT
        player_name,
        season,
        pts,
        CASE WHEN pts > 10 THEN 1 ELSE 0 END AS above_ten,
        SUM(CASE WHEN pts > 10 THEN 1 ELSE 0 END) OVER (PARTITION BY player_name ORDER BY season ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS streak
    FROM player_seasons
    WHERE player_name = 'LeBron James'
)
SELECT player_name, season, MAX(streak) AS longest_streak
FROM lebron_streaks
GROUP BY player_name, season
ORDER BY longest_streak DESC;