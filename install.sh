#!/bin/bash
# Install script for Instashell
# Coded by: Khalid Husain

echo -e "\e[1;92m[*] Updating packages...\e[0m"
sudo apt update

echo -e "\e[1;92m[*] Installing Tor, Curl, and OpenSSL...\e[0m"
sudo apt install -y tor curl openssl

echo -e "\e[1;92m[*] Setting permissions for instashell.sh...\e[0m"
chmod +x instashell.sh

echo -e "\e[1;92m[*] Starting Tor service...\e[0m"
sudo service tor start

echo -e "\e[1;92m[+] Installation Complete!\e[0m"
echo -e "\e[1;93m[!] Run the tool using: sudo ./instashell.sh\e[0m"
