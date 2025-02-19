-- Netflix Project

CREATE TABLE netflix
(
	show_id      VARCHAR(7),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(450)

);

SELECT * from netflix;

SELECT 
DISTINCT type
from netflix;


--Business problems


--1. Count the number of Movies vs TV Shows

SELECT
	type,
	count(*) as total_content
	from netflix
	group by type;


--2. Find the most common rating for movies and TV shows

--WITH

select 
	type,
	rating
	from

(SELECT 
	type,
	rating,
	count(*),
	RANK() OVER(PARTITION by type order by count(*) desc) as ranking
from netflix
GROUP by 1,2) as t1
where ranking =1



--3. List all movies released in a specific year (e.g., 2020)


select *
from netflix
where type='Movie'AND release_year='2020';



--4. Find the top 5 countries with the most content on Netflix



select 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	count(show_id) as total_content
 from netflix
	GROUP by 1
	ORDER by 2 desc
	limit 5;


--5. Identify the longest movie

select * from netflix
	where 
		type='Movie'
		AND
		duration=(select max(duration) from netflix)
		
		
		
--6. Find content added in the last 5 years
select * 
from netflix
where
	TO_DATE(date_added, 'Month DD, YYYY')>= CURRENT_DATe - Interval '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!


select * 
from netflix
where director like'%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons

select *
from
(select *,
	SPLIT_PART(duration,' ',1) as season
from netflix
where type = 'TV Show' )
where season ::NUMERIC>5



--9. Count the number of content items in each genre

select 
	unnest(STRING_TO_ARRAY(listed_in,','))as gener,
	count(show_id) as total_content
	from netflix
	group by 1
	
	
--10.Find each year and the average numbers of content release in India on netflix.


select 
	extract(year from TO_DATE(date_added,'Month DD, YYYY')) as year,
	count(*)as yearly_content,
	ROUND(
	count(*)::numeric/(select count(*) from netflix where country='India')::numeric * 100 ,2)as AVERAGE_CONTENT
from netflix
where country='India'
group by 1




--11. List all movies that are documentaries



select * from netflix
where type ILIKE '%Movie%' and listed_in ILIKE '%Documentaries%'


--12. Find all content without a director

select * from netflix 
where director isnull

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select count(show_id)as number_of_movies from netflix
where 
	casts ILIKE '%salman khan%' and
	release_year> EXTRACT(YEAR from CURRENT_DATE)-10	
	--TO_DATE(date_added, 'Month DD, YYYY')>= CURRENT_DATe - Interval '10 years'
	
	
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	unnest(STRING_TO_ARRAY(casts,','))as actors,
	count(*)as shows 
from netflix
where country ILIKE '%India%' 
and 
type ILIKE '%Movie%'
group by 1
order by 2 desc
limit 10


--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

WITH new_table
as
(
select *,
	CASE
	WHEN description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'BAD CONTENT'
		ELSE 'GOOD CONTENT'
	END category
from netflix
)
select category,
	count(*) as content
from new_table
	group by 1
	

