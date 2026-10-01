#!/bin/bash

cat << 'EOF' >> /etc/bind/k01/k01.com
outbound    IN    CNAME    http.badssl.com.
EOF

service bind9 restart