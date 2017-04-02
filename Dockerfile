# https://pkgs.alpinelinux.org/contents?branch=edge&name=cyrus-sasl-dev&arch=armhf&repo=main
# docker-ext-enabled allow:
#   bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl
#   json ldap mbstring mcrypt mssql mysql mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc
#   pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml
#   snmp soap sockets spl standard sybase_ct sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip
FROM php:5.6-fpm-alpine

MAINTAINER Zhiyuan Leong <2121422@qq.com>

ENV TIMEZONE            Asia/Chongqing
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

WORKDIR /tmp

RUN apk --no-cache --update add make autoconf g++ gcc libc-dev curl ca-certificates bash git libmemcached-dev zlib-dev cyrus-sasl-dev tzdata freetype-dev libjpeg-turbo-dev libpng-dev \
  && apk add libressl2.4-libcrypto libressl2.4-libssl yaml-dev --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted --no-cache \
  && apk add gearman-dev --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted --no-cache \
  && cp -r -f /usr/share/zoneinfo/Hongkong /etc/localtime \
  && git clone --branch v3.0.2 git://github.com/phalcon/cphalcon.git \
  && cd cphalcon/build/ \
  && ./install \
  && docker-php-ext-install gd \
  && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \
  && pecl install memcached-2.1.0 \
  && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/memcached.ini \
  && pecl install igbinary-2.0.1 \
  && echo "extension=igbinary.so" > /usr/local/etc/php/conf.d/igbinary.ini \
  && pecl install redis-3.1.1 \
  && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
  && pecl install gearman-1.1.2 \
  && echo "extension=gearman.so" > /usr/local/etc/php/conf.d/gearman.ini \
  && printf "\n" | pecl install yaml-1.3.0 \
  && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/yaml.ini \
  && printf "no\n" | pecl install memcache-3.0.8 \
  && echo "extension=memcache.so" > /usr/local/etc/php/conf.d/memcache.ini \
  && cd /var/www/html \
  && echo "<?php  phpinfo();" > index.php \
  && rm -rf /tmp/*

VOLUME ["/var/www/html"]

WORKDIR /var/www/html

EXPOSE 9000
