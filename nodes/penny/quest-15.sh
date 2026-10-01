#!/bin/sh

apt-get update && apt-get install apache2 -y
mkdir -p /var/www/eternal
echo "Jalur /eternal milik Penny" > /var/www/eternal/index.html

cat << 'EOF' > /etc/apache2/sites-available/penny-eternal.conf
<VirtualHost *:80>
    ServerName penny.k01.com
    
    # DocumentRoot diarahkan ke /var/www agar request /eternal
    # langsung mengarah ke /var/www/eternal
    DocumentRoot /var/www

    <Directory /var/www/eternal>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2ensite penny-eternal.conf
a2dissite 000-default.conf

service apache2 restart