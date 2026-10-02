#!/bin/sh

mkdir -p /var/www/orion

echo "Halo dari direktori /var/www/orion untuk proxy khusus" > /var/www/orion/index.html

cat << 'EOF' > /etc/nginx/sites-available/proxy-khusus
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