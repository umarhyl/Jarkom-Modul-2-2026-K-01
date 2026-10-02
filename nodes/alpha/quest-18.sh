#!/bin/sh

cat <<'EOF'> /etc/resolv.conf
nameserver 127.0.0.1
EOF

service dnsmasq stop 2>/dev/null
pkill dnsmasq 2>/dev/null
sleep 1

# dnsmasq baru (cache kosong), jalan di background
dnsmasq --no-poll --no-resolv -h --listen-address=127.0.0.1 --server=10.64.1.2
sleep 1

echo "=== FASE 1: sebelum perubahan (harus 10.64.2.2, TTL 15) ==="
dig abbey.k01.com +noall +answer | awk '{print $2, $5}'
echo
echo ">>> SEKARANG jalankan 'sh quest-18.sh' di PRAB <<<"
echo

sleep 5

for i in $(seq 1 35); do
  echo "$(date +%T) -> $(dig abbey.k01.com +noall +answer | awk '{print "TTL="$2, $5}')"
  sleep 1
done

echo