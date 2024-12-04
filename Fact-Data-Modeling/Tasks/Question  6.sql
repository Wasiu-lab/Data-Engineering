insert into hosts_cumulated
with yesterday as (
        select * 
        from hosts_cumulated
        where date = DATE('2023-01-30')
),
today as (

        select CAST(user_id as TEXT),
        host,
        DATE(CAST(event_time as TIMESTAMP)) as date_active
        
        from events
        
        where DATE(CAST(event_time as TIMESTAMP)) = DATE('2023-01-31')
        and user_id IS NOT NULL and host is not NULL
        group by user_id ,host ,DATE(CAST(event_time as TIMESTAMP))
)
select 
		COALESCE(t.user_id,y.user_id) as user_id,
		COALESCE(t.host, y.host),
        CASE when y.host_activity_datelist is NULL
             then ARRAY[t.date_active]    
             when t.date_active IS NULL
             then y.host_activity_datelist
             ELSE ARRAY[t.date_active] || y.host_activity_datelist 
        END as host_activity_datelist,
        COALESCE( t.date_active,y.date + INTERVAL '1 day') as date
from today t 
        FULL OUTER JOIN yesterday y 
        ON t.user_id = y.user_id
        and t.host = y.host
		
