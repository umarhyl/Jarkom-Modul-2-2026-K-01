#!/bin/sh

apt update && apt install nginx -y

mkdir -p /var/www/orion

echo "Halo dari direktori /var/www/orion untuk proxy khusus" > /var/www/orion/index.html

cat << 'EOF' > /etc/apache2/sites-available/proxy-khusus
server {
    listen 80;
    server_name localhost;

    root /var/www;
    index index.html index.htm index.php;

    location /orion {
        try_files $uri $uri/ =404;
    }
}
EOF

nginx -t
service nginx restart