#!/bin/sh

echo "ServerName localhost" >> /etc/apache2/apache2.conf

mkdir -p /var/www/eternal
echo "jalur /eternal milik Obladi" > /var/www/eternal/index.html

cat << 'EOF' > /etc/apache2/sites-available/desmond-eternal.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    # Pemetaan jalur /eternal ke lokasi direktori fisik
    Alias /eternal /var/www/eternal

    <Directory /var/www/eternal>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite desmond-eternal.conf

service apache2 restart