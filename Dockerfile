FROM php:8.2-apache AS builder

RUN apt update && apt install -y \
    wget \
    unzip \
    acl \
    && wget https://sourceforge.net/projects/itop/files/latest/download -O /tmp/itop.zip \
    && unzip /tmp/itop.zip "web/*" -d /var/www/html/itop \
    && mv /var/www/html/itop/web/*  /var/www/html/itop \
    && rmdir /var/www/html/itop/web \
    && setfacl -dR -m u:"www-data":rwX /var/www/html/itop/data /var/www/html/itop/log \
    && setfacl -R -m u:"www-data":rwX /var/www/html/itop/data /var/www/html/itop/log \
    && setfacl -m u:"www-data":rwX /var/www/html/itop/ \
    && mkdir /var/www/html/itop/env-production /var/www/html/itop/env-production-build /var/www/html/itop/env-test /var/www/html/itop/env-test-build \
    && chown www-data: /var/www/html/itop/conf /var/www/html/itop/env-production /var/www/html/itop/env-production-build /var/www/html/itop/env-test /var/www/html/itop/env-test-build

FROM php:8.2-apache AS runner

COPY entrypoint.sh /entry.sh
COPY --from=builder /var/www/html/itop /opt/itop

RUN apt update && apt install -y \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    libldap2-dev \
    graphviz \
    mariadb-client \
    && docker-php-ext-install gd mysqli soap zip ldap \
    && docker-php-source extract \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-source delete \
    && echo "upload_max_filesize=60M\npost_max_size=80M\nsession.save_path=\"/tmp\"" > /usr/local/etc/php/conf.d/custom.ini \
    && a2enmod headers \
    && chmod +x /entry.sh \
    && sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf \
    && echo 'RequestHeader set X-Forwarded-Port "443"' >> /etc/apache2/conf-available/forwarded-port.conf \
    && a2enconf forwarded-port

EXPOSE 8080

ENTRYPOINT [ "/entry.sh" ]