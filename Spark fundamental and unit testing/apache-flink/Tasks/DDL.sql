CREATE TABLE sessionized_results (
    session_id VARCHAR,         -- Unique identifier for each session
    ip VARCHAR,                 -- IP address of the user
    host VARCHAR,               -- Hostname the user interacted with
    session_start TIMESTAMP(3), -- Start time of the session
    session_end TIMESTAMP(3),   -- End time of the session
    num_events BIGINT,          -- Number of events in the session
    avg_events_per_session DOUBLE -- Average number of events per session (calculated in job)
) WITH (
    'connector' = 'jdbc',                           -- Use JDBC connector for storage
    'url' = 'jdbc:postgresql://<DB_HOST>:<DB_PORT>/<DB_NAME>', -- PostgreSQL database URL
    'table-name' = 'sessionized_results',          -- Table name in the database
    'username' = 'postgres',                  -- Database username
    'password' = 'postgres',                  -- Database password
    'driver' = 'org.postgresql.Driver'             -- PostgreSQL driver
);
