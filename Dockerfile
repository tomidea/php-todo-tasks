FROM php:7.1-apache
LABEL Creator="Gabriel Akinmoyero"
COPY . /home
COPY config.conf /etc/apache2/sites-enabled
WORKDIR /home
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
 && php artisan migrate
EXPOSE 80
# ENTRYPOINT [ "service", "apache2", "start"]
CMD [ "php", "artisan", "serve" ]