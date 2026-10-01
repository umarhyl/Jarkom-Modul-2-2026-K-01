#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.1.2
    netmask 255.255.255.0
    gateway 10.64.1.1
EOF

# Quest 3
cat <<EOF > /etc/resolv.conf
nameserver 192.168.122.1
EOF

# Quest 20
/root/quest-4.sh
/root/quest-5.sh
/root/quest-7.sh
/root/quest-8.sh
/root/quest-19.sh