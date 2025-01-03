SELECT 
    AVG(avg_events_per_session) AS avg_events_per_session
FROM 
    sessionized_results
WHERE 
    host LIKE '%techcreator.io';
