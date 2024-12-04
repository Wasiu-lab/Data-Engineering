-- step 1 
--create a table that will hold the data for the active day of different users 

-- droping table to fix the issue of bigint and change to text
-- drop table users_cumulated
-- create table users_cumulated(
-- 			user_id text,
-- note date_active is list of date in the past where user was active and 
-- it a list since we are passint it in []
-- 			dates_active date[],
-- date will be the current date for the user 
-- 			date date,
-- 			primary key(user_id, date)
-- )

-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
-- the below query is for the today cte which will help reduce the column of user_id with mutiple login 
-- in a day. Though it also include null peope that didn't log in at all
select 
			user_id,
			date(cast(event_time as timestamp)) as date_active
		from events
-- -- we are casting it because the event tiem from te original data was in text data type which need to be cast to display 
		where date(cast(event_time as timestamp)) = date('2023-01-01')
		group by user_id, date(cast(event_time as timestamp)) 

-- ######################################################################

-- step 2 
-- writing yesterday and today query for each new day
-- insert into the table then populate it one day at a time
insert into users_cumulated
with yesterday as (
-- this will be an empty table because we havent populate anything into the user_cumulated table
		select * 
		from users_cumulated
		where date = date('2023-01-30')
), today as(
		select 
-- since we changed user_id to text we will have to cast it as text
			cast(user_id as text) as user_id,
			date(cast(event_time as timestamp)) as date_active
		from events
-- we are casting it because the event tiem from te original data was in text data type which need to be cast to display 
		where date(cast(event_time as timestamp)) = date('2023-01-31')
		-- dealing with the null column 
		and user_id is not null 
		group by user_id, date(cast(event_time as timestamp))
)
-- #######################
--- step 3
-- incremental filling of each daay to day to the today column
-- note it y.dates_active and t.date_active
select 
-- filling yesterday column
	coalesce(t.user_id, y.user_id) as user_id,
-- date active column will be done because we want to collect the array of vaules
-- explanation: when yesterday date_active is null then it should give an array for today date_active
-- else it should concate (||) yesterday and today active date 
-- also we should consider when today date_active is null then we want it to pass yesteday date
		case
			when y.dates_active is null then array[t.date_active]
			when t.date_active is null then y.dates_active
-- for the else statement, make sure the recent dat comes first 
			else array[t.date_active] || y.dates_active  
		end
		as date_active,
-- coalescing the y.date alone would have return yesterday's date and what we want is date_active and the date to be the same 
-- therefore we are adding plus one day to it 
	coalesce(t.date_active, y.date + interval '1 day') as date
	
from today t full outer join yesterday y 
	on t.user_id = y.user_id

select * from users_cumulated
where date = date('2023-01-31')

