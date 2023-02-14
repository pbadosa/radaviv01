FROM php:7.4-apache


#RUN apt update && apt install -y git 

WORKDIR /var/www/html
COPY ./ssl /etc/ssl
#COPY ./let /etc/letsencrypt
#RUN git clone https://github.com/WordPress/WordPress.git .

RUN chown -R www-data:www-data /var/www/html

RUN docker-php-ext-install mysqli 
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install -j "$(nproc)" opcache

RUN set -ex; \
  { \
    echo "; Cloud Run enforces memory & timeouts"; \
    echo "memory_limit = -1"; \
    echo "max_execution_time = 0"; \
    echo "; File upload at Cloud Run network limit"; \
    echo "upload_max_filesize = 32M"; \
    echo "post_max_size = 32M"; \
    echo "; Configure Opcache for Containers"; \
    echo "opcache.enable = On"; \
    echo "opcache.validate_timestamps = Off"; \
    echo "; Configure Opcache Memory (Application-specific)"; \
    echo "opcache.memory_consumption = 32"; \
  } > "/usr/local/etc/php/conf.d/docker-php-ram-limit.ini"

#RUN cd /usr/local/etc/php/conf.d/ && echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-ram-limit.ini

RUN apt-get update
RUN apt-get install --yes --force-yes cron g++ gettext libicu-dev openssl libc-client-dev libkrb5-dev libxml2-dev libfreetype6-dev libgd-dev libmcrypt-dev bzip2 libbz2-dev libtidy-dev libcurl4-openssl-dev libz-dev libmemcached-dev libxslt-dev
RUN apt-get install openssh-server -y
RUN apt-get install letsencrypt -y

COPY ./let /etc/letsencrypt

RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2ensite default-ssl.conf

RUN docker-php-ext-configure gd --with-freetype=/usr --with-jpeg=/usr
RUN docker-php-ext-install gd
