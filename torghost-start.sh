#!/usr/bin/env bash
echo
echo "Darkweb Access Granted"
echo
sudo LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libcrypto.so.3 torghostng -s -id cz,nl
python3 /opt/TorghostNG/torghostng.py -s -id cz,nl

# sudo visudo Notes
# kali ALL=(ALL) NOPASSWD: /root/torghost-start.sh, /root/torghost-stop.sh
echo

echo -e "\e[031mDarkweb Network Information\e[0m"
echo "---------------------------------"
printf "| %-12s | %-20s |\n" "Public IP" "$EXT"
printf "| %-12s | %-20s |\n" "Country" "$COUNTRY"
printf "| %-12s | %-20s |\n" "State" "$REGION"
printf "| %-12s | %-20s |\n" "City" "$CITY"
printf "| %-12s | %-20s |\n" "Kali IP" "$KALI"
echo "---------------------------------"
echo
