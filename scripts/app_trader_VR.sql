-- gross revenue
with apple_revenue as (select (rating * 24)+12 
					   from app_store_apps);
select name, genres, rating, round((rating/5),1)*5 as rating_rounded, (round((rating/5),1)*120)+12 as lifespan_in_months, ((round((rating/5),1)*120)+12)*2500 as net, apple_revenue
from play_store_apps
where rating is not null
order by net desc;

select rating, round((rating/5),1)*5 as rating_rounded
from play_store_apps;

select *
from play_store_apps;

select 
from app_store_apps as apple
inner join play_store_apps;


SELECT
	apple_apps as app_in_both_stores, trunc(weighted_rev_count) as weighted_rev_count, cast(lifespan_mos as int) as lifespan_mos, cast(gross as money) as gross, 
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
inner join play_store_apps as android
	on apple.name = android.name
where apple.name is not null and apple.rating is not null and android.name is not null and android.rating is not null) as eval
where weighted_rev_count <500000
order by profit desc;






