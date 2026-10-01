#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.4.2
    netmask 255.255.255.0
    gateway 10.64.4.1
EOF

# Quest 3 & 4
cat <<EOF > /etc/resolv.conf
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
EOF

# Quest 20
/root/quest-11-12-13.sh
/root/quest-15.sh