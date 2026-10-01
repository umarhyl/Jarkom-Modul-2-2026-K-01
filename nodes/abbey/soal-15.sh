#!/bin/sh

apt-get update && apt-get install nginx -y

cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy-khusus
# Cluster untuk jalur /orion (Molly & Oblada)
upstream corecluster {
    server 10.64.1.6; # IP Oblada
    server 10.64.1.7; # IP Molly
}

# Cluster untuk jalur /eternal (Penny & Desmond)
upstream pennycluster {
    server 10.64.1.8; # IP Penny  (Sesuaikan jika beda)
    server 10.64.1.9; # IP Desmond (Sesuaikan jika beda)
}

server {
    listen 80;
    server_name abbey.k01.com 10.64.2.2;

    # Forwarding jalur /orion
    location /orion {
        proxy_pass http://corecluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Forwarding jalur /eternal
    location /eternal {
        proxy_pass http://pennycluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/abbey-proxy-khusus /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
service nginx restart