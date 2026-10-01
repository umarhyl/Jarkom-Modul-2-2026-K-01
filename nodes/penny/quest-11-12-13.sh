#!/bin/sh

apt update && apt install apache2 -y

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

mkdir -p /var/www/html/admin
cat << 'EOF' > /var/www/html/admin/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Admin</title>
</head>
<body>
    <h1>Selamat datang di halaman admin</h1>
</body>
</html>
EOF

cat << 'EOF' > /etc/apache2/sites-available/penny-proxy.conf
<VirtualHost *:80>
    ServerName penny.k01.com
    ServerAlias 10.64.4.2

    Redirect 301 / http://www.k01.com/
</VirtualHost>

<VirtualHost *:80>
    ServerName www.k01.com

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

    # Quest 12
    <Location /admin>
        AuthType Basic
        AuthName "Area Rahasia Sindikat"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Location>
</VirtualHost>
EOF

htpasswd -bc /etc/apache2/.htpasswd prabs "pakar_pinter_jadi_goblok"

a2enmod auth_basic authn_core authz_user
a2ensite penny-proxy.conf
service apache2 restart