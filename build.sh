docker build -t laravel-platform -f php-7.2-apache-node10/Dockerfile php-7.2-apache-node10
docker build -t laravel-platform:nginx -f php-7.2-nginx-node10/Dockerfile php-7.2-nginx-node10

docker tag laravel-platform liararepo/laravel-platform
docker tag laravel-platform:nginx liararepo/laravel-platform:nginx