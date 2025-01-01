-- Doing the retention analysis 
select
	date,
	extract(dow from first_active_date)as dow,
	date - first_active_date as day_since_fist_active,
	cast(		
		count(
			case 
				when daily_active_state in ('Retained', 'Resurrected', 'New')
						then 1 end) as real) / count(1) as pct_active,
	count(case when daily_active_state in ('Retained')then 1 end) as Retained,
	count(case when daily_active_state in ('Resurrected')then 1 end) as Resurrected,
	count(case when daily_active_state in ('New')then 1 end) as New,
	count(1)
from users_growth_accounting
group by 1,2,3
order by 1,2,3