#!/bin/sh

apt-get update && apt-get install -y nginx php-fpm -y

cat << 'EOF' > /var/www/html/index.php
<!DOCTYPE html>
<html>
<head>
    <title>Beranda</title>
</head>
<body>
    <h1>Selamat Datang di Beranda Core</h1>
    <p>Ini adalah halaman utama.</p>
    <a href="/profil">Lihat Profil</a>
</body>
</html>
EOF

cat << 'EOF' > /var/www/html/profil.php
<!DOCTYPE html>
<html>
<head>
    <title>Profil</title>
</head>
<body>
    <h1>Halaman Profil</h1>
    <p>Ini adalah halaman profil dengan URL bersih (Clean URL).</p>
    <a href="/">Kembali ke Beranda</a>
</body>
</html>
EOF

cat << 'EOF' > /etc/nginx/sites-available/k01-core
server {
    listen 80;
    server_name oblada.k01.com;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location = /profil {
        rewrite ^ /profil.php last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

ln -s /etc/nginx/sites-available/k01-core /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
service php8.4-fpm start
service nginx restart