--find profit FIXEDDD

SELECT distinct apple.name AS app_name, apple.rating as apple_rating, 
	android.rating as android_rating,
	apple.price as apple_price,android.price as android_price,
	apple.primary_genre as apple_genre, android.genres as android_genre,
	12*(1+(2*round(android.rating/5,1)*5)) AS android_lifespan,
	12*(1+(2*round(apple.rating/5,1)*5)) AS apple_lifespan,
	2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5,1)*5))) AS revenue,
CASE WHEN apple.price > 1
		THEN (apple.price * 10000)
		else 10000 end +
	Case WHEN CAST(REPLACE (android.price, '$','') AS numeric) > 1 
		THEN (CAST(REPLACE (android.price, '$','') AS numeric) * 10000)
		ELSE 10000 END as initial_cost,
	1000 * case when 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5)) 
	then 12*(1+(2*round(apple.rating/5,1)*5))
	else 12*(1+(2*round(android.rating/5,1)*5)) END AS recurring_cost,
CAST(2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5,1)*5))) - 
	(CASE WHEN apple.price > 1
		THEN (apple.price * 10000)
		else 10000 end +
	Case WHEN CAST(REPLACE (android.price, '$','') AS numeric) > 1 
		THEN (CAST(REPLACE (android.price, '$','') AS numeric) * 10000)
		ELSE 10000 END) - 1000 * CASE WHEN 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5)) 
									THEN 12*(1+(2*round(apple.rating/5,1)*5))
									ELSE 12*(1+(2*round(android.rating/5,1)*5)) END AS MONEY) AS profit
FROM app_store_apps AS apple
inner join play_store_apps as android
	on apple.name = android.name
ORDER BY profit DESC;



--Categories worth focusing on
SELECT apple.primary_genre, count(distinct apple.name) as count_apps_both_stores, 
	round(avg(apple.rating),1) as apple_rating,
	 round(avg(android.rating),1) as android_rating,
	round(avg((android.rating+apple.rating)/2),1) as combined_avg_rating
FROM app_store_apps AS apple
inner join play_store_apps as android
	on apple.name = android.name
group by apple.primary_genre
having count(distinct apple.name)>=10
order by combined_avg_rating DESC;


--gaming apps ranked
Select app_name, profit, rank() over (order by profit DESC), overall_rank, apple_content, android_content
from
(SELECT app_name, profit, rank() over (order by profit DESC) AS overall_rank, android_category, apple_genre, android_content, apple_content
from (SELECT distinct apple.name AS app_name, apple.rating as apple_rating, 
	android.rating as android_rating, apple.content_rating as apple_content, android.content_rating as android_content,
	apple.price as apple_price,android.price as android_price,
	apple.primary_genre as apple_genre,android.category as android_category, android.genres as android_genre,
	12*(1+(2*round(android.rating/5,1)*5)) AS android_lifespan,
	12*(1+(2*round(apple.rating/5,1)*5)) AS apple_lifespan,
	2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5,1)*5))) AS revenue,
CASE WHEN apple.price > 1
		THEN (apple.price * 10000)
		else 10000 end +
	Case WHEN CAST(REPLACE (android.price, '$','') AS numeric) > 1 
		THEN (CAST(REPLACE (android.price, '$','') AS numeric) * 10000)
		ELSE 10000 END as initial_cost,
	1000 * case when 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5)) 
	then 12*(1+(2*round(apple.rating/5,1)*5))
	else 12*(1+(2*round(android.rating/5,1)*5)) END AS recurring_cost,
CAST(2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5,1)*5))) - 
	(CASE WHEN apple.price > 1
		THEN (apple.price * 10000)
		else 10000 end +
	Case WHEN CAST(REPLACE (android.price, '$','') AS numeric) > 1 
		THEN (CAST(REPLACE (android.price, '$','') AS numeric) * 10000)
		ELSE 10000 END) - 1000 * CASE WHEN 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5)) 
									THEN 12*(1+(2*round(apple.rating/5,1)*5))
									ELSE 12*(1+(2*round(android.rating/5,1)*5)) END AS MONEY) AS profit
