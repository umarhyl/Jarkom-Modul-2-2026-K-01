#!/bin/sh

a2enmod remoteip

cat <<EOF > /etc/apache2/apache2.conf
# Taruh di baris paling bawah
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 10.64.4.2
# Ubah format log bari yang ada tulisan combined
LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

service apache2 restart