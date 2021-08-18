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

select *
from app_store_apps;

SELECT apple.name AS apple_apps, apple.rating, apple.review_count, android.name AS android_apps, android.rating, android.review_count, (((round((apple.rating/5),1)*120)+12)*2500) + (((round((android.rating/5),1)*120)+12)*2500) as gross
FROM (SELECT * from app_store_apps) AS apple
full join play_store_apps as android
on apple.name = android.name
where apple.name is not null and apple.rating is not null;






