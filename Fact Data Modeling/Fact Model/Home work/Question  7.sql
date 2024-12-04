create table host_activity_reduced(
		month date,
		host text,
		hit_array integer[],
		unique_visitors integer[],
		primary key(month, host)
		)
