WITH yesterday AS (
    -- Select data from host_activity_reduced for the current month
    SELECT *
    FROM host_activity_reduced
    WHERE month = DATE_TRUNC('month', '2023-01-02'::DATE)
),
today AS (
    -- Aggregate daily hits and unique visitors from events table for the current date
    SELECT
        host,
        COUNT(1) AS daily_hits,
        COUNT(DISTINCT user_id) AS daily_unique_visitors,
        '2023-01-02'::DATE AS today_date
    FROM events
    WHERE event_time::date = '2023-01-02'::DATE
    GROUP BY host
),
final AS (
    -- Combine data from yesterday and today, ensuring arrays are correctly initialized
    SELECT
        DATE_TRUNC('month', '2023-01-02'::DATE)::DATE AS month,
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

-- Insert or update records in the host_activity_reduced table
INSERT INTO host_activity_reduced (month, host, hit_array, unique_visitors)
SELECT
    f.month,
    f.host,
    f.hit_array,
    f.unique_visitors
FROM final f
ON CONFLICT (month, host) DO UPDATE
SET hit_array = EXCLUDED.hit_array,
    unique_visitors = EXCLUDED.unique_visitors;