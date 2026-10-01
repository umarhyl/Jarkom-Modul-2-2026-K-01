#!/bin/sh

cat <<EOF >> /etc/bind/k01/k01.com
vault   IN      A       10.64.1.4
vault   IN      A       10.64.1.5
core    IN      A       10.64.1.6
core    IN      A       10.64.1.7
www     IN      CNAME   penny.k01.com.
static  IN      CNAME   abbey.k01.com.
EOF

service bind9 restart