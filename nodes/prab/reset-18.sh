#!/bin/sh
 
ZONE_FILE="/etc/bind/k01/k01.com"
 
# abbey -> IP lama, TTL 15
sed -i 's/^abbey.*/abbey   15   IN   A   10.64.2.2/' $ZONE_FILE
 
SERIAL=$(grep -m1 'Serial' $ZONE_FILE | grep -oE '[0-9]{10}')
NEW=$((SERIAL + 1))
sed -i "/Serial/s/$SERIAL/$NEW/" $ZONE_FILE
 
named-checkzone k01.com $ZONE_FILE && rndc reload