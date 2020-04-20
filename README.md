# php-fpm Dockerfile and conf optimized for Nextcloud

The [Nextcloud](https://nextcloud.com/) Docker images from hub.docker.com, either [the official](https://hub.docker.com/_/nextcloud "nextcloud official docker image") or the 3rd-party like [linuxserver.io](https://hub.docker.com/r/linuxserver/nextcloud "nextcloud docker image from linuxserver.io"), use php with default configurations, which is not optimized to run a complicated and resource consuming application like Nextcloud in a production environment.

I integrated the [recommendation configurations](https://docs.nextcloud.com/server/18/admin_manual/installation/server_tuning.html) from Nextcloud document with [php:fpm-alpine](https://hub.docker.com/_/php) as base image.
