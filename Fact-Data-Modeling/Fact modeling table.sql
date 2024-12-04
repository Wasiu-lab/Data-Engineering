-- -- step 1
-- -- checking for duplicate
-- select 
-- 	game_id, team_id, player_id, count(1)
-- from game_details
-- group by 1,2, 3
-- having count(1) > 1

-- --step 2 
-- -- creating a dedupe inside a cte to remove duplicate and also requery step 1
-- -- joining the games table to be able to extracet the when  field for the fact table
-- with deduped as (
-- 	select 
-- 	g.game_date_est,
-- 	gd.*,
-- 	row_number() over(partition by gd.game_id, team_id, player_id order by g.game_date_est ) as row_num
-- 	from game_details gd
-- 		join games g on gd.game_id = g.game_id
-- )


-- checking for duplicate
-- select 
-- 	game_id, team_id, player_id, count(1)
-- from game_details
-- group by 1,2, 3
-- having count(1) > 1
insert into fact_game_details
with deduped as (
	select 
	g.game_date_est,
	g.season,
	g.home_team_id,
	gd.*,
	row_number() over(partition by gd.game_id, team_id, player_id order by g.game_date_est ) as row_num
	from game_details gd
		join games g on gd.game_id = g.game_id
		-- this below is just to make the query fast
		-- where g.game_date_est = '2016-10-04'
)
-- step 4 pulling only columns that we need to work with 
-- note from comment for games
-- DND -- did not dress
-- DNP did not play 
-- NWT not in arena
select game_date_est as dim_game_date,
	season as dim_season,
	team_id as dim_team_id,
	player_id as dim_player_id,
	player_name as dim_player_name,
	start_position as dim_start_position,
	team_id = home_team_id as dim_is_playing_at_home,
	-- aim of below is to remove the null and have the comment where null read a boolean expression
	-- like flase and if not then true and coalescing it to have it in a new column
	-- after this then we can remove the comment column 
	coalesce(position('DNP' in comment), 0) > 0 as dim_did_not_play,
	coalesce(position('DND' in comment), 0) > 0 as dim_did_not_dress,
	coalesce(position('NWT' in comment), 0) > 0 as dim_did_not_with_team,
	--comment, removing comment from the query
	-- looking at the minutes played by player, we want to split it into 2 different column which 
	-- will be minutes and second or we can join them together but have it in decimal 
	-- the aim of this is for analytic purpose to make it easy 
	cast(split_part(min, ':', 1) as real)
	+ cast(split_part(min, ':', 1) as real)/60 as m_minutes,
	-- split_part(min, ':', 1) as minutes,
	-- split_part(min, ':', 2) as seconds,
	--min,
	fgm as m_fgm,
	fga as m_fga,
	fg3m as m_fg3m,
	fg3a as m_fg3a,
	ftm as m_ftm,
	fta as m_fta,
	oreb as m_oreb,
	dreb as m_dreb,
	reb as m_reb,
	ast as m_ast,
	stl as m_stl,
	blk as m_blk,
	"TO" as m_turnover,
	pf as m_pf,
	pts as m_pts,
	plus_minus as m_plus_minus
from deduped
where row_num = 1

--dim is use to start label that are season while measure have m in front of it
create table fact_game_details(
			dim_game_date DATE,
			dim_season integer,
			dim_team_id integer,
			dim_player_id integer,
			dim_player_name text,
			dim_start_position text,
			dim_is_playing_at_home boolean,
			dim_did_not_play boolean,
			dim_did_not_dress boolean,
			dim_did_not_with_team boolean,
			m_minutes real,
			m_fgm integer,
			m_fga integer,
			m_fg3m integer,
			m_fg3a integer,
			m_ftm integer,
			m_fta integer,
			m_oreb integer,
			m_dreb integer,
			m_reb integer,
			m_ast integer,
			m_stl integer,
			m_blk integer,
			m_turnover integer,
			m_pf integer,
			m_pts integer,
			m_plus_minus integer,
			primary key(dim_game_date, dim_team_id, dim_player_id)
)
select *
from fact_game_details
-- in case we neeed to match it with the team name to view the team we can just join it

select t.*, fgd.*
from fact_game_details fgd
	join teams t
		on t.team_id = fgd.dim_team_id 

-- we can find player from the fgd table who bailed out of most games or wasn't in the arean for most games 

select dim_player_name, 
-- number of apperance 
	count(1) as num_games,
	count(case when dim_did_not_with_team then 1 end) as bailed_out,
	cast( count(case when dim_did_not_with_team then 1 end) as real)/count(1) as bailed_percenatge
from fact_game_details
group by 1
order by 2 desc