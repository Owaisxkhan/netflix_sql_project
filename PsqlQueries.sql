-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

-- 1. Count the number of Movies vs TV Shows

SELECT 
		SUM(CASE WHEN type = 'Movie' then 1 ELSE 0 END) AS count_of_movie,
		SUM(CASE WHEN type = 'TV Show' then 1 ELSE 0 END) AS count_of_TVShow
FROM netflix
		

-- 2. Find the most common rating for movies and TV shows

SELECT 
		type,
		rating
FROM
(SELECT 
		type,
		rating,
		count(*),
		RANK() OVER(PARTITION BY type ORDER BY count(*) DESC) AS ranking
FROM netflix
GROUP BY type, rating
) as t1
WHERE 
		ranking = 1


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT 
		*
FROM netflix
WHERE release_year = 2020 AND type = 'Movie'

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
		count(*) as count_of_movies
FROM netflix
GROUP BY new_country
ORDER BY count_of_movies DESC
LIMIT 5;

SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country
FROM netflix

-- 5. Identify the longest movie

SELECT 	
		*
from netflix
where 
		type = 'Movie' AND duration = (select MAX(duration) FROM netflix)


-- 6. Find content added in the last 5 years

SELECT 
		*	
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

SELECT CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT
		*
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons

SELECT
		*
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric > 5

-- 9. Count the number of content items in each genre

SELECT
		UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
		COUNT(show_id) AS total_content	
FROM netflix
GROUP BY 1
ORDER BY 2 DESC


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
select * from netflix
WHERE country = 'India'
SELECT
		EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
		count(*) as yearly_content,
		ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1


-- 11. List all movies that are documentaries

SELECT 
		*
FROM netflix
WHERE listed_in LIKE '%Documentaries%' and type = 'Movie'

-- 12. Find all content without a director

SELECT 
		*
FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


SELECT 
		*
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year> EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
		UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
		COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--    the description field. Label content containing these keywords as 'Bad' and all other 
--    content as 'Good'. Count how many items fall into each category.

WITH new_table AS 
(
SELECT 
		*,
		CASE 
			WHEN description ILIKE '%kill%' OR
				 description ILIKE '%violence' THEN 'Bad_content'
			ELSE 'Good_content'	
		END category
FROM netflix
)
SELECT 
		category,
		COUNT(*) as total_content
FROM new_table
GROUP BY category
