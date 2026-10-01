#!/bin/sh
# Instalasi ApacheBench (jika belum ada)
apt-get update && apt-get install apache2-utils -y

# Stress test ke www.k01.com
ab -n 250 -c 10 http://www.k01.com/

# Stress test ke static.k01.com
ab -n 250 -c 10 http://static.k01.com/