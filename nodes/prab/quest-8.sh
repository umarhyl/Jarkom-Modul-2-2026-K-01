#!/bin/sh

cat <<EOF >> /etc/bind/named.conf.local
zone "1.64.10.in-addr.arpa" {
    type master;
    file "/etc/bind/k01/1.64.10.in-addr.arpa";
    allow-transfer { 10.64.1.3; };
    notify yes;
};

zone "2.64.10.in-addr.arpa" {
    type master;
    file "/etc/bind/k01/2.64.10.in-addr.arpa";
    allow-transfer { 10.64.1.3; };
    notify yes;
};

zone "4.64.10.in-addr.arpa" {
    type master;
    file "/etc/bind/k01/4.64.10.in-addr.arpa";
    allow-transfer { 10.64.1.3; };
    notify yes;
};
EOF

# 10.64.1.x -> prab
cat <<'EOF' > /etc/bind/k01/1.64.10.in-addr.arpa
$TTL    604800
@       IN      SOA     prab.k01.com. root.k01.com. (
                        2026092901 ; Serial
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      prab.k01.com.
@       IN      NS      tedd.k01.com.

2       IN      PTR     prab.k01.com.
3       IN      PTR     tedd.k01.com.
4       IN      PTR     obladi.k01.com.
5       IN      PTR     desmond.k01.com.
6       IN      PTR     oblada.k01.com.
7       IN      PTR     molly.k01.com.
EOF

# 10.64.2.x -> abbey
cat <<'EOF' > /etc/bind/k01/2.64.10.in-addr.arpa
$TTL    604800
@       IN      SOA     prab.k01.com. root.k01.com. (
                        2026092901
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      prab.k01.com.
@       IN      NS      tedd.k01.com.

2       IN      PTR     abbey.k01.com.
EOF

# 10.64.4.x -> penny
cat <<'EOF' > /etc/bind/k01/4.64.10.in-addr.arpa
$TTL    604800
@       IN      SOA     prab.k01.com. root.k01.com. (
                        2026092901
                        604800
                        86400
                        2419200
                        604800 )
;
@       IN      NS      prab.k01.com.
@       IN      NS      tedd.k01.com.

2       IN      PTR     penny.k01.com.
EOF

# rndc-confgen -a
service bind9 restart
