with cde_1 as (select name, genres, cast(replace(price,'$','') as numeric) as price_1
			  from play_store_apps
			  where cast(replace(price,'$','') as numeric)= 0.00)
select a.primary_genre,a.name, p.genres
from app_store_apps as a
right join play_store_apps as p
on a.name = p.name
where a.price = 0.00
order by a.rating desc



select cast (replace (price, '$', '') numeric (5,2))
from play_store_apps


Select a_sub.rating_cato,p_sub.rating_cato, count (distinct a_sub.name)
from (select name, case when rating > 4.0 then 'good'
	  when rating between 3.5 and 4.0 then 'avg'
	  else 'not good' end as rating_cato
from app_store_apps) as a_sub
full join (select name, case when rating > 4.0 then 'good'
	  when rating between 3.5 and 4.0 then 'avg'
	  else 'not good' end as rating_cato
from play_store_apps) as p_sub
on a_sub.name = p_sub.name
group by a_sub.rating_cato, p_sub.rating_cato
order by a_sub.rating_cato asc

select sub_p.Rating_cata, count (distinct sub_p.name) 
from (select name, case when rating > 4.0 then 'Good'
	  when rating between 3.5 and 4.0 then 'Avg'
	  else 'Not good' end as Rating_cata
	 from play_store_apps) as sub_p
group by sub_p.Rating_cata
order by count desc

select sub_a.Rating_cata, count (distinct sub_a.name) 
from (select name, case when rating > 4.0 then 'Good'
	  when rating between 3.5 and 4.0 then 'Avg'
	  else 'Not good' end as Rating_cata
	 from app_store_apps) as sub_a
group by sub_a.Rating_cata
order by count desc



