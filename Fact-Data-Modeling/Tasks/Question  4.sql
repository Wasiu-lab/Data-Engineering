with users as (
		select * from user_devices_cumulated
		),	
series as(
		select * 
		from generate_series(date('2023-01-01'), date('2023-01-31'), interval  '1 day') 
		as series_date
		),
datelist_int as (
select
	case when 
	device_activity @> array[date(series_date)]
	then cast(pow(2, 31 - (date - date(series_date)))as bigint)
	else 0 
	end as datelist_int,
	*
	from users cross join series
)

select * from datelist_int





