#!/bin/sh

ls -la /var/cache/bind/k01.com

dig @10.64.1.2 k01.com SOA +short
dig @10.64.1.3 k01.com SOA +short