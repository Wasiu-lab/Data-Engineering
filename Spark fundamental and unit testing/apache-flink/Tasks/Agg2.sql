SELECT 
    host,
    AVG(avg_events_per_session) AS avg_events_per_session
FROM 
    sessionized_results
WHERE 
    host IN ('zachwilson.techcreator.io', 'zachwilson.tech', 'lulu.techcreator.io')
GROUP BY 
    host;
