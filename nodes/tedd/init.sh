#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.1.3
    netmask 255.255.255.0
    gateway 10.64.1.1
EOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

apt update && apt install bind9 -y

ln -s /etc/init.d/named /etc/init.d/bind9

cat <<EOF > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
        };
        allow-query { any; };
        auth-nxdomain no;
        listen-on { any; };
        listen-on-v6 { any; };
};
EOF

cat <<EOF > /etc/bind/named.conf.local
zone "k01.com" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/cache/bind/k01.com";
};

zone "1.64.10.in-addr.arpa" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/cache/bind/1.64.10.in-addr.arpa";
};

zone "2.64.10.in-addr.arpa" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/cache/bind/2.64.10.in-addr.arpa";
};

zone "4.64.10.in-addr.arpa" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/cache/bind/4.64.10.in-addr.arpa";
};
EOF

service bind9 restart

cat <<EOF > /etc/resolv.conf
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
EOF
