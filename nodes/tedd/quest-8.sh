#!/bin/sh

cat <<EOF >> /etc/bind/named.conf.local
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