FROM app_store_apps AS apple
inner join play_store_apps as android
	on apple.name = android.name
WHERE cast(apple.review_count as int) + android.review_count <= 500000
ORDER BY profit DESC
) as subquery) as subquery2
where android_category = 'GAME' OR apple_genre = 'Games'
LIMIT 75;




--review count and content rating


SELECT apple.name AS app_name, apple.content_rating as apple_rating, android.content_rating AS android_content,
cast(apple.review_count AS int) AS apple_review_count, android.review_count AS android_review_count
FROM app_store_apps AS apple
inner join play_store_apps as android
	on apple.name = android.name;

SELECT apple.content_rating as apple_rating,
	round(avg(cast(apple.review_count AS int)),0) AS apple_review_count,
 	round(avg(android.review_count),0) AS android_review_count 
FROM app_store_apps AS apple
inner join play_store_apps as android
	on apple.name = android.name
GROUP BY apple_rating
Order BY android_review_count DESC;


--Vamsi

SELECT
	apple_apps as app_in_both_stores, apple_rating, android_rating, apple_price, android_price, 
	apple_genre, android_genre, apple_content_rating, play_content_rating, 
	cast(lifespan_mos as int) as lifespan_mos, cast(gross as money) as gross,
	cast(ad_cost as money) as ad_cost, cast(apple_purchase_cost as money) as apple_purchase_cost,
	cast(android_purchase_cost as money) as android_purchase_cost,
	cast(gross - ad_cost - apple_purchase_cost - android_purchase_cost as money) as profit
FROM
(SELECT
	apple.name AS apple_apps, coalesce(apple.rating,0) as apple_rating, apple.price as apple_price,
 	apple.primary_genre AS apple_genre, android.genres AS android_genre, apple.content_rating AS apple_content_rating, android.content_rating AS play_content_rating,
	android.name AS android_apps, coalesce(android.rating,0) as android_rating, cast(replace(android.price,'$','') as numeric) as android_price,
 	((cast(apple.review_count as numeric) / (cast(apple.review_count as numeric) + cast(android.review_count as numeric)))
 	* cast(apple.review_count as numeric))
 					+
 	((cast(android.review_count as numeric) / (cast(apple.review_count as numeric) + cast(android.review_count as numeric)))
 	* cast(android.review_count as numeric)) as weighted_rev_count,
 	((round((apple.rating/5),1)*120)+12) + ((round((android.rating/5),1)*120)+12) as lifespan_mos,
	(((round((apple.rating/5),1)*120)+12)*2500) + (((round((android.rating/5),1)*120)+12)*2500) as gross,
	case when ((round((apple.rating/5),1)*120)+12) > ((round((android.rating/5),1)*120)+12) then ((round((apple.rating/5),1)*120)+12) * 1000
	 	 when ((round((android.rating/5),1)*120)+12) > ((round((apple.rating/5),1)*120)+12) then ((round((android.rating/5),1)*120)+12) * 1000
	 	 else ((round((android.rating/5),1)*120)+12) * 1000 end as ad_cost,
	case when apple.price <=1 then 10000
		 else apple.price * 10000 end as apple_purchase_cost,
	case when cast(replace(android.price,'$','') as numeric) <=1 then 10000
		 else cast(replace(android.price,'$','') as numeric) * 10000 end as android_purchase_cost 	
FROM (SELECT * from app_store_apps) AS apple
full join play_store_apps as android
	on apple.name = android.name
where apple.name is not null and apple.rating is not null and android.name is not null and android.rating is not null) as eval
where weighted_rev_count <500000
order by profit desc;

--Jose

WITH both_stores_data AS (
		SELECT DISTINCT apple.name, apple.price AS apple_purchase_cost, android.price AS android_purchase_cost,
		CAST(apple.price AS money) + CAST(android.price AS money) AS total_cost,
 		ROUND(((apple.rating + android.rating)/2),2) AS avg_rating,
 		apple.primary_genre AS app_genre, android.genres AS android_genre
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
ORDER BY investment_cost DESC;