# php-fpm Dockerfile and conf optimized for Nextcloud

The [Nextcloud](https://nextcloud.com/) Docker images from hub.docker.com, either [the official](https://hub.docker.com/_/nextcloud "nextcloud official docker image") or the 3rd-party like [linuxserver.io](https://hub.docker.com/r/linuxserver/nextcloud "nextcloud docker image from linuxserver.io"), use php with default configurations, which is not optimized to run a complicated and resource consuming application like Nextcloud in a production environment.

I combined the recommendation configurations from Nextcloud document, and use [php-fpm](https://hub.docker.com/_/php) 
