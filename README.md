# JARKOM MODUL 2 2026 - K01

## Member

| Nama | NRP |
| --- | --- |
| Umar | 5027251005 |
| Syarifah Nailatur Rohma | 5027251109 |

## Laporan

### Topologi

![Topologi jaringan](assets/topologi.png)

`rootkit` berfungsi sebagai router pusat yang menghubungkan lima segmen jaringan internal. Prefix IP kelompok yang digunakan adalah `10.64.x.x` dengan subnet mask `/24`.

| Segmen | Interface rootkit | Gateway | Entitas |
| --- | --- | --- | --- |
| 10.64.1.0/24 | eth1 | 10.64.1.1 | prab, tedd, obladi, desmond, oblada, molly |
| 10.64.2.0/24 | eth2 | 10.64.2.1 | abbey |
| 10.64.3.0/24 | eth4 | 10.64.3.1 | alpha, beta, gamma |
| 10.64.4.0/24 | eth3 | 10.64.4.1 | penny |
| 10.64.5.0/24 | eth5 | 10.64.5.1 | delta, epilson |

### 1. Konfigurasi IP dan gateway

`rootkit` menggunakan `eth0` sebagai interface WAN melalui DHCP. Interface `eth1` sampai `eth5` digunakan sebagai gateway untuk lima jaringan internal.

Konfigurasi yang terdapat pada `nodes/rootkit/init.sh`:

```bash
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.64.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.64.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.64.4.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.64.3.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 10.64.5.1
    netmask 255.255.255.0
```

Daftar alamat setiap entitas:

| Entitas | IP address | Gateway | Peran |
| --- | --- | --- | --- |
| rootkit | eth1 `10.64.1.1`, eth2 `10.64.2.1`, eth3 `10.64.4.1`, eth4 `10.64.3.1`, eth5 `10.64.5.1` | - | Router |
| alpha | `10.64.3.2/24` | `10.64.3.1` | Client |
| beta | `10.64.3.3/24` | `10.64.3.1` | Client |
| gamma | `10.64.3.4/24` | `10.64.3.1` | Client |
| prab | `10.64.1.2/24` | `10.64.1.1` | DNS master |
| tedd | `10.64.1.3/24` | `10.64.1.1` | DNS slave |
| abbey | `10.64.2.2/24` | `10.64.2.1` | Proxy core |
| penny | `10.64.4.2/24` | `10.64.4.1` | Proxy vault |
| delta | `10.64.5.2/24` | `10.64.5.1` | Client |
| epilson | `10.64.5.3/24` | `10.64.5.1` | Client |
| obladi | `10.64.1.4/24` | `10.64.1.1` | Web statis |
| desmond | `10.64.1.5/24` | `10.64.1.1` | Web statis |
| oblada | `10.64.1.6/24` | `10.64.1.1` | Web dinamis |
| molly | `10.64.1.7/24` | `10.64.1.1` | Web dinamis |

Contoh konfigurasi client pada `nodes/alpha/init.sh`:

```bash
auto eth0
iface eth0 inet static
    address 10.64.3.2
    netmask 255.255.255.0
    gateway 10.64.3.1
```

![ip addr-ip route](assets/alpha-1.png)

### 2. NAT dan akses internet

Pada `rootkit`, IPv4 forwarding diaktifkan agar paket dapat diteruskan antarinterface. NAT masquerade diterapkan pada interface WAN `eth0`, kemudian trafik dari seluruh interface internal diizinkan menuju WAN.

Konfigurasi dari `nodes/rootkit/init.sh`:

```bash
apt update
which iptables &>/dev/null || apt install iptables -y

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT
```

Pengujian dilakukan dengan memeriksa `ip route`, tabel NAT, lalu menjalankan `ping -c 3 192.168.122.1` dari client.

![nat rootkit](assets/iptables-rootkit.png)
![ping internet](assets/alpha-2.png)

### 3. Routing internal dan resolver awal

Setiap node non-router memiliki default gateway menuju `rootkit`. Resolver awal digunakan agar node dapat mengakses jaringan luar dan mengunduh paket. Pada script terbaru, konfigurasi resolver final untuk node yang sudah melewati tahap DNS adalah:

```text
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
```

Contoh isi resolver pada node yang sudah menggunakan DNS internal:

```bash
cat <<EOF > /etc/resolv.conf
nameserver 10.64.1.2
nameserver 10.64.1.3
nameserver 192.168.122.1
EOF
```

Pada tahap awal `prab` dan `tedd`, resolver `192.168.122.1` digunakan terlebih dahulu untuk instalasi. Setelah DNS internal aktif, resolver diganti ke urutan `prab`, `tedd`, lalu resolver eksternal.

Pengujian routing dilakukan dengan ping antarclient dan ping dari client menuju node pada subnet lain.

![resolver dan ping antarsegmen](assets/alpha-3.png)

### 4. DNS authoritative master-slave

