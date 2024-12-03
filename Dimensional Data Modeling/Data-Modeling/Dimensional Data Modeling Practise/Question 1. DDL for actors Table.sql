select * from actor_films

CREATE TYPE films AS (
    film text,
    votes integer,
    rating real,
    filmid TEXT
);

create type quality_class as enum ('star', 'good', 'average' ,'bad')
drop table actors
create table actors (
    actorid text,
    filmid text,
    current_year integer,
    quality_class quality_class,
    films films [],
    is_active bool,
    primary key (actorid, filmid, current_year)
);