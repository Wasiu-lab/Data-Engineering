CREATE TABLE hosts_cumulated (
	user_id text,            
    host TEXT,         
    host_activity_datelist DATE[],    
 	date date, 
    PRIMARY KEY (user_id, host, date)
)