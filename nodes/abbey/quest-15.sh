#!/bin/sh

mkdir -p /etc/nginx/abbey-locations
mkdir -p /var/www/orion
echo "Orion statis" > /var/www/orion/index.html

cat << 'EOF' > /etc/nginx/abbey-locations/orion.conf
location /orion {
    root /var/www;
    index index.html;
    try_files $uri $uri/ =404;
}
EOF

nginx -t && service nginx restart