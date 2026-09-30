#!/bin/sh

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
EOF

sed -i '1i nameserver 10.64.1.2\nnameserver 10.64.1.3' /etc/resolv.conf
# rndc-confgen -a
service bind9 restart