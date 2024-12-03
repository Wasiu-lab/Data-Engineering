create type vertex_type as enum(
							'player',
							'team',
							'game'
							)

create table vertices(
			identifier text,
			type vertex_type,
			properties json,
			primary key(identifier, type)
					)

create type edge_type as enum ('plays_against', 
								'shares_team',
								'plays_in',
								'plays_on'
								)
drop table edges
create table edges(
			subject_identifier text,
			subject_type vertex_type,
			object_identifier text,
			object_type vertex_type,
			edge_type edge_type,
			properties json,
			primary key(
			subject_identifier,
			subject_type,
			object_identifier,
			object_type,
			edge_type
			)
)

--#######################
-- building the game properties to insert into vertices
-- insert into vertices
-- select 
-- 	game_id as identifier,
-- 	'game'::vertex_type as type,
-- 	json_build_object(
-- 	'pts_home', pts_home,
-- 	'pts_away', pts_away,
-- 	'winning_team',
-- 	case when home_team_wins = 1
-- 		then home_team_id
-- 		else visitor_team_id
-- 	end)
-- from games;

-- ################################
-- building the player properties to insert into vertices
-- insert into vertices
-- with players_agg as (
-- select 
-- 	player_id as identifier,
-- 	max(player_name) as player_name,
-- 	count(game_id) as number_of_games,
-- 	sum(pts) as total_point,
-- 	array_agg(distinct team_id) as teams
-- from game_details
-- group by player_id
-- )
-- select identifier, 
-- 		'player':: vertex_type,
-- 		json_build_object(
-- 		'player_name', player_name,
-- 		'number_of_games', number_of_games,
-- 		'total_point', total_point,
-- 		'teams', teams
-- 		)
-- from players_agg;
-- ##############################
-- building the team properties to insert into vertices
-- A CTE was written becuause we had duplicate in the teams table
-- insert into vertices
-- with teams_deduped as (
-- 	select *, row_number() over(partition by team_id) as row_num
-- 	from teams
-- )
-- select 
-- 	team_id as identifier,
-- 	'team'::vertex_type as type,
-- 	json_build_object(
-- 	'abbreviation', abbreviation,
-- 	'nick_name', nickname,
-- 	'city', city,
-- 	'year_founded', yearfounded,
-- 	'arena', arena,
-- 	'arena_capacity', arenacapacity
-- 	)
-- from teams_deduped
-- where row_num = 1

-- ###################
-- cte because of duplicate. The below query is for plays_in part of the edges table  
-- with deduped2 as (
-- 	select *, row_number() over(partition by player_id, game_id) as row_num
-- 	from game_details
-- ),		
-- select 
-- 	player_id as subject_identifier,
-- 	'player':: vertex_type as subject_type,
-- 	game_id as object_identifier,
-- 	'game':: vertex_type as object_type,
-- 	'plays_in':: edge_type as edge_type,
-- 	json_build_object(
-- 		'start_position', start_position,
-- 		'pts', pts,
-- 		'team_id', team_id,
-- 		'team_abbreviation',team_abbreviation
-- 	)
-- from deduped2
-- where row_num = 1;

-- The below query is for   player_against and shared team part of  edges table
-- with deduped2 as (
-- 	select *, row_number() over(partition by player_id, game_id) as row_num
-- 	from game_details
-- ), 
-- filtered as (
-- 		select * from deduped2
-- 		where row_num = 1
-- 		),
-- aggregated as (
-- 		select 
-- 				f1.player_id as subject_player_id,
-- 				f2.player_id as object_player_id,
-- 				case when f1.team_abbreviation = f2.team_abbreviation
-- 					then 'shares_team':: edge_type
-- 				else 'plays_against':: edge_type
-- 			end as edge_type,
-- 			max(f1.player_name) as subject_player_name,
-- 			max(f2.player_name) as object_player_name,
-- 			count(1) as num_games,
-- 			sum(f1.pts) as subject_points,
-- 			sum(f2.pts) as object_points
-- 		from filtered f1 join filtered f2 
-- 			on f1.game_id = f2.game_id
-- 			and f1.player_name <> f2.player_name
-- 		where f1.player_name > f2.player_name --- this just to have one side iteration or edges
-- 		group by 
-- 		f1.player_id,
-- 		f2.player_id,
-- 		case when f1.team_abbreviation = f2.team_abbreviation
-- 				then 'shares_team':: edge_type
-- 		else 'plays_against':: edge_type
-- 		end	-- this will created egde per case but we want it in aggregation
-- )	

-- select 
-- 	subject_player_id as subject_identifier,
-- 	'player':: vertex_type as subject_type,
-- 	object_player_id as object_identifier,
-- 	'player':: vertex_type as object_type,
-- 	edge_type as edge_type,
-- 	json_build_object(
-- 		'num_games', num_games,
-- 		'subject_points', subject_points,
-- 		'object_points', object_points
-- 	)
-- from aggregated
			










