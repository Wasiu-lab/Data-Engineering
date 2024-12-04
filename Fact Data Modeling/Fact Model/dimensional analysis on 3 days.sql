with agg as (
select metric_name, month_start,
	array[sum(metric_array[1]),
			sum(metric_array[2]),
			sum(metric_array[3]),
			sum(metric_array[4])]
			as summed_array

from array_matrics 
group by metric_name, month_start
)
select 
		metric_name, 
		month_start + (index - 1) * INTERVAL '1 day' AS month_start,
		unnest_value as value,
		index
		
FROM agg 
CROSS JOIN UNNEST(summed_array) WITH ORDINALITY AS u(unnest_value, index)

