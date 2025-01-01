-- Creating DDL for the table to be used 
-- This table will also be usd fr survival accounting 
 CREATE TABLE users_growth_accounting (
     user_id TEXT,
     first_active_date DATE,
     last_active_date DATE,
     daily_active_state TEXT,
     weekly_active_state TEXT,
     dates_active DATE[],
     date DATE,
     PRIMARY KEY (user_id, date)
 );