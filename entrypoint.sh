#!/bin/bash
set -e

# Si /var/www/html n'a pas d'index.php, on initialise
[ ! -f /var/www/html/index.php ] && cp -a /opt/itop/. /var/www/html/

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

exec "apache2-foreground" "$@"