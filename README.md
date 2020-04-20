# php-fpm Dockerfile and conf optimized for Nextcloud

The [Nextcloud](https://nextcloud.com/) Docker images from hub.docker.com, either [the official](https://hub.docker.com/_/nextcloud "nextcloud official docker image") or the 3rd-party like [linuxserver.io](https://hub.docker.com/r/linuxserver/nextcloud "nextcloud docker image from linuxserver.io"), use php with default configurations, which is not optimized to run a complicated and resource consuming application like Nextcloud in a production environment.

I integrated the [recommended configurations](https://docs.nextcloud.com/server/18/admin_manual/installation/server_tuning.html) from Nextcloud document with [php:fpm-alpine](https://hub.docker.com/_/php) as base image.

Please be aware, after build, the image has only php-fpm runtime environment, has no Nextcloud source code inside. You have to download Nextcloud server package and extract into the mapped folder. See the below usage section.

## 1. build the image

``` bash
$ git clone https://github.com/fishingsun/phpfpm-nextcloud-docker.git
$ cd phpfpm-nextcloud-docker
$ docker build -t php:7.4fpm-alpine .
```

If your local Docker environment has no default bridge network, please add `--network` option, for example:
``` bash
$ docker build --network ipvlan -t php:7.4fpm-alpine .
```

After compiled successfully, the new image should be listed in local docker:
``` bash
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
php                    7.4fpm-alpine       97e8492c353d        5 minutes ago       267MB
php                    fpm-alpine          f2a53c8e8392        2 days ago          71.4MB
```

## 2. use the image

Create the working folder:
``` bash
$ sudo mkdir -p /srv/phpfpm-apps/{nextcloud,nextcloud-data}
$ sudo chown -R www-data:www-data /srv/phpfpm-apps
```

Run:
``` bash
$ docker run --name phpfpm \
    --network ipvlan --ip=192.168.0.204 \
    -v /srv/phpfpm-apps:/var/www/html \
    --restart unless-stopped \
    -d php:7.4fpm-alpine
```

Go to https://nextcloud.com/install/ and download Nextcloud server package, and extract into `/srv/phpfpm-apps/nextcloud` folder.

Of course, you need a reverse proxy, pointing to `192.168.0.204:9000` in the above example case. Recommend Caddy or Nginx.