Setelah konfigurasi jaringan selesai, layanan DNS dikonfigurasi pada terminal `prab` dan `tedd`. `prab` berperan sebagai master zona `k01.com`, sedangkan `tedd` menjadi slave dengan master `10.64.1.2`.

Konfigurasi jaringan awal `prab` pada script:

```bash
auto eth0
iface eth0 inet static
    address 10.64.1.2
    netmask 255.255.255.0
    gateway 10.64.1.1

echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

Konfigurasi master BIND9 yang diterapkan pada `prab`:

```conf
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    allow-query { any; };
    auth-nxdomain no;
    listen-on { any; };
    listen-on-v6 { any; };
};

zone "k01.com" {
    type master;
    file "/etc/bind/k01/k01.com";
    allow-transfer { 10.64.1.3; };
    notify yes;
};
```

Konfigurasi slave pada `tedd`:

```conf
zone "k01.com" {
    type slave;
    masters { 10.64.1.2; };
    file "/var/cache/bind/k01.com";
};
```

Verifikasi dilakukan dengan query SOA dari kedua nameserver.

- client query SOA (master 10.64.1.2)
![query SOA prab dan tedd](assets/alpha-4.png)

### 5. Identitas host dan hostname

Hostname setiap entitas disesuaikan dengan glosarium praktikum: `rootkit`, `alpha`, `beta`, `gamma`, `delta`, `epilson`, `prab`, `tedd`, `abbey`, `penny`, `obladi`, `desmond`, `oblada`, dan `molly`. Nama domain setiap entitas dicatat pada zona `k01.com`.

Record A yang digunakan:

```dns
alpha   IN A 10.64.3.2
beta    IN A 10.64.3.3
gamma   IN A 10.64.3.4
delta   IN A 10.64.5.2
epilson IN A 10.64.5.3
abbey   IN A 10.64.2.2
penny   IN A 10.64.4.2
```

Pengujian dilakukan dengan `hostname`, `ip addr`, dan `dig alpha.k01.com A` dari client.

- client query hostname dan IP
![hostname dan ip addr](assets/alpha-5.png)
![hostname dan resolusi domain setiap entitas](assets/alpha-5.png)

### 6. Zone transfer

Forward zone dan reverse zone dideklarasikan sebagai master pada `prab`, lalu ditarik oleh `tedd` sebagai slave. Nilai serial SOA pada kedua nameserver harus sama setelah transfer selesai.

```bash
# Jalankan di node prab
dig @10.64.1.2 k01.com SOA

# Jalankan di node tedd
dig @10.64.1.3 k01.com SOA
```

Jika serial sama dan `tedd` memberikan jawaban authoritative, zone transfer berhasil.

- client query SOA (master 10.64.1.2)
![query SOA prab](assets/prab-1.png)
- client query SOA (slave 10.64.1.3)
![query SOA tedd](assets/tedd-1.png)

### 7. Record vault, core, dan CNAME

Record layanan pada zona `k01.com` adalah sebagai berikut:

```dns
vault  IN A     10.64.1.4
vault  IN A     10.64.1.5
core   IN A     10.64.1.6
core   IN A     10.64.1.7
www    IN CNAME penny.k01.com.
static IN CNAME abbey.k01.com.
```

`vault` menunjuk ke `obladi` dan `desmond`, sedangkan `core` menunjuk ke `oblada` dan `molly`. Pengujian dilakukan dari dua client dengan `dig` untuk memastikan jawaban konsisten.

- client query vault, core, www, dan static (master 10.64.1.2)
![alpha qury vault](assets/alpha-6.png)
![alpha query core](assets/alpha-7.png)
![alpha query www](assets/alpha-8.png)
![alpha query static](assets/alpha-9.png)

- client query vault, core, www, dan static (slave 10.64.1.3)
![alpha qury vault](assets/beta-1.png)
![beta query core](assets/beta-2.png)
![beta query core](assets/beta-3.png)
![beta query core](assets/beta-4.png)

### 8. Reverse DNS

Reverse zone digunakan untuk menerjemahkan alamat IP kembali menjadi hostname. Record PTR yang digunakan antara lain:

```dns
2 IN PTR prab.k01.com.
3 IN PTR tedd.k01.com.
4 IN PTR obladi.k01.com.
5 IN PTR desmond.k01.com.
6 IN PTR oblada.k01.com.
7 IN PTR molly.k01.com.
```

Pada reverse zone proxy, `10.64.2.2` diarahkan ke `abbey.k01.com` dan `10.64.4.2` diarahkan ke `penny.k01.com`.

```bash
dig @10.64.1.2 -x 10.64.2.2
dig @10.64.1.2 -x 10.64.1.4
dig @10.64.1.3 -x 10.64.2.2
dig @10.64.1.3 -x 10.64.4.2
```

- client query DNS master (10.64.1.2)
![alpha query PTR abbey](assets/alpha-10.png)
![alpha query PTR penny](assets/alpha-11.png)

- client query DNS slave (10.64.1.3)
![beta query PTR abbey](assets/beta-5.png)
![beta query PTR penny](assets/beta-6.png)

### 9. Web statis area vault

`obladi` dan `desmond` dikonfigurasi manual sebagai web server Apache. Directory `/var/www/html/arsip` digunakan untuk menyimpan dokumen dan fitur autoindex diaktifkan.

```apache
<VirtualHost *:80>
    ServerName obladi.k01.com
    DocumentRoot /var/www/html

    <Directory /var/www/html/arsip>
        Options +Indexes
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

