#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.2.2
    netmask 255.255.255.0
    gateway 10.64.2.1
EOF

cat <<EOF > /etc/resolv.conf
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
EOF

apt update && apt install nginx -y

cat << 'EOF' > /etc/nginx/sites-available/abbey-proxy
upstream corecluster {
    server 10.64.1.6;
    server 10.64.1.7;
}

server {
    listen 80;
    server_name abbey.k01.com 10.64.2.2;
    # Redirect sementara (302) ke domain kanonik static.k01.com
    return 302 http://static.k01.com$request_uri;

    location / {
        proxy_pass http://corecluster;

        # Meneruskan header Host, X-Real-IP, dan X-Forwarded-For
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF


ln -s /etc/nginx/sites-available/abbey-proxy /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
service nginx restart