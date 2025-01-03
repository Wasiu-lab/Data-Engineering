-- 1. State Change Tracking for Players
WITH player_changes AS (
    SELECT
        p.player_name,
        p.current_season,
        COALESCE(LAG(p.current_season) OVER (PARTITION BY p.player_name ORDER BY p.current_season), 0) AS prev_season,
        p.is_active,
        COALESCE(LAG(p.is_active) OVER (PARTITION BY p.player_name ORDER BY p.current_season), FALSE) AS prev_is_active
    FROM player_table p
),
state_tracking AS (
    SELECT
        player_name,
        current_season,
        CASE
            WHEN prev_season = 0 AND is_active THEN 'New'
            WHEN prev_season != 0 AND NOT is_active THEN 'Retired'
            WHEN prev_season != 0 AND is_active AND prev_is_active THEN 'Continued Playing'
            WHEN prev_season != 0 AND is_active AND NOT prev_is_active THEN 'Returned from Retirement'
            WHEN NOT is_active AND NOT prev_is_active THEN 'Stayed Retired'
        END AS state_change
    FROM player_changes
)
SELECT *
FROM state_tracking;