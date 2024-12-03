select * from player_seasons;
-- The CTD here is pulling all the years in one query 
-- create type season_stat as (
-- 							season integer,
-- 							gp integer,
-- 							pts real,
-- 							reb real,
-- 							ast real
-- 							)

-- create type scoring_class as enum ('star', 'good', 'average', 'bad');

-- The first table will include details that won't be changign over time
drop table player_table
create table player_table (
					player_name text,
					height text,
					college text,
					country text,
					draft_year text,
					draft_round text,
					draft_number text,
					season_stat season_stat[],
					scoring_class scoring_class,
					years_since_last_season integer,
					current_season integer,
					is_active boolean,
					primary key(player_name, current_season)
					);

INSERT INTO player_table
WITH years AS (
    SELECT *
    FROM GENERATE_SERIES(1996, 2022) AS season
), p AS (
    SELECT
        player_name,
        MIN(season) AS first_season
    FROM player_seasons
    GROUP BY player_name
), players_and_seasons AS (
    SELECT *
    FROM p
    JOIN years y
        ON p.first_season <= y.season
), windowed AS (
    SELECT
        pas.player_name,
        pas.season,
        ARRAY_REMOVE(
            ARRAY_AGG(
                CASE
                    WHEN ps.season IS NOT NULL
                        THEN ROW(
                            ps.season,
                            ps.gp,
                            ps.pts,
                            ps.reb,
                            ps.ast
                        )::season_stat
                END)
            OVER (PARTITION BY pas.player_name ORDER BY COALESCE(pas.season, ps.season)),
            NULL
        ) AS seasons
    FROM players_and_seasons pas
    LEFT JOIN player_seasons ps
        ON pas.player_name = ps.player_name
        AND pas.season = ps.season
    ORDER BY pas.player_name, pas.season
), static AS (
    SELECT
        player_name,
        MAX(height) AS height,
        MAX(college) AS college,
        MAX(country) AS country,
        MAX(draft_year) AS draft_year,
        MAX(draft_round) AS draft_round,
        MAX(draft_number) AS draft_number
    FROM player_seasons
    GROUP BY player_name
)
SELECT
    w.player_name,
    s.height,
    s.college,
    s.country,
    s.draft_year,
    s.draft_round,
    s.draft_number,
    seasons AS season_stat,
    CASE
        WHEN (seasons[CARDINALITY(seasons)]::season_stat).pts > 20 THEN 'star'
        WHEN (seasons[CARDINALITY(seasons)]::season_stat).pts > 15 THEN 'good'
        WHEN (seasons[CARDINALITY(seasons)]::season_stat).pts > 10 THEN 'average'
        ELSE 'bad'
    END::scoring_class AS scoring_class,
    w.season - (seasons[CARDINALITY(seasons)]::season_stat).season as years_since_last_active,
    w.season,
    (seasons[CARDINALITY(seasons)]::season_stat).season = season AS is_active
FROM windowed w
JOIN static s
    ON w.player_name = s.player_name;

-- select player_name, is_active
-- from player_table
-- where current_season = 2022
-- limit 20








	
