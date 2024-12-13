
WITH agg AS (
    SELECT 
        metric_name, 
        month_start,
        ARRAY(
            SUM(metric_array[0]),
            SUM(metric_array[1]),
            SUM(metric_array[2]),
            SUM(metric_array[3])
        ) AS summed_array
    FROM array_matrics
    GROUP BY metric_name, month_start
)
SELECT 
    metric_name,
    DATE_ADD(month_start, index - 1) AS calculated_date,
    exploded_value AS value,
    index
FROM agg
LATERAL VIEW POSEXPLODE(summed_array) AS index, exploded_value
