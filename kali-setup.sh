#!/bin/bash
################################################
# Kali Linux Post Setup Automation Script
# Tested on Kali 2021.4a
# If you're reading this pat yourself on the back
# sudo dos2unix *.sh
# sudo chmod +x *.sh
# Usage: sudo ./kali-setup.sh | tee kali.log
# Learn more at https://github.com/aryanguenthner/
# Last Updated 01/26/2022, Minor updates: Enabled HP Printer Connection
################################################
echo
cd /tmp
date > kali-setup-date.txt
echo
echo "Good Idea to Update and Upgrade first before we do this kali-setup.sh"
echo
# apt update && apt -y upgrade && apt -y full-upgrade && reboot
echo
echo "Be Patient, Installing Kali Dependencies"
apt update
apt -y install virtualenv ssmtp mailutils mpack ndiff docker docker.io docker-compose containerd python3.9-venv python3-dev python3-venv pip python3-pip python3-bottle python3-cryptography python3-dbus python3-future python3-matplotlib python3-mysqldb python3-openssl python3-pil python3-psycopg2 python3-pymongo python3-sqlalchemy python3-tinydb python3-py2neo at bloodhound ipcalc nload crackmapexec hostapd dnsmasq gedit cupp nautilus dsniff build-essential cifs-utils cmake curl ffmpeg gimp git graphviz imagemagick libapache2-mod-php php-xml libmbim-utils nfs-common openssl tesseract-ocr vlc wkhtmltopdf xsltproc xutils-dev driftnet websploit apt-transport-https openresolv screenfetch baobab speedtest-cli sendmail libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev awscli sublist3r w3m jq hplip printer-driver-hpcups cups system-config-printer gobuster tcpxtract libreoffice
echo
#openjdk-13-jdk did not install
#libindicator3-7 did not install
#python3.8-venv did not install
#libappindicator3-1 did not install
echo
# Slack Setup on Kali needs some love
# curl https://packagecloud.io/install/repositories/slacktechnologies/slack/script.deb.sh . 
# chmod +x script.deb.sh
# os=debian dist=stretch ./script.deb.sh
# echo
# Download and Install cloudflare tunnel
# cd /tmp
# wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/ccloudflared-linux-amd64.deb
# dpkg -i cloudflared-linux-amd64.deb
echo
# Coolest Thing for Nmap
# nmap -T4 -sVTC -p- --open --max-retries 0 -oA nmap-scan-20220126 --stylesheet nmap-bootstrap.xsl
# xsltproc -o nmap-new.html nmap-bootstrap.xsl nmap-scan-20220126
cd /usr/share/nmap/scripts
wget https://github.com/aryanguenthner/nmap-bootstrap-xsl/blob/stable/nmap-bootstrap.xsl
nmap --script-updatedb
# Download and Install Etcher - USB Bootable Media Creator
# curl -1sLf \
#   'https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh' \
#   | sudo -E bash 
echo
# apt update
# apt -y install balena-etcher-electron
echo
# Project Discovery
apt -y install golang-go
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
# Upgrade pip
pip3 install --upgrade pip
echo
pip3 install updog
echo "Hacker TV" #Works with Python 3.9
echo
apt -y install python3-imdbpy
echo
sudo apt -y install libmpv1 gir1.2-xapp-1.0 debhelper python3-setproctitle dpkg-dev git
echo
cd /opt
sudo git clone https://github.com/aryanguenthner/hypnotix.git
cd hypnotix
wget http://ftp.us.debian.org/debian/pool/main/i/imdbpy/python3-imdbpy_6.8-2_all.deb &&
sudo dpkg -i python3-imdbpy_6.8-2_all.deb
sudo dpkg-buildpackage -b -uc
sudo python3 -m venv ./venv
sudo dpkg -i ../hypnotix*.deb
echo
# How to Update Python Alternatives
echo
: 'kali python Config
sudo update-alternatives --list python
sudo update-alternatives --config python
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 3
sudo update-alternatives --set python /usr/bin/python3.8
# update-alternatives --remove-all python

