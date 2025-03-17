CREATE TABLE NETFLIX (
	SHOW_ID VARCHAR(10),
	TYPE VARCHAR(10),
	TITLE VARCHAR(150),
	DIRECTOR VARCHAR(250),
	CASTS VARCHAR(1000),
	COUNTRY VARCHAR(150),
	DATE_ADDED VARCHAR(50),
	RELEASE_YEAR INT,
	RATING VARCHAR(10),
	DURATION VARCHAR(20),
	LISTED_IN VARCHAR(100),
	DESCRIPTION VARCHAR(300)
)
SELECT
	*
FROM
	NETFLIX;

-- Count the Number of Movies vs TV Shows

SELECT
	TYPE,
	COUNT(*)
FROM
	NETFLIX
GROUP BY 1

-- Find the Most Common Rating for Movies and TV Shows
WITH CTE AS (
		SELECT
			TYPE AS TYPE,
			RATING AS RATING,
			COUNT(*) AS NUMBER_OF_SHOWS,
			RANK() OVER (PARTITION BY TYPE ORDER BY COUNT(*) DESC
			) FROM NETFLIX
		GROUP BY 1,2
	)
SELECT
	TYPE,
	RATING,
	NUMBER_OF_SHOWS
FROM CTE
WHERE RANK = 1
	
-- List All Movies Released in a 2020

SELECT
	*
FROM
	NETFLIX
WHERE
	RELEASE_YEAR = '2020'

-- Find the Top 5 Countries with the Most Content on Netflix
WITh COUNTRIES AS (
		SELECT
			TRIM(UNNEST(STRING_TO_ARRAY(COUNTRY, ','))) AS COUNTRY,
			COUNT(SHOW_ID)
		FROM NETFLIX
		GROUP BY 1
		ORDER BY 2 DESC
	)
SELECT
	*
FROM
	COUNTRIES
WHERE
	COUNTRY IS NOT NULL
LIMIT 5;

-- Identify the Longest Movie

select 
	* 
from
	netflix
where 
	type = 'Movie' 
and 
	duration is not null
	order by split_part(duration,' ',1)::INT desc


-- Find Content Added in the Last 5 Years

select 
	*
from
	netflix
where 
	to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'


-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'

with director_name_cte as(
	select *,
	unnest(string_to_array(director,',')) as director_name from netflix
	)
select 
	* 
from 
director_name_cte
where 
	director_name = 'Rajiv Chilaka'

-- List All TV Shows with More Than 5 Seasons
with season_count_cte as
	(
	select *,
	split_part(duration,' ',1)::INT as seasons from netflix
where 
	type = 'TV Show'
)
select 
	* 
from 
	season_count_cte
where seasons > 5
order by 2 desc


-- Count the Number of Content Items in Each Genre

select 
	trim(unnest(string_to_array(listed_in,','))) as genre,
	count(*) as Total_Content 
from 
	netflix
group by 1
order by 2 desc;

-- Find each year and the average numbers of content release in India on netflix.

with countries_cte as (
	select 
		*,
		unnest(string_to_array(country,',')) as countries 
	from 
		netflix
)
select 
	release_year,
	count(show_id) as total_release,
	(count(show_id)::numeric/(select count(show_id) from countries_cte where countries = 'India')::numeric * 100) 
from  
	countries_cte
WHERE countries = 'India'
GROUP BY release_year
order by 2 desc
limit 5;

-- List All Movies that are Documentaries
with genre_cte as(
	select 
	*,
	unnest(string_to_array(listed_in,',')) as genre 
from 
	netflix
)
select * from genre_cte 
where genre LIKE '%Documentaries';


SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';

-- Find All Content Without a Director

select * from netflix
where director is null


-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select * from netflix
where 
	casts like '%Salman Khan%' 
and 
	release_year >= extract(year from current_date) - 10

 -- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies released in India
with actors_cte as(
	select 
		*,
		trim(unnest(string_to_array(casts,','))) as actors,
		trim(unnest(string_to_array(country,','))) as countries 
	from 
		netflix
)
select 
	actors,
	count(*) 
from 
	actors_cte 
where 
	countries = 'India' 
and 
	actors is not null
group by 1
order by 2 desc
limit 10;

-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

select 
case
	when 
		description ilike '%Kill%' or description ilike '%Violence%' then 'Bad'
	else
		'Good'
	end as Category,
	count(*) as number_of_shows
from netflix
group by Category

