#!/bin/sh

apt-get install -y php-fpm

a2enmod proxy proxy_http proxy_fcgi

mkdir -p /var/www/eternal
echo "<?php phpinfo();" > /var/www/eternal/index.php
chown -R www-data:www-data /var/www/eternal

# Nyalakan php-fpm dan cari socket-nya otomatis
for s in /etc/init.d/php*-fpm; do $s start; done
sleep 1
SOCK=$(ls /run/php/php*-fpm.sock | head -1)
echo "Socket: $SOCK"

cat << 'EOF' > /etc/apache2/eternal.inc
# Jalur /eternal: jangan diteruskan ke balancer
ProxyPass /eternal !

Alias /eternal /var/www/eternal
<Directory /var/www/eternal>
    Require all granted
    DirectoryIndex index.php index.html
    <FilesMatch "\.php$">
        SetHandler "proxy:unix:SOCK_PATH|fcgi://localhost"
    </FilesMatch>
</Directory>
EOF

sed -i "s#SOCK_PATH#$SOCK#" /etc/apache2/eternal.inc

apache2ctl configtest && service apache2 restart