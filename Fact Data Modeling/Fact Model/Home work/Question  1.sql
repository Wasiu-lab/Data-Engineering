WITH deduplicated AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) AS row_num
    FROM game_details
)
SELECT *
FROM deduplicated
WHERE row_num = 1 ;


