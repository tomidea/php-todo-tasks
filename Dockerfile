FROM php:7.1-apache
LABEL Creator="tomidea"
COPY . /var/www/html
COPY config.conf /etc/apache2/sites-enabled
WORKDIR /var/www/html
RUN apt-get update \
 && rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-available/000-default.conf \
 && echo "ServerName 127.0.0.1." >> /etc/apache2/apache2.conf \
 && a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests \
 && apachectl configtest \
 && service apache2 restart \
 && apt install -y wget git zip \
 && docker-php-ext-install pdo_mysql pdo mysqli \
 && wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet \
 && mv composer.phar /usr/bin/composer \
 && composer install \
 && chmod -R 777 ./bootstrap/cache/ && chmod -R 777 ./storage && chown -R www-data:www-data ./ \
 && cp .env.sample .env

EXPOSE 80
COPY run /usr/local/bin
# COPY ./wait-for-it.sh /usr/local/bin

RUN chmod +x ./wait-for-it.sh
ENTRYPOINT [ "./wait-for-it.sh", "db:3306", "--", "php", "artisan", "migrate", "--force " ]

EXPOSE 80