#!/bin/sh

apt-get update && apt-get install apache2 -y

mkdir -p /var/www/html/arsip

cat << 'EOF' > /etc/apache2/sites-available/k01-vault.conf
<VirtualHost *:80>
    ServerName obladi.k01.com
    DocumentRoot /var/www/html

    <Directory /var/www/html/arsip>
        Options +Indexes
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

echo "Ini dokumen rahasia arsip 1" > /var/www/html/arsip/dokumen1.txt
echo "Ini dokumen rahasia arsip 2" > /var/www/html/arsip/dokumen2.txt

a2ensite k01-vault.conf
a2enmod autoindex
service apache2 restart