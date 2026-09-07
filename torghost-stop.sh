#!/usr/bin/env bash

echo "Exiting the Darkweb"
echo
# exec /usr/bin/torghostng -x
python3 /opt/TorghostNG/torghostng.py -x
echo
echo
echo -e "\e[031mNetwork Information\e[0m"
echo "---------------------------------"
printf "| %-12s | %-20s |\n" "Public IP" "$EXT"
printf "| %-12s | %-20s |\n" "Country" "$COUNTRY"
printf "| %-12s | %-20s |\n" "State" "$REGION"
printf "| %-12s | %-20s |\n" "City" "$CITY"
printf "| %-12s | %-20s |\n" "Kali IP" "$KALI"
echo "---------------------------------"
echo
