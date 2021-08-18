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


SELECT apple.name AS apple_apps, apple.rating, android.name AS android_apps, android.rating 
FROM (SELECT * from app_store_apps) AS apple
full join play_store_apps as android
on apple.name = android.name
WHERE apple.name IS NOT NULL;