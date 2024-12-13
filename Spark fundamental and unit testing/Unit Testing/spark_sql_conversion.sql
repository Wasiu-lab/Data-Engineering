
-- Define SparkSQL equivalent of the provided PostgreSQL query

WITH last_season_scd AS (
    SELECT * FROM players_scd
    WHERE current_season = 2021
      AND end_season = 2021
),
historical_scd AS (
    SELECT 
        player_name,
        scoring_class,
        is_active,
        start_season,
        end_season
    FROM players_scd
    WHERE current_season = 2021
      AND end_season < 2021
),
this_season_data AS (
    SELECT * FROM player_table
    WHERE current_season = 2022
),
unchanged_record AS (
    SELECT 
        ts.player_name, 
        ts.scoring_class, 
        ts.is_active,
        ls.start_season,
        ts.current_season AS end_season
    FROM this_season_data ts
    JOIN last_season_scd ls
    ON ts.player_name = ls.player_name
    WHERE ts.scoring_class = ls.scoring_class
      AND ts.is_active = ls.is_active
), 
changed_records AS (
    SELECT 
        ts.player_name, 
        EXPLODE(
            ARRAY(
                STRUCT(
                    ls.scoring_class,
                    ls.is_active,
                    ls.start_season,
                    ls.end_season
                ),
                STRUCT(
                    ts.scoring_class,
                    ts.is_active,
                    ts.current_season,
                    ts.current_season
                )
            )
        ) AS records
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
    ON ts.player_name = ls.player_name
    WHERE (ts.scoring_class <> ls.scoring_class
        OR ts.is_active <> ls.is_active)
),
unnested_changed_records AS (
    SELECT 
        player_name,
        records.scoring_class,
        records.is_active,
        records.start_season,
        records.end_season
    FROM changed_records
),
new_records AS (
    SELECT 
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ts.current_season AS start_season,
        ts.current_season AS end_season
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
    ON ts.player_name = ls.player_name
    WHERE ls.player_name IS NULL
)

SELECT * FROM historical_scd
UNION ALL
SELECT * FROM unchanged_record
UNION ALL
SELECT * FROM unnested_changed_records
UNION ALL
SELECT * FROM new_records
