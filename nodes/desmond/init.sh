#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.1.5
    netmask 255.255.255.0
    gateway 10.64.1.1
EOF

cat <<EOF > /etc/resolv.conf
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
EOF

apt-get update && apt-get install apache2 -y

mkdir -p /var/www/html/arsip

cat << 'EOF' > /etc/apache2/sites-available/k01-vault.conf
<VirtualHost *:80>
    ServerName desmond.k01.com
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