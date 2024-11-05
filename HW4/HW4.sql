-- What is the average length of films in each category? List the results in alphabetic order of categories.
SELECT c.name, AVG(f.length) AS avg_length
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id  -- Join to connect films with categories
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name  -- Group by category to calculate average length per category
ORDER BY c.name;  -- Order results alphabetically by category name



-- Which categories have the longest and shortest average film lengths?
WITH avg_lengths AS (
    SELECT c.name, AVG(f.length) AS avg_length
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    GROUP BY c.name  -- Group by category to calculate average length per category
)
-- Select categories with the longest and shortest average film lengths
SELECT name, avg_length
FROM avg_lengths
WHERE avg_length = (SELECT MAX(avg_length) FROM avg_lengths)  -- Longest average length
   OR avg_length = (SELECT MIN(avg_length) FROM avg_lengths);  -- Shortest average length
   


-- Which customers have rented action but not comedy or classic movies?
SELECT DISTINCT cu.customer_id, cu.first_name, cu.last_name
FROM customer cu
JOIN rental r ON cu.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Action'  -- Only include customers who rented Action movies
  AND cu.customer_id NOT IN (
      -- Exclude customers who rented Comedy or Classic movies
      SELECT cu.customer_id
      FROM customer cu
      JOIN rental r ON cu.customer_id = r.customer_id
      JOIN inventory i ON r.inventory_id = i.inventory_id
      JOIN film_category fc ON i.film_id = fc.film_id
      JOIN category c ON fc.category_id = c.category_id
      WHERE c.name IN ('Comedy', 'Classic')
  );



-- Which actor has appeared in the most English-language movies?
SELECT a.actor_id, a.first_name, a.last_name, COUNT(*) AS film_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id  -- Connect actors with films they appeared in
JOIN film f ON fa.film_id = f.film_id
JOIN language l ON f.language_id = l.language_id  -- Connect films with their languages
WHERE l.name = 'English'  -- Only consider English-language movies
GROUP BY a.actor_id, a.first_name, a.last_name  -- Group by actor to count their movies
ORDER BY film_count DESC  -- Order by the count of films in descending order
LIMIT 1;  -- Return only the actor with the highest count



-- How many distinct movies were rented for exactly 10 days from the store where Mike works?
SELECT COUNT(DISTINCT i.film_id) AS distinct_movies_rented
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN staff s ON r.staff_id = s.staff_id
WHERE s.first_name = 'Mike'  -- Restrict to rentals handled by staff member named Mike
  AND DATEDIFF(r.return_date, r.rental_date) = 10;  -- Only rentals of exactly 10 days
 -- NOTE: query and constraint 6 are incompatible as reviewed in class.



-- Alphabetically list actors who appeared in the movie with the largest cast of actors.
WITH movie_cast_count AS (
    -- Calculate the number of actors in each movie
    SELECT fa.film_id, COUNT(fa.actor_id) AS actor_count
    FROM film_actor fa
    GROUP BY fa.film_id
),
largest_cast_movie AS (
    -- Select the movie with the maximum number of actors
    SELECT film_id
    FROM movie_cast_count
    WHERE actor_count = (SELECT MAX(actor_count) FROM movie_cast_count)
)
-- List actors from the movie with the largest cast, ordered alphabetically
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN largest_cast_movie lcm ON fa.film_id = lcm.film_id
ORDER BY a.first_name, a.last_name;  -- Alphabetical order by actor's first and last name
