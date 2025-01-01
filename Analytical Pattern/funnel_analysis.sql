-- aim is to find the percentage of people that visited and actualy sign up to the site 
-- the is funneling 
-- firstly removing the duplicate using CTE 
with deduped_events as (
	select 
		user_id,
		url,
		event_time,
		DATE(event_time) as event_date
	from events
	where user_id is not null
-- and url in ('/signup', '/login')
	group by 1,2,3,4
),
	selfjoined as (
	select d1.user_id, d1.url, 
	d2.url as destination_url, d1.event_time, d2.event_time
	from deduped_events d1 
-- performing self join to know if they sign u the same time they visited the signup page
	join deduped_events d2 
	on d1.user_id = d2.user_id
	and d1.event_date = d2.event_date 
	and d2.event_time > d1.event_time
	-- and d1.url <> d2.
-- The above code an the code below do the same thing trying to filter out where d1 usrl 
--  and d2 url are not the same 
-- where d1.url = '/signup' and d2.url = '/login'
	-- where d1.url = '/signup'
),
	Convert_user_number as (
	select 
		user_id,
		url,
		count(1) as number_of_hit,
	-- The below is users that converted from signup to login
		sum(case when destination_url = '/login' then 1 else 0 end) as converted
	from selfjoined
	group by 1, 2
 )
 -- The conversion rate of user that visit
 -- remove some filter from the selfjoin we can get the number of all hits
select
	url,
	sum(number_of_hit) as num_hit,
	sum(converted) as num_converted,
	cast(sum(converted) as real)/count(number_of_hit) as percent_converted
from Convert_user_number
group by 1
having sum(number_of_hit) > 500 
-- and sum(converted) > 0

	