kali python3 Config
update-alternatives --list python3
sudo update-alternatives --config python3
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 3 #MobSF
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 #hypnotix, apt work, not MobSF
sudo update-alternatives --set python3 /usr/bin/python3.9
'
echo
: '# Virtualbox Install if your doing a hard install
sudo wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib" >> /etc/apt/sources.list
sudo apt update
sudo apt -y install dkms
sudo apt -y install virtualbox virtualbox-ext-pack
'
# Signal
echo
# NOTE: These instructions only work for 64 bit Debian-based
# Linux distributions such as Ubuntu, Mint etc.
# 1. Install our official public software signing key
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
# 2. Add our repository to your list of repositories
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
# 3. Update your package database and install signal
apt update && apt -y install signal-desktop
echo
echo "VPN stuff"
cd /tmp
wget --no-check-certificate https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub
apt-key add openvpn-repo-pkg-key.pub
echo
echo "Getting tmpmail"
# Hackers like tmpmail
# tmpmail --generate hackermaill@1secmail.com
curl -L "https://git.io/tmpmail" > tmpmail && chmod +x tmpmail
mv tmpmail ~/bin/
./tmpmail --generate
echo
# Hackers like SSH
echo
echo "Enabling SSH"
sed -i '34s/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl enable ssh
service ssh restart
echo
echo "Your Internal IP Address"
hostname -I
echo
echo "External Internal IP Address"
curl ifconfig.me
echo
echo '# IP Address' >> /root/.zshrc
echo 'hostname -I' >> /root/.zshrc
echo
echo '# Go' >> /root/.zshrc
echo 'export GOPATH=$HOME/work' >> /root/.zshrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /root/.zshrc
echo 'export HISTCONTROL=ignoredups' >> /root/.zshrc
echo
# Metasploit Setup
cd /opt
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
echo
echo "Metasploit Ready Up"
systemctl start postgresql
msfdb init
echo
# Yeet
echo
cd /opt
echo "ShellPhish"
cd /opt
git clone https://github.com/aryanguenthner/shellphish.git
echo
echo "Malicious Macro Builder"
cd /opt
git clone https://github.com/infosecn1nja/MaliciousMacroMSBuild.git
echo
echo "metagoofil"
sudo apt -y install metagoofil
echo
echo "Setting up Knock - Subdomain Finder"
cd /opt
git clone https://github.com/guelfoweb/knock.git
cd knock
#nano knockpy/config.json <- set your virustotal API_KEY
pip install -e .
echo
echo "Subbrute"
cd /opt
git clone https://github.com/TheRook/subbrute.git
echo
echo "dnstwister"
cd /opt
git clone https://github.com/elceef/dnstwist.git
sudo apt-get -y install python3-dnspython python3-geoip python3-whois python3-requests python3-ssdeep python3-dns
echo
echo "RDPY"
cd /opt
git clone https://github.com/citronneur/rdpy.git
cd rdpy
sudo python setup.py install
echo
echo "EyeWitness"
cd /opt
git clone https://github.com/FortyNorthSecurity/EyeWitness.git
cd /opt/EyeWitness/Python/setup
sudo yes | ./setup.sh
echo
echo "Cewl"
cd /opt
git clone https://github.com/digininja/CeWL.git
gem install mime-types
gem install mini_exiftool
gem install rubyzip
gem install spider
echo
echo "This is going to take a minute hold my root-beer"
echo
echo "AD Recon - My Fav"
cd /opt
git clone https://github.com/sense-of-security/ADRecon.git
echo
echo "enum4linux-ng"
cd /opt
git clone https://github.com/cddmp/enum4linux-ng.git
echo
echo "BloodHound"
cd /opt
git clone https://github.com/BloodHoundAD/Bloodhound.git
echo
echo "bloodhound-python"
# bloodhound-python -u 'bob' -p 'Passw0rd!' -ns 192.168.1.3 -d LAB.local  -c all'
pip install bloodhound
echo
echo "Daniel Miessler Security List Collection"
cd /opt
git clone https://github.com/danielmiessler/SecLists.git
cd SecLists
echo
echo "Awesome Incident Response"
cd /opt
git clone https://github.com/meirwah/awesome-incident-response.git
echo
echo "Fuzzdb"
cd /opt
git clone https://github.com/fuzzdb-project/fuzzdb.git
echo
echo "Payloads All The Things"
cd /opt
git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git
echo
echo "OneListForAll"
cd /opt
git clone https://github.com/six2dez/OneListForAll.git
cd OneListForAll
# 7z x onelistforall.7z.001
wget https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule
wget https://github.com/NotSoSecure/password_cracking_rules/blob/master/OneRuleToRuleThemAll.rule
wget https://contest-2010.korelogic.com/rules.txt
cat rules.txt >> /etc/john/john.conf
echo
echo "SprayingToolKit"
cd /opt
git clone https://github.com/byt3bl33d3r/SprayingToolkit.git
: ' Nmap works dont forget --> nmap -Pn -p 445 -script smb-brute --script-args='smbpassword=Summer2019,smbusername=Administrator' 192.168.1.23 '
echo
: ' Hydra works dont forget --> hydra -p Summer2019 -l Administrator smb://192.168.1.23 '
: ' Metasploit works dont forget --> set smbpass Summer2019 / set smbuser Administrator / set rhosts 192.168.1.251 / run '
echo "Awesome XSS"
cd /opt
git clone https://github.com/s0md3v/AwesomeXSS.git
echo
echo "XSS Payloads"
cd /opt
git clone https://github.com/payloadbox/xss-payload-list.git
echo
echo "Foospidy Payloads"
cd /opt
git clone https://github.com/foospidy/payloads.git
echo
echo "Java Deserialization Exploitation (jexboss)"
cd /opt
git clone https://github.com/joaomatosf/jexboss.git
echo
echo "theHarvester"
cd /opt
git clone https://github.com/laramies/theHarvester.git
echo
echo "OWASP Cheat Sheet"
cd /opt
git clone https://github.com/OWASP/CheatSheetSeries.git
echo
echo "Pulse VPN Exploit"
cd /opt
git clone https://github.com/projectzeroindia/CVE-2019-11510.git

