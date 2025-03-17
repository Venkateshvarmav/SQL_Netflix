# Netflix Movies and TV Shows Data Analysis using SQL

## Overview

This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

* Analyze the distribution of content types (movies vs TV shows).
* Identify the most common ratings for movies and TV shows.
* List and analyze content based on release years, countries, and durations.
* Explore and categorize content based on specific criteria and keywords.

## Schema

```sql
DROP TABLE IF EXISTS netflix;
```

```sql
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
```

## Business Problems and Solutions

1. **Count the Number of Movies vs TV Shows**

```sql
SELECT
	  TYPE,
	  COUNT(*)
FROM
	  NETFLIX
GROUP BY 1
```

2. **Find the Most Common Rating for Movies and TV Shows**

```sql
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
```

3. **List All Movies Released in a 2020**

```SQL
SELECT
	*
FROM
	NETFLIX
WHERE
	RELEASE_YEAR = '2020'
```

4. **Find the Top 5 Countries with the Most Content on Netflix**

```sql
with COUNTRIES AS (
		SELECT
			TRIM(UNNEST(STRING_TO_ARRAY(COUNTRY, ','))) AS COUNTRY,
			COUNT(SHOW_ID)
		FROM
      NETFLIX
		GROUP BY 1
		ORDER BY 2 DESC
	)
SELECT * FROM	COUNTRIES
WHERE
	COUNTRY IS NOT NULL
LIMIT 5;
```

5.**Identify the Longest Movie**

```sql
select * from netflix
where 
	type = 'Movie' 
and 
	duration is not null
order by split_part(duration,' ',1)::INT desc
```

6. **Find Content Added in the Last 5 Years**

```sql
select * from	netflix
where 
	to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'
```

7. **Find All Movies/TV Shows by Director 'Rajiv Chilaka'**

```sql
with director_name_cte as(
	select
    *,
	  unnest(string_to_array(director,',')) as director_name from netflix
	)
select * from director_name_cte
where 
	director_name = 'Rajiv Chilaka'
```

8. **List All TV Shows with More Than 5 Seasons**

```sql
with season_count_cte as
	(
	  select
      *,
	    split_part(duration,' ',1)::INT as seasons from netflix
    where 
	    type = 'TV Show'
  )
select * from season_count_cte
where seasons > 5
order by 2 desc  
```

9. **Count the Number of Content Items in Each Genre**

```sql
select 
	trim(unnest(string_to_array(listed_in,','))) as genre,
	count(*) as Total_Content 
from 
	netflix
group by 1
order by 2 desc;
```

10. **Find each year and the average numbers of content release in India on netflix.**

```sql
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
```
11. **List All Movies that are Documentaries**

```sql
with genre_cte as(
	select 
	*,
	unnest(string_to_array(listed_in,',')) as genre 
from 
	netflix
)
select * from genre_cte 
where genre LIKE '%Documentaries';
```

                            **OR**

```sql
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```

12. **Find All Content Without a Director**

```sql
select * from netflix
where director is null
```

13. **Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years**

```sql
select * from netflix
where 
	casts like '%Salman Khan%' 
and 
	release_year >= extract(year from current_date) - 10
```

14.**Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies released in India** 

```sql
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
```

15. **Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords**

```sql
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
```

## Findings and Conclusion

* **Content Distribution**: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
* **Common Ratings**: Insights into the most common ratings provide an understanding of the content's target audience.
* **Geographical Insights**: The top countries and the average content releases by India highlight regional content distribution.
* **Content Categorization**: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

## Author - Venkatesh Varma V

This project is part of my portfolio, showcasing my SQL skills essential for data analyst roles.

