#!/bin/sh

ZONE_FILE="/etc/bind/k01/k01.com"

sed -i 's/^abbey.*/abbey   15   IN   A   10.200.200.1/' $ZONE_FILE

# Naikkan serial +1 (bukan epoch)
SERIAL=$(grep -oE '[0-9]{10}' $ZONE_FILE | head -1)
NEW=$((SERIAL + 1))
sed -i "s/$SERIAL/$NEW/" $ZONE_FILE

# RELOAD, bukan restart (restart menghapus cache)
named-checkzone k01.com $ZONE_FILE && rndc reload

echo "Selesai. Serial: $SERIAL -> $NEW"