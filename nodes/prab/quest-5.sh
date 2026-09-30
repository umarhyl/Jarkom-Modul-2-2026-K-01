#!/bin/sh

cat <<EOF >> /etc/bind/db.k01.com
alpha   IN      A       10.64.3.2
beta    IN      A       10.64.3.3
gamma   IN      A       10.64.3.4
abbey   IN      A       10.64.2.2
delta   IN      A       10.64.5.2
epilson IN      A       10.64.5.3
penny   IN      A       10.64.4.2
obladi  IN      A       10.64.1.4
desmond IN      A       10.64.1.5
oblada  IN      A       10.64.1.6
molly   IN      A       10.64.1.7
EOF