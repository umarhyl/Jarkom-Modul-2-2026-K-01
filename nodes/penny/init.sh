#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.4.2
    netmask 255.255.255.0
    gateway 10.64.4.1
EOF

cat <<EOF > /etc/resolv.conf
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
EOF

apt update && apt install apache2 -y

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

cat << 'EOF' > /etc/apache2/sites-available/penny-proxy.conf
<VirtualHost *:80>
    ServerName penny.k01.com
    ServerAlias 10.64.4.2

    Redirect 301 / http://www.k01.com/
</VirtualHost>

<VirtualHost *:80>
    ServerName www.k01.com

    Redirect 301 / http://www.k01.com/

    # Meneruskan header Host asli
    ProxyPreserveHost On

    ProxyPass /admin !

    # Cluster Load Balancing untuk area vault (obladi & desmond)
    <Proxy balancer://vaultcluster>
        BalancerMember http://10.64.1.4
        BalancerMember http://10.64.1.5
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPass / balancer://vaultcluster/
    ProxyPassReverse / balancer://vaultcluster/

    # Meneruskan IP asli klien ke backend
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

    # soal 12
    <Location /admin>
        AuthType Basic
        AuthName "Area Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>
</VirtualHost>
EOF

htpasswd -bc /etc/apache2/.htpasswd prabs "pakar_pinter_jadi_gob***"

a2enmod auth_basic authn_core authz_user
a2ensite penny-proxy.conf
service apache2 restart