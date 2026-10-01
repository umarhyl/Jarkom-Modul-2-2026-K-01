#!/bin/sh

apt update && apt install nginx -y

cat <<EOF > /etc/nginx/conf.d/real_ip.conf
set_real_ip_from 10.64.2.2;
real_ip_header X-Forwarded-For;
real_ip_recursive on;

nginx -t && service nginx reload