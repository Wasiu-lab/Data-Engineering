-- select * from player_seasons;

-- create type season_stat as (
-- 							season integer,
-- 							gp integer,
-- 							pts real,
-- 							reb real,
-- 							ast real
-- 							)

-- create type scoring_classes as enum ('star', 'good', 'average' ,'bad')

-- The first table will include details that won't be changign over time
-- create table player_table (
-- 					player_name text,
-- 					height text,
-- 					college text,
-- 					country text,
-- 					draft_year text,
-- 					draft_round text,
-- 					draft_number text,
-- 					season_stat season_stat[],
-- 					scoring_classes scoring_classes,
-- 					years_since_last_season integer,
-- 					current_season integer,
-- 					primary key(player_name, current_season)
-- 					)

-- select min(season) from player_seasons;


insert into player_table
with yesterday as (	
				select * from player_table
				where current_season = 2000
				),
				today as (
				select * from player_seasons
				where season = 2001
				) 

select  
	coalesce(t.player_name, y.player_name) as player_name,
	coalesce(t.height, y.height) as height,
	coalesce(t.college, y.college) as college,
	coalesce(t.country, y.country) as country,
	coalesce(t.draft_year, y.draft_year) as draft_year,
	coalesce(t.draft_round, y.draft_round) as draft_round,
	coalesce(t.draft_number, y.draft_number) as draft_number,
	case when y.season_stat is null
		then array[row(
		t.season,
		t.gp,
		t.pts,
		t.reb,
		t.ast
		)::season_stat]
	when t.season is not null then y.season_stat || array[row(
		t.season,
		t.gp,
		t.pts,
		t.reb,
		t.ast
		)::season_stat]
	else y.season_stat
	end as season_stat,
	case 
		when t.season is not null then 
		case when t.pts > 20 then 'star'
			when t.pts >15 then 'good'
			when t.pts > 10 then 'average'
			else 'bad'
	end:: scoring_classes
	else y.scoring_classes
	end as scoring_classes,
	case when t.season is not null then 0
		else y.years_since_last_season + 1
	end as years_since_last_season,
	coalesce(t.season, y.current_season + 1) as current_season	
from today t full outer join yesterday y
	on t.player_name = y.player_name

select * from player_table where current_season = 2000
and player_name = 'Michael Jordan'













	