Pada `desmond`, `ServerName` diganti menjadi `desmond.k01.com`. File uji dibuat dengan:

```bash
mkdir -p /var/www/html/arsip
echo "Ini dokumen rahasia arsip 1" > /var/www/html/arsip/dokumen1.txt
echo "Ini dokumen rahasia arsip 2" > /var/www/html/arsip/dokumen2.txt
a2enmod autoindex
service apache2 restart
```

- client curl http://obladi.k01.com (obladi web server)
![client curl obladi web server](assets/alpha-12.png)

- client curl http://desmond.k01.com (desmond web server)
![client curl desmond web server](assets/alpha-13.png)

### 10. Web dinamis area core

`oblada` dan `molly` dikonfigurasi manual menggunakan Nginx dan PHP-FPM. Aplikasi memiliki `index.php` sebagai halaman beranda dan `profil.php` sebagai halaman profil.

```nginx
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
```

- client curl http://oblada.k01.com (oblada web server)
![client curl oblada web server](assets/alpha-14.png)

- client curl http://molly.k01.com (molly web server)
![client curl molly web server](assets/alpha-15.png)

### 11. Reverse proxy dan load balancing

`penny` menjadi reverse proxy untuk area vault menggunakan Apache, sedangkan `abbey` menjadi reverse proxy untuk area core menggunakan Nginx.

Konfigurasi upstream pada `abbey`:

```nginx
upstream corecluster {
    server 10.64.1.6;
    server 10.64.1.7;
}

location / {
    proxy_pass http://corecluster;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

Konfigurasi balancer pada `penny`:

```apache
<Proxy balancer://vaultcluster>
    BalancerMember http://10.64.1.4
    BalancerMember http://10.64.1.5
    ProxySet lbmethod=byrequests
</Proxy>

ProxyPass / balancer://vaultcluster/
ProxyPassReverse / balancer://vaultcluster/
RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
```

Header `Host`, `X-Real-IP`, dan `X-Forwarded-For` diteruskan ke backend. Pengujian dilakukan dengan mengakses `www.k01.com` dan `static.k01.com` berulang kali.

- Client uji reverse proxy vault www
![client uji reverse proxy vault www](assets/alpha-16.png)

- Client uji reverse proxy core static
![client uji reverse proxy vault www](assets/alpha-17.png)


### 12. Basic authentication `/admin`

Path `/admin` pada `www.k01.com` diberi perlindungan Basic Authentication. Request tanpa kredensial harus ditolak dengan status `401 Unauthorized`.

```apache
ProxyPass /admin !

<Location /admin>
    AuthType Basic
    AuthName "Area Rahasia Sindikat"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Location>
```

Kredensial dibuat pada node `penny`:

```bash
htpasswd -bc /etc/apache2/.htpasswd prabs "pakar_pinter_jadi_gob***"
a2enmod auth_basic authn_core authz_user
service apache2 restart
```

Pengujian:

```bash
curl -i http://www.k01.com/admin
curl -i -u prabs:'pakar_pinter_jadi_gob***' http://www.k01.com/admin
```

- Client curl http://www.k01.com/admin tanpa kredensial
![client curl www.k01.com/admin tanpa kredensial](assets/alpha-18.png)

- Client curl http://www.k01.com/admin dengan kredensial
![client curl www.k01.com/admin dengan kredensial](assets/alpha-19.png)

### 13. Redirect hostname kanonik

Akses ke `penny.k01.com` atau IP `10.64.4.2` diarahkan permanen dengan status `301` menuju `www.k01.com`. Akses ke `abbey.k01.com` atau IP `10.64.2.2` diarahkan sementara dengan status `302` menuju `static.k01.com`.

Konfigurasi redirect pada `penny`:

```apache
<VirtualHost *:80>
    ServerName penny.k01.com
    ServerAlias 10.64.4.2
    Redirect 301 / http://www.k01.com/
</VirtualHost>
```

Konfigurasi redirect pada `abbey`:

```nginx
server {
    listen 80;
    server_name abbey.k01.com 10.64.2.2;
    return 302 http://static.k01.com$request_uri;
}
```

Pengujian dilakukan dengan:

```bash
curl -I http://penny.k01.com/
curl -I http://abbey.k01.com/
```

- Client curl http://penny.k01.com/ (redirect 301)
![client curl penny.k01.com redirect 301](assets/alpha-20.png)

- Client curl http://abbey.k01.com/ (redirect 302)
![client curl abbey.k01.com redirect 302](assets/alpha-21.png)