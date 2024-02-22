#!/bin/bash

# Install Squid Proxy
sudo apt-get update
sudo apt-get install -y squid

# Backup konfigurasi Squid default
sudo mv /etc/squid/squid.conf /etc/squid/squid.conf.backup

# Buat file konfigurasi baru untuk Squid
sudo touch /etc/squid/squid.conf

# Tambahkan konfigurasi dasar untuk Squid
echo "acl localnet src 0.0.0.1-0.255.255.255 # RFC 1122 \"this\" network (LAN)" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet src 10.0.0.0/8            # RFC 1918 local private network (LAN)" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet src 100.64.0.0/10         # RFC 6598 shared address space (CGN)" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet src 169.254.0.0/16        # RFC 3927 link-local (directly plugged) machines" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet src 172.16.0.0/12         # RFC 1918 local private network (LAN)" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet src 192.168.0.0/16        # RFC 1918 local private network (LAN)" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet src fc00::/7             # RFC 4193 local private network range" | sudo tee -a /etc/squid/squid.conf
echo "acl localnet src fe80::/10            # RFC 4291 link-local (directly plugged) machines" | sudo tee -a /etc/squid/squid.conf
echo "acl SSL_ports port 443" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 80          # http" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 21          # ftp" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 443         # https" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 70          # gopher" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 210         # wais" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 1025-65535  # unregistered ports" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 280         # http-mgmt" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 488         # gss-http" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 591         # filemaker" | sudo tee -a /etc/squid/squid.conf
echo "acl Safe_ports port 777         # multiling http" | sudo tee -a /etc/squid/squid.conf
echo "acl CONNECT method CONNECT" | sudo tee -a /etc/squid/squid.conf

# Tambahkan konfigurasi autentikasi
echo -n "Masukkan username: "
read username
htpasswd -c /etc/squid/passwd $username

echo "auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd" | sudo tee -a /etc/squid/squid.conf
echo "auth_param basic children 5" | sudo tee -a /etc/squid/squid.conf
echo "auth_param basic realm Squid proxy-caching web server" | sudo tee -a /etc/squid/squid.conf
echo "auth_param basic credentialsttl 2 hours" | sudo tee -a /etc/squid/squid.conf
echo "auth_param basic casesensitive off" | sudo tee -a /etc/squid/squid.conf
echo "acl authenticated proxy_auth REQUIRED" | sudo tee -a /etc/squid/squid.conf
echo "http_access allow authenticated" | sudo tee -a /etc/squid/squid.conf

# Izinkan koneksi dari local network
echo "http_access allow localnet" | sudo tee -a /etc/squid/squid.conf

# Batasi koneksi ke port yang aman
echo "http_access deny !Safe_ports" | sudo tee -a /etc/squid/squid.conf

# Larang koneksi ke port tidak aman
echo "http_access deny CONNECT !SSL_ports" | sudo tee -a /etc/squid/squid.conf

# Batasi akses ke localhost
echo "http_access allow localhost" | sudo tee -a /etc/squid/squid.conf

# Konfigurasi tambahan sesuai kebutuhan

# Restart Squid untuk menerapkan perubahan
sudo systemctl restart squid

echo "Instalasi Squid Proxy selesai."
