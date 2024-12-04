insert into user_devices_cumulated
with yesterday as (
        select * 
        from user_devices_cumulated
        where date = DATE('2023-01-30')
),
today as (

        select CAST(e.user_id as TEXT),
        d.browser_type,
        DATE(CAST(event_time as TIMESTAMP)) as date_active
        
        from events e left join devices d
        on e.device_id = d.device_id
        
        where DATE(CAST(event_time as TIMESTAMP)) = DATE('2023-01-31')
        and user_id IS NOT NULL and browser_type is not NULL
        group by e.user_id ,d.browser_type ,DATE(CAST(e.event_time as TIMESTAMP))
)
select 
		COALESCE(t.user_id,y.user_id) as user_id,
		COALESCE(t.browser_type, y.browser_type),
        CASE when y.device_activity is NULL
             then ARRAY[t.date_active]    
             when t.date_active IS NULL
             then y.device_activity
             ELSE ARRAY[t.date_active] || y.device_activity 
        END as device_activity,
        COALESCE( t.date_active,y.date + INTERVAL '1 day') as date
from today t 
        FULL OUTER JOIN yesterday y 
        ON t.user_id = y.user_id
        and t.browser_type = y.browser_type