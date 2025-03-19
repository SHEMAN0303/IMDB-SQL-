USE imdb;
# 1). Count the total number of records in each table of the database.
SELECT 'movie' AS TableName, COUNT(*) AS RecordsCount FROM movie
UNION ALL
SELECT 'genre', COUNT(*) FROM genre
UNION ALL
SELECT 'director_mapping', COUNT(*) FROM director_mapping
UNION ALL
SELECT 'role_mapping', COUNT(*) FROM role_mapping
UNION ALL
SELECT 'names', COUNT(*) FROM names
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings;

# 2). Identify which columns in the movie table contain null values
SELECT id, title, worlwide_gross_income,country,languages,production_company
FROM movie
WHERE worlwide_gross_income IS NULL AND country IS NULL AND languages IS NULL AND production_company IS NULL AND id IS NULL;

# 3). Determine the total number of movies released each year, and analyze how the trend changes month-wise
SELECT 
    YEAR(date_published) AS Year, 
    MONTH(date_published) AS Month, 
    COUNT(*) AS TotalMovies
FROM 
    movie
GROUP BY 
    YEAR(date_published), 
    MONTH(date_published)
ORDER BY 
    Year, 
    Month;
    
# 4). How many movies were produced in either the USA or India in the year 2019?
SELECT country,
    COUNT(*) AS TotalMovies
FROM 
    Movie
WHERE country IN ('USA','India') 
    AND YEAR(date_published) = 2019
    GROUP BY country;

#5. List the unique genres in the dataset, and count how many movies belong exclusively to one genre.
    SELECT 
    genre AS UNIQUEGENRES, 
    COUNT(movie_id) AS MovieCount
FROM 
    genre
GROUP BY 
    genre
HAVING 
    COUNT(movie_id)>1;
    
#6). Which genre has the highest total number of movies produced?
SELECT 
    genre, 
    COUNT(movie_id) AS TotalMovies
FROM 
    genre
GROUP BY 
    genre
ORDER BY 
    TotalMovies DESC
LIMIT 1;

#7). Calculate the average movie duration for each genre.
SELECT 
    g.genre, 
    AVG(m.duration) AS AverageDuration
FROM 
    movie m
JOIN 
    genre g ON m.id = g.movie_id
GROUP BY 
    g.genre;

# 8). Identify actors or actresses who have appeared in more than three movies with an average rating below 5.
SELECT n.name, COUNT(r.movie_id) AS movie_count, AVG(r.avg_rating) AS avg_rating
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
JOIN ratings r ON rm.movie_id = r.movie_id
GROUP BY n.name
HAVING COUNT(r.movie_id) > 3 AND AVG(r.avg_rating) < 5;

#9. Find the minimum and maximum values for each column in the ratings table, excluding the movie_id column.
SELECT
    MIN(avg_rating) AS min_average_rating,
    MAX(avg_rating) AS max_average_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM ratings;

# 10). Which are the top 10 movies based on their average rating?
SELECT m.title, r.avg_rating
FROM movie m
JOIN ratings r ON m.id = r.movie_id
ORDER BY r.avg_rating DESC
LIMIT 10;

# 11). Summarize the ratings table by grouping movies based on their median ratings.
SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating;

# 12).How many movies, released in March 2017 in the USA within a specific genre, had more than 1,000 votes?
SELECT g.genre, COUNT(m.id) AS movie_count
FROM Movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE m.date_published BETWEEN '2017-03-01' AND '2017-03-31'
AND m.country = 'USA'
AND r.total_votes > 1000
GROUP BY g.genre;

# 13). Find movies from each genre that begin with the word “The” and have an average rating greater than 8.
SELECT
genre.genre,
movie.title,
ratings.avg_rating
FROM genre JOIN movie ON genre.movie_id = movie.id JOIN ratings ON  movie.id = ratings.movie_id 
WHERE movie.title LIKE 'THE%' AND ratings.avg_rating > 8 ;

# 14).Of the movies released between April 1, 2018, and April 1, 2019, how many received a median rating of 8?
SELECT COUNT(movie_id) AS movie_count
FROM ratings r
JOIN movie m ON r.movie_id = m.id
WHERE r.median_rating = 8
AND m.date_published BETWEEN '2018-04-01' AND '2019-04-01';

# 15). Do German movies receive more votes on average than Italian movies?
SELECT 
    languages,
    AVG(r.total_votes) AS average_votes
FROM 
    movie m
JOIN 
    ratings r ON m.id = r.movie_id
WHERE 
    m.languages IN ('German', 'Italian')
GROUP BY 
    m.languages;

# 16). Identify the columns in the names table that contain null values
SELECT 'id' AS column_name, COUNT(*) AS null_count 
FROM names
WHERE id IS NULL
union all
SELECT 'name' AS column_name, COUNT(*) AS null_count 
FROM names
WHERE name IS NULL
union all
SELECT 'height' AS column_name, COUNT(*) AS null_count 
FROM names
WHERE height IS NULL
union all
SELECT 'date_of_birth' AS column_name, COUNT(*) AS null_count 
FROM names
WHERE date_of_birth IS NULL
union all
SELECT 'known_for_movies' AS column_name, COUNT(*) AS null_count 
FROM names
WHERE known_for_movies IS NULL;

# 17.) Who are the top two actors whose movies have a median rating of 8 or higher? 
SELECT n.name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN ratings r ON rm.movie_id = r.movie_id
WHERE r.median_rating >= 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;

# 18). Which are the top three production companies based on the total number of votes their movies received? 
SELECT m.production_company, SUM(r.total_votes) AS total_votes
FROM movie m
JOIN ratings r 
ON m.id = r.movie_id
GROUP BY m.production_company
ORDER BY total_votes DESC
LIMIT 3;

# 19). How many directors have worked on more than three movies?
SELECT COUNT(*) AS DIRECTORS
FROM (
    SELECT name_id,
    COUNT(movie_id)
    FROM director_mapping
    GROUP BY name_id
    HAVING COUNT(movie_id) > 3
) AS directors_with_more_than_three_movies;

# 20). Calculate the average height of actors and actresses separately.
SELECT rm.Category, AVG(n.height) AS average_height
FROM names n
JOIN role_mapping rm ON n.id = rm.name_id
WHERE rm.Category IN ('actor', 'actress')
GROUP BY rm.Category;

# 21). List the 10 oldest movies in the dataset along with their title, country, and director. 
SELECT m.title, m.country, n.name AS director_name, m.date_published
FROM movie m
JOIN director_mapping dm ON m.id = dm.movie_id
JOIN names n ON dm.name_id = n.id
ORDER BY m.date_published 
LIMIT 10;

#  22). List the top 5 movies with the highest total votes, along with their genres
SELECT m.title, g.genre, r.total_votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id JOIN genre g ON r.movie_id = g.movie_id
ORDER BY r.total_votes DESC
LIMIT 5;

# 23). Identify the movie with the longest duration, along with its genre and production company.
SELECT m.title,m.production_company, m.duration,g.genre
FROM movie m
join genre g on m.id=g.movie_id
ORDER BY m.duration DESC
LIMIT 1;

# 24). Determine the total number of votes for each movie released in 2018.
SELECT m.title, SUM(r.total_votes) AS total_votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE m.year = 2018
GROUP BY m.title;

# 25). What is the most common language in which movies were produced?
SELECT languages, COUNT(*) AS movie_count
FROM movie
GROUP BY languages
ORDER BY  COUNT(*) DESC LIMIT 1;