echo "hruffleHog - Git Enumeration"
cd /opt
git clone https://github.com/dxa4481/truffleHog.git

echo "Git Secrets"
cd /opt
git clone https://github.com/awslabs/git-secrets.git
echo
echo "Git Leaks"
cd /opt
git clone https://github.com/zricethezav/gitleaks.git
echo
echo "Discover Admin Loging Pages - Breacher"
cd /opt
git clone https://github.com/s0md3v/Breacher.git
echo
echo "Search Google Extract Result URLS - degoogle"
cd /opt
git clone https://github.com/deepseagirl/degoogle.git
echo
echo "Web SSH (Pretty Cool)"
cd /opt
git clone https://github.com/huashengdun/webssh.git
echo
echo "Installing Impacket"
cd /opt
pip3 install jinja2==2.10.1
git clone https://github.com/SecureAuthCorp/impacket.git
cd /opt
cd impacket
pip3 install -e .
echo
echo "GitRob"
cd /tmp
sudo wget --no-check-certificate https://github.com/michenriksen/gitrob/releases/download/v2.0.0-beta/gitrob_linux_amd64_2.0.0-beta.zip
unzip gitrob_linux_amd64_2.0.0-beta.zip
mkdir -p /opt/gitrob
mv gitrob /opt/gitrob/
echo
#echo "Google Play CLI" I wish this one actually worked
#apt -y install gplaycli
echo
echo "Lee Baird Discover Script"
cd /opt
git clone https://github.com/leebaird/discover.git
echo "Just Don't Update Kali Using the Lee Baird Discover Update Script"
echo
# Save these two for later
# git clone https://github.com/jschicht/RawCopy.git
# git clone https://github.com/khr0x40sh/MacroShop.git
echo
echo "Phone Info Gathering Tool"
cd /opt
git clone https://github.com/sundowndev/PhoneInfoga.git
cd PhoneInfoga
curl -sSL https://raw.githubusercontent.com/sundowndev/PhoneInfoga/master/support/scripts/install | bash\n
./phoneinfoga version
echo
echo "Hacker Hacker"
cd /opt
git clone https://github.com/aryanguenthner/365.git
cd 365
sudo dos2unix *.sh *.py && chmod +x *.sh *.py
echo
echo
#Tor Web Browser Stuff
echo
#sudo gpg --keyserver pool.sks-keyservers.net --recv-keys EB774491D9FF06E2 && 
apt -y install torbrowser-launcher
echo
cd /opt
git clone https://github.com/aryanguenthner/TorGhost.git
cd TorGhost
apt -y install python3-pyinstaller
apt -y install python3-notify2
pip3 install . --ignore-installed stem
sudo ./build.sh
echo
# MongoDB Install
echo
echo "Installing MongoDB 4.2 from Ubuntu Repo, Because It Works"
echo
cd /tmp
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list
apt update
apt -y install mongodb-org
service mongod start
systemctl enable mongod.service
echo "Hopefully MongoDB Installed"
echo
# Install Ivre.Rocks
echo
apt -y install ivre
echo
# Dependencies
pip install tinydb
pip install py2neo
echo
# Ivre Database init, data download & importation
echo
echo -e '\r'
yes | ivre ipinfo --init # Run to Clear Dashboard
yes | ivre scancli --init #Run to Clear Dashboard
yes | ivre view --init #Run to Clear Dashboard
yes | ivre flowcli --init
yes | ivre runscansagentdb --init
sudo ivre ipdata --download
echo -e '\r'
echo
# Nmap Magic
echo
echo "Copying IVRE Nmap Scripts to Nmap"
sudo apt -y install nmap
echo
cp /usr/share/ivre/nmap_scripts/*.nse /usr/share/nmap/scripts/
yes | patch /usr/share/nmap/scripts/rtsp-url-brute.nse \
/usr/share/ivre/nmap_scripts/patches/rtsp-url-brute.patch
nmap --script-updatedb
echo
# Enable Nmap to get Screenshots using Phantomjs v1.9.8
echo
cd /opt
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
tar xvf phantomjs-1.9.8-linux-x86_64.tar.bz2
mv phantomjs-1.9.8-linux-x86_64 phantomjs
mv phantomjs /opt
ln -s /opt/phantomjs/bin/phantomjs /usr/local/bin/phantomjs
phantomjs -v
echo
# Windows Exploit Suggester Next Gen
echo
cd /opt
sudo git clone https://github.com/bitsadmin/wesng.git
echo
# MobSF Setup
echo
echo "Installing MobSF on kali 2020.4"
# nano -c /opt/Mobile-Security-Framework-MobSF/run.sh
# MobSF working with Python 3.7/3.8
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
sudo update-alternatives --set python3 /usr/bin/python3.8/
echo
cd /opt/
git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
cd Mobile-Security-Framework-MobSF/
pip3 install -r requirements.txt
python3 -m venv ./venv
./setup.sh
echo
echo '# MobSF' >> /root/.zshrc
echo 'export ANDROID_SDK=/root/Android/Sdk/' >> /root/.zshrc
echo 'export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$PATH' >> /root/.zshrc
echo 'export PATH="/root/Android/Sdk/platform-tools":$PATH' >> /root/.zshrc
echo 'export PATH="/opt/android-studio/jre/jre/bin":$PATH' >> /root/.zshrc
echo '# Java Deez Nutz' >> /root/.zshrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /root/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /root/.zshrc
echo
sudo chmod -R 777 /home/kali/
echo
echo "Hacker Hacker"
systemctl restart ntp
source ~/.zshrc
echo
# VirtualBox Hack for USB Devices
usermod -a -G vboxusers $USER
apt --fix-broken install
updatedb
echo
date > kali-setup-finish-date.txt
# TODO: Add this to VLC https://broadcastify.cdnstream1.com/24051
reboot
# Taco Taco
# Gucci
