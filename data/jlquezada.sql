/*SELECT apple.name AS apple_apps, apple.rating, android.name AS android_apps, android.rating 
FROM (SELECT * from app_store_apps) AS apple
full join play_store_apps as android
on apple.name = android.name
WHERE apple.name IS NOT NULL;*/

/*lifespan = (1 + 2(round(star_rating)))*12

(12*(1+(2*((round(apple_rating/5),1)*5)))) AS apple_lifespan,
(12*(1+(2*((round(android_rating/5),1)*5)))) AS android_lifespan,
(12*(1+(2*((round(apple_rating/5),1)*5)))) AS apple_lifespan

revenue - initial_cost - recurring_cost AS revenue_minus_cost

*/
 
/*SELECT apple.name AS apple_apps, apple.rating, android.name AS android_apps, android.rating, 
FROM (SELECT * from app_store_apps) AS apple
full join play_store_apps as android
on apple.name = android.name
WHERE apple.name IS NOT NULL;*/

/*
Vamsi modified code
WITH sql_table as
(SELECT
	apple_apps as app_in_both_stores, trunc(weighted_rev_count) as weighted_rev_count, cast(lifespan_mos as int) as lifespan_mos,
	cast(gross as money) as gross, cast(ad_cost as money) as ad_cost, cast(apple_purchase_cost as money) as apple_purchase_cost,
	cast(android_purchase_cost as money) as android_purchase_cost,
	cast(gross - ad_cost - apple_purchase_cost - android_purchase_cost as money) as profit
FROM
(SELECT
	apple.name AS apple_apps, coalesce(apple.rating,0) as apple_rating, apple.price as apple_price,
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
inner join play_store_apps as android
	on apple.name = android.name
where apple.name is not null and apple.rating is not null and android.name is not null and android.rating is not null) as eval
where weighted_rev_count <500000
order by profit desc, weighted_rev_count desc)
SELECT app_in_both_stores, weighted_rev_count, lifespan_mos, gross, ad_cost, apple_purchase_cost, android_purchase_cost, profit
FROM
(SELECT
	row_number() over (partition by app_in_both_stores) as row_number,
	*
 FROM sql_table) as duplicate
WHERE row_number = 1
ORDER BY profit desc;
*/

/*
Jeremiah's
SELECT apple.name AS app_name, apple.rating as apple_rating,
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
WHERE android.review_count + CAST(apple.review_count AS int) < 50000
ORDER BY profit DESC;
*/


/*
Project Plan: 
1. Price range per app - make sure we don't have any duplicates
2. Share/Talk about APP ANNIE 2020 report for ideas and additional information to use in our presentation...create categories based 
on reports table of contents. Clean our data to show the financials based on those parameters.

*/

WITH both_stores_data AS (
		SELECT DISTINCT apple.name, apple.price AS apple_purchase_cost, android.price AS android_purchase_cost, 
		CAST(apple.price AS money) + CAST(android.price AS money) AS total_price, 
 		ROUND(((apple.rating + android.rating)/2),2) AS avg_rating, 
 		apple.primary_genre AS apple_genre, android.genres AS android_genre
FROM app_store_apps AS apple
LEFT JOIN play_store_apps AS android
ON apple.name = android.name),

investment_cost AS (
		SELECT *, 
		CASE WHEN total_price > '1' THEN total_price * '10000'
		ELSE '1000' END AS investment_cost
		FROM both_stores_data),

/*profit AS (
		SELECT
		revenue,
		CASE WHEN apple.price > 1 THEN (apple.price * 10000)
			else 10000 end +
		Case WHEN CAST(REPLACE (android.price, '$','') AS numeric) > 1 THEN (CAST(REPLACE (android.price, '$','') AS numeric) * 10000)
			ELSE 10000 END as initial_cost, 1000 * case when 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5))
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
									ELSE 12*(1+(2*round(android.rating/5,1)*5)) END AS MONEY) AS profit),*/
	

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
WHERE total_price IS NOT NULL
ORDER BY apple_genre DESC;



