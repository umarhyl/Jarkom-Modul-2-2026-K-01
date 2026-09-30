#!/bin/sh

apt-get update && apt-get install bind9 -y
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
EOF

sed -i '1i nameserver 10.64.1.2\nnameserver 10.64.1.3' /etc/resolv.conf
# rndc-confgen -a
service bind9 restart