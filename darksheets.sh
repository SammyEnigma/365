#!/usr/bin/env bash

#######################################################
# Made for doing security research on the Dark Deep Web
# Intended to be used on Kali Linux
# eye -q "vice lausd" | grep .onion > results+onions.txt
# torghost -a -c ca 
# libreoffice --calc results+onions.txt
# Tested on Kali 2022.4
# Last updated 11/29/2022
# https://github.com/aryanguenthner
# The future is now
######################################################
echo "
██████╗░░█████╗░██████╗░██╗░░██╗░██████╗██╗░░██╗███████╗███████╗████████╗░██████╗
██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔════╝██║░░██║██╔════╝██╔════╝╚══██╔══╝██╔════╝
██║░░██║███████║██████╔╝█████═╝░╚█████╗░███████║█████╗░░█████╗░░░░░██║░░░╚█████╗░
██║░░██║██╔══██║██╔══██╗██╔═██╗░░╚═══██╗██╔══██║██╔══╝░░██╔══╝░░░░░██║░░░░╚═══██╗
██████╔╝██║░░██║██║░░██║██║░╚██╗██████╔╝██║░░██║███████╗███████╗░░░██║░░░██████╔╝
╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝░░░╚═╝░░░╚═════╝░"
echo "v1.0"

# Setting Variables
YELLOW=033m
BLUE=034m
KALI=`hostname -I`
LS=`ls`
PWD=`pwd`
echo

# Stay Organized
mkdir -p /home/kali/Desktop/testing/dark-web/
cd /home/kali/Desktop/testing/dark-web/

echo "For the best results run as root: sudo ./darksheets.sh"
echo

# Todays Date
echo -e "\e[034mToday is\e[0m"
date
echo

# Files
echo -e "\e[034mFiles in your current directory -->$PWD\e[0m"
echo "$LS"
sleep 1
echo

# Networking
echo -e "\e[034mGetting Network Information\e[0m"
echo
echo -e "\e[033mPublic IP\e[0m"
curl -s http://ip-api.com/line?fields=timezone | cut -d "/" -f 2

curl -s ifconfig.me
echo
echo
echo -e "\e[033mKali IP\e[0m"
echo $KALI | awk '{print $1}'
echo

# Make sure everything is installed for this to work
echo -e "\e[033mRequirements Check\e[0m"
echo
E=/usr/local/bin/eye
if [ -f "$E" ]
then

    echo "Found The Devils Eye"

else

    echo "Getting the Devil"
pip install thedevilseye

fi
echo

T=/opt/TorGhost/torghost.py
if [ -f "$T" ]
then

    echo "Found TorGhost"

else

    echo "Downloading TorGhost"
# Tor Web Browser Stuff
# Connect to Tor --> torghost -a -c us
# Exit Tor -->torghost -x
# sudo gpg --keyserver pool.sks-keyservers.net --recv-keys EB774491D9FF06E2 && 
# Use Tor Browswer to view the onion links
sudo apt-get -y install torbrowser-launcher

cd /opt
git clone https://github.com/aryanguenthner/TorGhost.git
cd TorGhost
sudo apt -y install python3-pyinstaller python3-notify2
echo "One moment please - Installing TorGhost"
sudo pip3 install . --ignore-installed stem > /dev/null
sudo ./build.sh > /dev/null
echo

fi
echo

# Open the onion links with Libreoffice
O=/usr/bin/libreoffice
if [ -f "$O" ]
then

    echo "Found Libreoffice"

else

    echo "Installing Libreoffice"
apt update && apt -y install libreoffice

fi
echo

# User Input
echo -en "\e[034mWhat are you looking for: \e[0m"
read SEARCH
echo

eye -q "$SEARCH" | grep .onion > results+onions.txt
echo "Be Patient"
echo

echo "Saved results into" results+onions.txt
echo

head results+onions.txt
echo

echo "How many evil onion links did we find?"
wc results+onions.txt
echo
sleep 2
echo

echo -en "\e[033mConnect to the Dark Web y/n: \e[0m"
read DWEB0
echo
echo

if [ $DWEB0 == y ]
then

    echo "Trying to get on the Dark Web"
echo
    echo "Exit Tor type: torghost -x"
torghost -a -c us,ca,mx
echo

    echo -e "\e[033mDark Web IP\e[0m"
curl -s http://ip-api.com/line?fields=timezone | cut -d "/" -f 2

curl -s ifconfig.me
echo
else

    echo "Maybe next time"

fi
echo

# First 10 Results
echo
echo -e "\e[033mFirst 10 Results\e[0m"

echo "Be Good"
echo
head results+onions.txt
echo

# Spreadsheet Results
echo -e "\e[033mOpen darksheet with results in y/n: \e[0m"
read OPEN1
echo

if [ $OPEN1 == y ]
then
    echo -e "\e[033mHere is your darksheet\e[0m"
    echo "To exit: CTRL + c"
    echo "Exit Tor type: torghost -x"
    echo
    echo "Use Tor Browser or Firefox to view .onion sites"
    echo "Edit Firefox: In URL type: about:config"
    echo "Set network.dns.blockDotOnion to false"
libreoffice --calc results+onions.txt;

else

    echo "Maybe next time"

fi
echo

# Fix Permissions for kali
chmod -R 777 /home/kali

# Exit the Dark Web
echo -n 'Exit the Dark Web y/n: '
read DWEB1
if [ $DWEB1 == y ]
then
    echo "Trying to Exit the Dark Web"
torghost -x
    echo
    echo "Exit Tor type: torghost -x"
    echo
    echo -e "\e[033mNew Public IP\e[0m"
curl -s http://ip-api.com/line?fields=timezone | cut -d "/" -f 2

curl -s ifconfig.me

else

echo "Be good"

fi

echo
echo
