# php-fpm environment, based-on the official php:fpm-alpine image
# added php features:
#     exif, gd, intl, ldap, opcache, pcntl, pdo_mysql, pdo_pgsql, zip, bz2, gmp,
#     acpu, memcached, redis, imagick, smbclient, gettext
FROM php:fpm-alpine

RUN set -ex; \
    \
    # change to a mirror if needed
    # sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories; \
    # refresh OS
    apk update --no-cache; \
    apk upgrade --no-cache; \
    \
    # install required packages
    apk add --no-cache shadow zlib libjpeg-turbo libpng libxpm \
        ffmpeg imagemagick procps samba-client; \
    \
    # remove useless users and groups
    deluser news; \
    deluser xfs; \
    deluser games; \
    deluser vpopmail; \
    deluser ftp; \
    # change www-data's uid and gid to make IDs are same to host machine
    usermod -u 33 www-data; \
    groupmod -g 33 www-data; \
    \
    # prepare the compilation dependencies
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        autoconf \
        freetype-dev \
        icu-dev \
        libevent-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libxpm-dev \
        libmemcached-dev \
        libxml2-dev \
        libzip-dev \
        openldap-dev \
        pcre-dev \
        postgresql-dev \
        imagemagick-dev \
        libwebp-dev \
        gmp-dev \
        samba-dev \
        bzip2-dev \
        gettext-dev; \
    \
    # gd, ldap needs to configure before install
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-configure ldap; \
    # install php extensions
    docker-php-ext-install -j "$(nproc)" \
        exif \
        gd \
        intl \
        gettext \
        ldap \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gmp \
        bz2; \
    \
    # pecl will claim success even if one install fails, so we need to perform each install separately.
    # attentions: pecl doesn't check version compatibility automatically,
    #             if errors, please specify extension's version to match php's version.
    pecl install apcu; \
    pecl install memcached; \
    pecl install redis; \
    pecl install imagick; \
    pecl install smbclient; \
    \
    # enable extensions from pecl.
    docker-php-ext-enable \
        apcu \
        memcached \
        redis \
        imagick \
        smbclient; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache $runDeps; \
    apk del .build-deps; \
    \
    # ref: https://docs.nextcloud.com/server/18/admin_manual/
    # configure php.ini
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini; \
    sed -i 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 8G/g' /usr/local/etc/php/php.ini; \
    sed -i 's/post_max_size\ =\ 8M/post_max_size\ =\ 8G/g' /usr/local/etc/php/php.ini; \
    sed -i 's/max_input_time\ =\ 60/max_input_time\ =\ 3600/g' /usr/local/etc/php/php.ini; \
    sed -i 's/max_execution_time\ =\ 30/max_execution_time\ =\ 3600/g' /usr/local/etc/php/php.ini; \
    \
    # configure opcache
    { \
        echo 'opcache.enable=1'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.revalidate_freq=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    \
    # configure apcu
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    \
    # configure memory_limit
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini; \
    # configure pdo_mysql
    { \
        echo '[mysql]'; \
        echo 'mysql.allow_local_infile=On'; \
        echo 'mysql.allow_persistent=On'; \
        echo 'mysql.cache_size=2000'; \
        echo 'mysql.max_persistent=-1'; \
        echo 'mysql.max_links=-1'; \
        echo 'mysql.connect_timeout=60'; \
        echo 'mysql.trace_mode=Off'; \
    } >> /usr/local/etc/php/conf.d/docker-php-ext-pdo_mysql.ini; \
    # configure pdo_pgsql
    { \
        echo '[PostgreSQL]'; \
        echo 'pgsql.allow_persistent=On'; \
        echo 'pgsql.auto_reset_persistent=Off'; \
        echo 'pgsql.max_persistent=-1'; \
        echo 'pgsql.max_links=-1'; \
        echo 'pgsql.ignore_notice=0'; \
        echo 'pgsql.log_notice=0'; \
    } >> /usr/local/etc/php/conf.d/docker-php-ext-pdo_pgsql.ini

COPY www.conf /usr/local/etc/php-fpm.d

EXPOSE 9000