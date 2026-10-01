#!/bin/sh

cat <<EOF >> /etc/bind/k01/k01.com
; Tambahkan TXT Record berikut di file forward zone
alpha   IN  TXT  "alpha"
beta   IN  TXT  "beta"
gamma   IN  TXT  "gamma"
delta   IN  TXT  "delta"
eplison   IN  TXT  "eplison"
EOF

service bind9 restart
