apple.rating AS apple_rating

android.rating AS android_rating


(2500 * ((1+(2*((round(apple.rating/5),1)*5)))) + (1+(2*((round(android.rating/5),1)*5))))-(initial_cost) - (1000 * (max lifespan))


(12*(1+(2*((round(apple_rating/5),1)*5)))) AS apple_lifespan
(12*(1+(2*((round(android_rating/5),1)*5)))) AS android_lifespan
2500 * (apple_lifespan + android_lifespan) AS revenue

-- initial cost--
case when apple.price > 1 and apple.price >= android.price then (apple_price * 10000)
when android.price > 1 and android.price > apple.price then (android_price * 10000)
else 10000) AS initial_cost


--recurring cost --
(1000 * (case when apple_lifespan > android_lifespan then apple_lifespan
else android_lifespan)) AS recurring_cost


 revenue - initial_cost - recurring_cost AS revenue_minus_cost

--find profit
SELECT apple.name AS apple_apps, apple.rating, 
	android.name AS android_apps, android.rating,
	android.price, apple.price,
	12*(1+(2*round(android.rating/5,1)*5)) AS android_lifespan,
	12*(1+(2*round(apple.rating/5,1)*5)) AS apple_lifespan,
	2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5,1)*5))) AS revenue,
case when apple.price > 1 and apple.price >= cast(replace (android.price, '$','') as numeric) 
	then (apple.price * 10000)
	when cast(replace (android.price, '$','') as numeric) > 1 and cast(replace (android.price, '$','') as numeric) > apple.price 
	then (cast(replace (android.price, '$','') as numeric) * 10000)
	ELSE 10000 END AS initial_cost,
1000 * case when 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5)) 
	then 12*(1+(2*round(apple.rating/5,1)*5))
	else 12*(1+(2*round(android.rating/5,1)*5)) END AS recurring_cost,
CAST(2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5,1)*5))) - 
case when apple.price > 1 and apple.price >= cast(replace (android.price, '$','') as numeric) 
	then (apple.price * 10000)
	when cast(replace (android.price, '$','') as numeric) > 1 and cast(replace (android.price, '$','') as numeric) > apple.price 
	then (cast(replace (android.price, '$','') as numeric) * 10000)
	ELSE 10000 END - 1000 * case when 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5)) 
	then 12*(1+(2*round(apple.rating/5,1)*5))
	else 12*(1+(2*round(android.rating/5,1)*5)) END AS money) AS profit
FROM app_store_apps AS apple
inner join play_store_apps as android
	on apple.name = android.name
ORDER BY profit DESC;



--profit FIXED for double purchase
SELECT apple.name AS apple_apps,
	android.name AS android_apps, 
CAST(2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5,1)*5))) - 
	CASE WHEN apple.price > 1
		THEN (apple.price * 10000)
		else 10000 end +
	Case WHEN CAST(REPLACE (android.price, '$','') AS numeric) > 1 
		THEN (CAST(REPLACE (android.price, '$','') AS numeric) * 10000)
		ELSE 10000 END - 1000 * CASE WHEN 12*(1+(2*round(apple.rating/5,1)*5)) > 12*(1+(2*round(android.rating/5,1)*5)) 
	THEN 12*(1+(2*round(apple.rating/5,1)*5))
	ELSE 12*(1+(2*round(android.rating/5,1)*5)) END AS MONEY) AS profit
FROM app_store_apps AS apple
INNER JOIN play_store_apps AS android
	ON apple.name = android.name
WHERE android.review_count + CAST(apple.review_count AS int) < 50000
ORDER BY profit DESC;



--Vamsis
SELECT
	apple_apps as app_in_both_stores, apple_rating, android_rating, apple_price, android_price, trunc(weighted_rev_count) as weighted_rev_count, cast(lifespan_mos as int) as lifespan_mos, cast(gross as money) as gross,
	cast(ad_cost as money) as ad_cost, cast(apple_purchase_cost as money) as apple_purchase_cost,
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
full join play_store_apps as android
	on apple.name = android.name
where apple.name is not null and apple.rating is not null and android.name is not null and android.rating is not null) as eval
where weighted_rev_count <500000
order by profit desc;








SELECT
	apple_apps as app_in_both_stores, apple_rating, android_rating, apple_price, android_price, trunc(weighted_rev_count) as weighted_rev_count, cast(lifespan_mos as int) as lifespan_mos, cast(gross as money) as gross,
	cast(ad_cost as money) as ad_cost, cast(apple_purchase_cost as money) as apple_purchase_cost,
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
full join play_store_apps as android
	on apple.name = android.name
where apple.name is not null and apple.rating is not null and android.name is not null and android.rating is not null) as eval
where weighted_rev_count <500000
order by profit desc;










replace (android.price, '$','')


revenue - initial_cost - recurring_cost AS revenue_minus_cost


SELECT apple.name AS apple_apps, apple.rating, 
android.name AS android_apps, android.rating,
12*(1+(2*round(android.rating/5, 1)*5)) AS android_lifespan,
12*(1+(2*round(apple.rating/5,1)*5)) AS apple_lifespan,
2500*(12*(1+(2*round(apple.rating/5,1)*5)) + 12*(1+(2*round(android.rating/5, 1)*5))) AS revenue
FROM app_store_apps AS apple
INNER JOIN play_store_apps as android
on apple.name = android.name;


12*(1+(2*round(android.rating/5,1)*5) AS android_lifespan,

maximize rating, installs, review count, 