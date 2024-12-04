-- select max(date(event_time)) as max_t, min(date(event_time)) from events 

-- to delete all the data in a table 
-- delete from array_matrics

-- step 1, create table 
-- create table array_matrics(
-- 		user_id numeric,
-- 		month_start date,
-- 		metric_name text,
-- 		metric_array real[],
-- 		primary key(user_id, month_start, metric_name)

-- )
insert into array_matrics
-- step 2 
-- writing the daily function query 
with daily_aggregate as (
		select 
			user_id,
			date(event_time) as date,
			count(1) as num_site_hits
		from events
		where date(event_time) = date('2023-01-04')
		and user_id is not null
		group by user_id, date(event_time)

),
yesterday_array as (
		select *
		from array_matrics
		where month_start = date('2023-01-01')
)
select 
	coalesce(da.user_id, ya.user_id) as user_id,
	coalesce(ya.month_start, date(date_trunc('month', date))) as month_start,
	'site_hits' as metric_name,
	case 
		when ya.metric_array is not null 
			then ya.metric_array || array[coalesce(da.num_site_hits, 0)]
		when ya.metric_array is null
-- below query will opulate a value of zero untill the day the user start being active like 
-- if the person wasn't active on first it will and actve 4 times on second it will give [0, 2]
			then array_fill(0, array[coalesce(date - date('2023-01-01'), 0)]) ||
			array[coalesce(da.num_site_hits, 0)]
	end as metric_array
from daily_aggregate da
	full outer join yesterday_array ya on 
		da.user_id = ya.user_id
	on conflict (user_id, month_start, metric_name)
	do 
		update set metric_array = excluded.metric_array

select cardinality(metric_array), count(1) from array_matrics group by 1




