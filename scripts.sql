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


SELECT apple.name AS apple_apps, apple.rating, android.name AS android_apps, android.rating,apple_lifespan,android_lifespanrevenue_minus_cost
FROM app_store_apps AS apple
inner join play_store_apps as android
on apple.name = android.name;







maximize rating, installs, review count, 