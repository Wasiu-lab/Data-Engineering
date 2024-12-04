insert into host_activity (month, host, hit_array, unique_visitors)
with daily_aggregate as (
    select 
        host,
        date(event_time) as date,
        count(1) as hit_array,
        count(distinct user_id) as unique_visitors 
    from events
    where date(event_time) = date('2023-01-09')
    and host is not null
    group by host, date(event_time)
),
yesterday_array as (
    select *
    from host_activity
    where month = date('2023-01-01')
)
select 
    coalesce(da.date, ya.month + interval '1 day') as month,
    coalesce(ya.host, da.host) as host,
    case 
        when ya.hit_array is not null 
            then ya.hit_array || array[coalesce(da.hit_array, 0)]
        when ya.hit_array is null
            then array_fill(0, array[coalesce(date - date('2023-01-01'), 0)]) || array[coalesce(da.hit_array, 0)]
    end as hit_array,
    case 
        when ya.unique_visitors is not null
            then ya.unique_visitors || array[coalesce(da.unique_visitors, 0)]
        when ya.unique_visitors is null 
            then array_fill(0, array[coalesce(date - date('2023-01-01'), 0)]) || array[coalesce(da.unique_visitors, 0)]
    end as unique_visitors
from daily_aggregate da
    full outer join yesterday_array ya on da.host = ya.host
group by 1, 2, 3, 4
on conflict (month, host)
do update set 
    hit_array = excluded.hit_array,
    unique_visitors = excluded.unique_visitors;
