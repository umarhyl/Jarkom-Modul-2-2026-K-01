#!/bin/sh

echo "Aba-aba 5 detik sebelum mengubah DNS..."
sleep 5

echo "Mengubah IP abbey dan menaikkan Serial SOA..."

# Menggunakan path direktori yang benar (jarkom)
ZONE_FILE="/etc/bind/k01/k01.com"

# Ubah IP menjadi fiktif dan naikkan serial
sed -i 's/abbey.*IN.*A.*10.64.2.2/abbey 15 IN A 10.200.200.1/g' $ZONE_FILE
sed -i "s/[0-9]\{8,10\}/$(date +%s)/g" $ZONE_FILE

# Gunakan 'named' alih-alih 'bind9'
service named restart || /etc/init.d/named restart

echo "[Prab] Selesai! Layanan DNS berhasil di-restart dengan IP fiktif."