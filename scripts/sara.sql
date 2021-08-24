WITH both_stores_data AS (
		SELECT DISTINCT apple.name, apple.price AS apple_purchase_cost, android.price AS android_purchase_cost,
		CAST(apple.price AS money) + CAST(android.price AS money) AS total_cost,
 		ROUND(((apple.rating + android.rating)/2),2) AS avg_rating,
 		apple.primary_genre AS app_genre, android.genres AS android_genre,
		CAST(apple.review_count AS int) AS app_review_count, CAST(android.review_count AS int) AS and_review_count
FROM app_store_apps AS apple
LEFT JOIN play_store_apps AS android
ON apple.name = android.name),
investment_cost AS (
		SELECT *,
		CASE WHEN total_cost > '1' THEN total_cost * '10000'
		ELSE '1000' END AS investment_cost
		FROM both_stores_data),
		
both_stores_avg_rating AS (
		SELECT *,
		CASE WHEN avg_rating BETWEEN 0 AND 0.24 THEN 0
						WHEN avg_rating BETWEEN 0.25 and 0.74 THEN 0.50
						WHEN avg_rating BETWEEN 0.75 and 1.24 THEN 1.00
						WHEN avg_rating BETWEEN 1.25 and 1.74 THEN 1.50
						WHEN avg_rating BETWEEN 1.75 and 2.24 THEN 2.00
						WHEN avg_rating BETWEEN 2.25 and 2.74 THEN 2.50
						WHEN avg_rating BETWEEN 2.75 and 3.24 THEN 3.00
						WHEN avg_rating BETWEEN 3.25 and 3.74 THEN 3.50
						WHEN avg_rating BETWEEN 3.75 and 4.24 THEN 4.00
						WHEN avg_rating BETWEEN 4.25 and 4.74 THEN 4.50
					    WHEN avg_rating BETWEEN 4.75 and 5.00 THEN 5.00
 						END as avg_rating_rounded
			FROM investment_cost)
			
SELECT *,
		CASE WHEN avg_rating_rounded > 0 THEN ((avg_rating_rounded * 2) +1)
		ELSE 1 END AS expected_app_lifestpan_years
FROM both_stores_avg_rating
WHERE app_genre = 'Games' AND avg_rating IS NOT NULL AND app_review_count > 100000
	AND and_review_count > 100000
ORDER BY investment_cost DESC;