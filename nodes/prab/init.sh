#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.1.2
    netmask 255.255.255.0
    gateway 10.64.1.1
EOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf

apt-get update && apt-get install bind9 -y

ln -s /etc/init.d/named /etc/init.d/bind9

mkdir -p /etc/bind/k01

cat <<'EOF' > /etc/bind/k01/k01.com
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     prab.k01.com. root.k01.com. (
                        2025100401 ; Serial (format YYYYMMDDXX)
                        604800     ; Refresh (1 minggu)
                        86400      ; Retry (1 hari)
                        2419200    ; Expire (4 minggu)
                        604800 )   ; Negative Cache TTL
;

@       IN      NS      prab.k01.com.
@       IN      NS      tedd.k01.com.

prab    IN      A       10.64.1.2
tedd    IN      A       10.64.1.3

@       IN      A       10.64.4.2

alpha   IN      A       10.64.3.2
beta    IN      A       10.64.3.3
gamma   IN      A       10.64.3.4
abbey   IN      A       10.64.2.2
delta   IN      A       10.64.5.2
epilson  IN      A      10.64.5.3
penny   IN      A       10.64.4.2
obladi  IN      A       10.64.1.4
desmond IN      A       10.64.1.5
oblada  IN      A       10.64.1.6
molly   IN      A       10.64.1.7

vault   IN      A       10.64.1.4
vault   IN      A       10.64.1.5
core    IN      A       10.64.1.6
core    IN      A       10.64.1.7
www     IN      CNAME   penny.k01.com.
static  IN      CNAME   abbey.k01.com.
EOF

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
    type master;
    file "/etc/bind/k01/k01.com";
    allow-transfer { 10.64.1.3; };
    notify yes;
};

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

service bind9 restart

cat <<EOF > /etc/resolv.conf
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
EOF

# rndc-confgen -a