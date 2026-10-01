#!/bin/sh

apt update && apt install nginx -y

cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
upstream corecluster {
    server 10.64.1.6;
    server 10.64.1.7;
}

# Redirect abbey.k01.com ke static.k01.com
server {
    listen 80;
    server_name abbey.k01.com 10.64.2.2;

    return 302 http://static.k01.com$request_uri;
}

# Reverse proxy untuk static.k01.com
server {
    listen 80;
    server_name static.k01.com;

    location / {
        proxy_pass http://corecluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

ln -s /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
service nginx restart