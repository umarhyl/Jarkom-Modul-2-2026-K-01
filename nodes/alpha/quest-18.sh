cat << 'EOF' > /root/cek_ttl_dns.sh
#!/bin/sh

echo " FASE 1: Sebelum Perubahan (Target: IP Lama 10.64.2.2)"
dig abbey.k01.com +short

echo " FASE 2: Dalam Jeda Waktu TTL 15 Detik (Masih IP Lama)"
dig abbey.k01.com +short

echo ">>> Menghitung mundur 16 detik agar TTL cache habis..."
sleep 16

echo " FASE 3: Setelah TTL Habis (Target: IP Baru 10.200.200.1)"
dig abbey.k01.com +short
EOF

chmod +x /root/cek_ttl_dns.sh