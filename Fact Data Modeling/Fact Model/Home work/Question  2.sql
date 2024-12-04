CREATE TABLE user_devices_cumulated (
	user_id text,            
    browser_type TEXT,         
    device_activity DATE[],    
 	date date, 
    PRIMARY KEY (user_id, browser_type, date)
)
