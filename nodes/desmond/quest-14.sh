#!/bin/sh

apt-get update && apt-get install apache2 -y
a2enmod remoteip

cat <<EOF > /etc/apache2/apache2.conf

sed -i 's/%h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\"/%a %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\"/' "$CONFIG_FILE"

if ! grep -q "RemoteIPHeader X-Forwarded-For" "$CONFIG_FILE"; then
cat << 'EOF' >> "$CONFIG_FILE"

RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 10.64.4.2
EOF

apache2ctl configtest
service apache2 restart || systemctl restart apache2

echo "Konfigurasi Apache selesai dan berjalan lancar!"