 -- Table DDL 
 -- CREATE TABLE users_growth_accounting (
 --     user_id TEXT,
 --     first_active_date DATE,
 --     last_active_date DATE,
 --     daily_active_state TEXT,
 --     weekly_active_state TEXT,
 --     dates_active DATE[],
 --     date DATE,
 --     PRIMARY KEY (user_id, date)
 -- );
 -- the below is somewhat like designing the CTD and we are drafting a a growth accounting analytic
insert into users_growth_accounting
WITH yesterday AS (
    SELECT * FROM users_growth_accounting
    WHERE date = DATE('2023-01-03')
),
     today AS (
         SELECT
            CAST(user_id AS TEXT) as user_id,
            DATE_TRUNC('day', event_time::timestamp) as today_date,
            COUNT(1)
         FROM events
         WHERE DATE_TRUNC('day', event_time::timestamp) = DATE('2023-01-04')
         AND user_id IS NOT NULL
         GROUP BY user_id, DATE_TRUNC('day', event_time::timestamp)
     )

SELECT 
	COALESCE(t.user_id, y.user_id)   as user_id,
-- The below is based on if there is a date in yesterday then the person is returning and if yesterday 
-- is null then it will pick from today making the person a new user 
	COALESCE(y.first_active_date, t.today_date)   AS first_active_date,
-- Last active is the opposite of the first active so if they were actve today then it is the last active date 
-- if not the yesterday is the last active date 
    COALESCE(t.today_date, y.last_active_date)   AS last_active_date,
     CASE
         WHEN y.user_id IS NULL THEN 'New'
-- retained will be when they were active both yesterday and today therefore yday = today 
         WHEN y.last_active_date = t.today_date - Interval '1 day' THEN 'Retained'
-- resurected meaning inactive yday and active today thereb 
         WHEN y.last_active_date < t.today_date - Interval '1 day' THEN 'Resurrected'
-- Churned is when active yesterday and inactive today
-- y.date is the partitioned date
         WHEN t.today_date IS NULL AND y.last_active_date = y.date THEN 'Churned'
         ELSE 'Stale'
     END as daily_active_state,
     CASE
        	WHEN y.user_id IS NULL THEN 'New'
--  for weekly it will have to be last active should be less than 7 days meaning within 7 days they were active
            WHEN y.last_active_date < t.today_date - Interval '7 day' THEN 'Resurrected'

            WHEN
                t.today_date IS NULL
                 AND y.last_active_date = y.date - interval '7 day' THEN 'Churned'
--  Working weekly retained wont be equal to again we we wont use today we will use main date - 7
            WHEN COALESCE(t.today_date, y.last_active_date) + INTERVAL '7 day' >= y.date THEN 'Retained'
     ELSE 'Stale'
     END as weekly_active_state,
     COALESCE(y.dates_active,
        ARRAY []::DATE[])
        || CASE
				WHEN
                   t.user_id IS NOT NULL THEN ARRAY [t.today_date]
                   ELSE ARRAY []::DATE[]
                END AS date_list,
      COALESCE(t.today_date, y.date + Interval '1 day') as date
FROM today t
     FULL OUTER JOIN yesterday y
     ON t.user_id = y.user_id
	 
-- select * from users_growth_accounting