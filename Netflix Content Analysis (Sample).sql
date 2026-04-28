SELECT * FROM netflix.netflix_titles;

CREATE TABLE netflix_stagging AS 
SELECT * FROM netflix_titles;
-- FIND duplicate and delete 
SELECT *, 
row_number() OVER(PARTITION BY type,title,director,cast,country,country,date_added,release_year,rating,duration,listed_in)
FROM  netflix_stagging;

WITH netflix_stagging AS 
(SELECT *, 
row_number() OVER(PARTITION BY type,title,director,cast,country,country,date_added,release_year,rating,duration,listed_in) 
as row_num
FROM  netflix_titles )
SELECT *
FROM netflix_stagging 
WHERE row_num>1;
-- 
SELECT date_added,
STR_TO_DATE(date_added,'%M %d,%Y') AS clean_date_added
FROM netflix_stagging;
 
 SELECT * 
 FROM netflix_stagging
 WHERE STR_TO_DATE( date_added,'%M %d,%Y') IS NULL;
 
 UPDATE netflix_stagging
 SET date_added = STR_TO_DATE( date_added,'%M %d,%Y') 
 WHERE STR_TO_DATE( date_added,'%M %d,%Y') IS NOT NULL;
  
  ALTER  TABLE netflix_stagging 
  MODIFY date_added DATE;
  
 UPDATE netflix_stagging
 SET type = CASE 
                WHEN duration LIKE '%min%' THEN 'movie'
                WHEN duration LIKE '%season%' THEN 'Tv show'
                ELSE type 
END 
WHERE type IS NULL;

 SELECT
     CASE 
       WHEN duration LIKE '%min%' THEN 'movie'
       WHEN duration LIKE '%season%' THEN 'TV show'
     END  AS duration_type,
   SUBSTRING_INDEX(duration , ' ' ,1) AS duration_value
	 FROM netflix_stagging;
     
     ALTER TABLE netflix_stagging
     ADD COLUMN duration_value INT;
     
     UPDATE netflix_stagging 
     SET duration_value=CAST( SUBSTRING_INDEX(TRIM(duration) , ' ' ,1) AS UNSIGNED)
     WHERE duration IS NOT NULL
      AND TRIM(duration) != ' ';
 -- total_content_available_on_Netflix
 SELECT COUNT(*)
 FROM netflix_stagging;
 
 -- top_10_release_year 
 SELECT COUNT(*)  AS total,release_year
 FROM netflix_stagging
 GROUP BY release_year
 ORDER BY release_year DESC 
 LIMIT 10;
 
 -- top_10_type_shows
 SELECT type, COUNT(*)*100.0 /SUM(COUNT(*)) OVER() AS percentage
 FROM netflix_stagging
 GROUP BY type 
 ORDER BY percentage DESC;
 
 -- top_10_genre 
 SELECT listed_in , COUNT(*) AS TOTAL
 FROM netflix_stagging
 GROUP BY listed_in
 ORDER BY TOTAL DESC 
 LIMIT 10;
 
 -- TREND 
 SELECT release_year, 
 COUNT(*) AS total,
COUNT(*)-LAG(COUNT(*)) OVER(ORDER BY release_year) AS Growth
 FROM netflix_stagging
 GROUP BY release_year 
 ORDER BY release_year ASC;
 