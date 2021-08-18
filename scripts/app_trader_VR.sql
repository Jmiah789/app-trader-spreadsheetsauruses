SELECT apple.name AS apple_apps, apple.rating, apple.review_count, android.name AS android_apps, android.rating, android.review_count 
FROM (SELECT * from app_store_apps) AS apple
full join play_store_apps as android
on apple.name = android.name
where apple.name is not null and apple.rating is not null






