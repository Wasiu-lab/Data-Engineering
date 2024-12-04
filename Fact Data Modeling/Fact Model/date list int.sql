-- the below query looks at how active the user was in the last 30 day on a daily basis giving it at bit
-- binary figures 
with users as (
		select * from users_cumulated
		where date = date('2023-01-31')
),	
	 series as(
		--generating the sequnce for the date we will be needing,
		-- the query only populate list of date from 1-31
		select * 
		from generate_series(date('2023-01-01'), date('2023-01-31'), interval  '1 day') 
		as series_date
		), 

place_holder_int as (
select
-- match each series date to the date_active it retuen a boolean for the matching
-- casing the entire case senario as bit 32 to give us the deisre outcome of bit result 
-- rather than case the case as bit, we can do so at the main select clause and remove the filter 
-- of where user_id is something 
	case when 
	dates_active @> array[date(series_date)] -- return if the user was active or not
-- below give the difference in day between date active and series day
-- first to get the 32 bit, we first cast the date difference as bigint for population purpose and not to give error
	then cast(pow(2, 31 - (date - date(series_date)))as bigint)
	else 0 
	end as placeholder_int_value,
	*
from users cross join series
-- where user_id = '16742710737361400000'
)

select 
	user_id,
	cast(cast(sum(placeholder_int_value)as bigint)as bit(32)),
-- bitcount for counting bits to count days active 
-- for any user having bit_count > 0 is monthly active user 
	bit_count(cast(cast(sum(placeholder_int_value)as bigint)as bit(32))) > 0 as dim_is_monthly_active,
-- checking for weekly active users note we are firstly passing seven 1's to sum for people active for 
-- atleast one time every week 
	bit_count(cast('11111110000000000000000000000000' as bit(32)) &
		cast(cast(sum(placeholder_int_value)as bigint) as bit(32))) > 0 as dim_is_weekly_active,
	bit_count(cast('10000000000000000000000000000000' as bit(32)) &
		cast(cast(sum(placeholder_int_value)as bigint) as bit(32))) > 0 as dim_is_daily_active

from place_holder_int
group by user_id

-- this syntax return the series date as a boolean column which gives true or flase for the date matching
-- SELECT
--     series_date = ANY(dates_active) AS is_active,
--     *
-- FROM users
-- CROSS JOIN series
-- WHERE user_id = '568596539987322000';
