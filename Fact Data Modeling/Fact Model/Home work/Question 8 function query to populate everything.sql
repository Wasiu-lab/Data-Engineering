create table function_table (
		month date,
		host text,
		hit_array integer[],
		unique_visitors integer[],
		primary key(month, host)
		)

create or replace function load_host_activity_reduced_january() returns void
    language plpgsql
as
$$ --do 
DECLARE
    curr_date DATE;
BEGIN
    curr_date := '2023-01-01'::DATE;
    WHILE curr_date <= '2023-01-31'::DATE LOOP
-- possible to use the generate series also for the loop query 
-- FOR curr_date IN SELECT generate_series('2023-01-01'::DATE,
-- '2023-01-31'::DATE, INTERVAL '1 day')::DATE LOOP
        WITH yesterday AS (
            SELECT *
            FROM function_table
            WHERE month = DATE_TRUNC('month', curr_date)
        ),
        today AS (
            SELECT
                host,
                COUNT(1) AS daily_hits,
                COUNT(DISTINCT user_id) AS daily_unique_visitors,
                curr_date AS today_date
            FROM events
            WHERE event_time::date = curr_date
            GROUP BY host
        ),
        final AS (
            SELECT
                DATE_TRUNC('month', curr_date)::DATE AS month,
                COALESCE(y.host, t.host) AS host,
                COALESCE(
                    y.hit_array,
                    ARRAY[]::INTEGER[]
                ) || ARRAY[t.daily_hits] AS hit_array,
                COALESCE(
                    y.unique_visitors,
                    ARRAY[]::INTEGER[]
                ) || ARRAY[t.daily_unique_visitors] AS unique_visitors
            FROM yesterday y
            FULL OUTER JOIN today t ON y.host = t.host
        )

        INSERT INTO function_table (month, host, hit_array, unique_visitors)
        SELECT
            f.month,
            f.host,
            f.hit_array,
            f.unique_visitors
        FROM final f
        ON CONFLICT (month, host) DO UPDATE
        SET hit_array = EXCLUDED.hit_array,
            unique_visitors = EXCLUDED.unique_visitors;

        -- Increment the date by one day
        curr_date := curr_date + INTERVAL '1 day';
-- using the generate series no need to do the increment line 56
    END LOOP;
END;
$$;

alter function load_host_activity_reduced_january() owner to postgres;

select * from function_table
 