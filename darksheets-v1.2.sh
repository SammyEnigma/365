#!/usr/bin/env bash
#######################################################
# Made for OSINT CTI cyber security research on the Dark Deep Web
# Intended to be used on Kali Linux
# Updated for compatibility and better Tor handling
# Hacked on 02/09/2025, pay me later
# Great ideas
# install_addon "https://addons.mozilla.org/firefox/downloads/file/4141345/noscript-11.4.26.xpi" "noscript"
# install_addon "https://addons.mozilla.org/firefox/downloads/file/4125998/adblock_plus-3.17.1.xpi" "adblock_plus"
# install_addon "https://addons.mozilla.org/firefox/downloads/file/4151024/sponsorblock-5.4.15.xpi" "sponsorblock"
######################################################

# Banner
cat <<'EOF'
██████╗░░█████╗░██████╗░██╗░░██╗░██████╗██╗░░██╗███████╗███████╗████████╗░██████╗
██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔════╝██║░░██║██╔════╝██╔════╝╚══██╔══╝██╔════╝
██║░░██║███████║██████╔╝█████═╝░╚█████╗░███████║█████╗░░█████╗░░░░░██║░░░╚█████╗░
██║░░██║██╔══██║██╔══██╗██╔═██╗░░╚═══██╗██╔══██║██╔══╝░░██╔══╝░░░░░██║░░░░╚═══██╗
██████╔╝██║░░██║██║░░██║██║░╚██╗██████╔╝██║░░██║███████╗███████╗░░░██║░░░██████╔╝
╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝░░░╚═╝░░░╚═════╝░
EOF
echo "OSINT CTI Cyber Threat intelligence v1.2"
# Darksheets is meant for researchers and educational purposes only. This was developed to speed the investigation, enable clear documentation without pain and suffering. Pay me later.
# Consider using spiderfoot,redtiger
# https://github.com/smicallef/spiderfoot
# https://github.com/loxy0dev/RedTiger-Tools
echo "sudo ./darksheets-v1.2.sh"
echo
# Todays Date
sudo timedatectl set-timezone America/Los_Angeles
echo -e "\e[034mToday is\e[0m"
date '+%Y-%m-%d %r' | tee darksheets.run.date
# Setting Variables
CITY=$(curl -s http://ip-api.com/line?fields=timezone | cut -d "/" -f 2)
PWD=$(pwd)
RED='\033[31m'
#RANDOM=$$
echo

# Network Information
echo -e "\e[031mGetting Network Information\e[0m"
# Get public IP, Before Connecting to Dark Web
# Get location details using ipinfo.io
# Fetch Public IP using multiple sources (fallback if one fails)
EXT=$(curl -s https://api64.ipify.org || curl -s https://ifconfig.me || curl -s https://checkip.amazonaws.com)

# If IP is still empty, set a default message
if [[ -z "$EXT" ]]; then
    EXT="Unavailable"
fi

# Get location details using ipinfo.io
LOCATION=$(curl -s ipinfo.io/json)
COUNTRY=$(echo "$LOCATION" | jq -r '.country')
REGION=$(echo "$LOCATION" | jq -r '.region')
CITY=$(echo "$LOCATION" | jq -r '.city')

# Get local Kali IP
KALI=$(hostname -I | awk '{print $1}')

# Print in table format
echo "---------------------------------"
printf "| %-12s | %-20s |\n" "Label" "Value"
echo "---------------------------------"
#printf "| %-12s | %-20s |\n" "Public IP" "$EXT"
printf "| %-12s | %-20s |\n" "Country" "$COUNTRY"
printf "| %-12s | %-20s |\n" "State" "$REGION"
#printf "| %-12s | %-20s |\n" "City" "$CITY"
printf "| %-12s | %-20s |\n" "Kali IP" "$KALI"
echo "---------------------------------"
echo

# Dependencies Check
# Must have LibreOffice,TheDevilsEye,Tor,TorGhost,OnionVerifier,FireFox
echo "Checking Requirements"
sudo apt-get install -y tor torbrowser-launcher python3-stem  > /dev/null 2>&1
# Simulated Progress Bar
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
echo
echo "Config Looks Good So Far"
echo
# Python3 Verify Onion Links
#OINFO=/opt/365/onion_verifier.py
#if [ -f "$OINFO" ]
#then
#    echo -e "\e[031mFound Onion Verifier\e[0m"
#else
#    echo -e "\e[031mGetting Onion Verifier\e[0m"
#    sudo cp /opt/365/onion_verifier.py "$PWD"
#fi
#echo

# Verify LibreOffice is installed
L=/usr/bin/libreoffice
if [ -f "$L" ]
then
    echo -e "\e[031mFound LibreOffice\e[0m"
else
    echo -e "\e[031mPlease wait while LibreOffice is installed\e[0m"
    sudo apt-get install -y libreoffice
fi

# Editing Firefox about:config this allows DarkWeb .onion links to be opened with Firefox
#echo 'user_pref("network.dns.blockDotOnion", false);' > user.js
#sudo mv user.js /home/kali/.mozilla/firefox/*default-esr/
USER_JS_PATH=$(find /home/kali/.mozilla/firefox/ -name "user.js" | head -n 1)

if [[ -f "$USER_JS_PATH" ]]; then
    if ! grep -q 'user_pref("network.dns.blockDotOnion", false);' "$USER_JS_PATH"; then
        echo 'user_pref("network.dns.blockDotOnion", false);' >> "$USER_JS_PATH"
    fi
else
    echo 'user_pref("network.dns.blockDotOnion", false);' > user.js
    sudo mv user.js /home/kali/.mozilla/firefox/*default-esr/
fi
echo

TORNG=/usr/bin/torghostng
if [ -f "$TORNG" ]
then
    echo -e "\e[031mFound TorghostNG\e[0m"
    echo
else
    echo
    sudo git clone https://github.com/aryanguenthner/torghostng /opt/torghostng
    cd /opt/torghostng
    sudo touch /etc/sysctl.conf
    sudo python3 install.py
    echo "TorghostNG is installed"
fi

# Verify the Devil exists
#E=/usr/local/bin/eye
E=/root/.local/share/pipx/venvs/thedevilseye/bin/eye
if [ -f "$E" ]
then
    echo -e "\e[031mFound The Devil\e[0m"
else
    echo -e "\e[031mGetting the Devil\e[0m"
    sudo pipx install thedevilseye==2022.1.4.0 > /dev/null 2>&1
    echo
    echo "The Devil's in your computer"
fi
echo

# What are you researching?
#echo -en "\e[031mWhat are you researching: \e[0m"
#read -e SEARCH
read -p "What are you researching: " SEARCH
echo
echo -e "\nSearching for $SEARCH"
echo

# Simulate Progress Bar
echo "Searching for Onions..."
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
echo

# Create Results File
# Perform Devils Eye Search
RESULTS_FILE=results.onion.csv
sudo /root/.local/share/pipx/venvs/thedevilseye/bin/eye -q "$SEARCH" | grep ".onion" > "$RESULTS_FILE"
sed '/^invest/d; /^222/d; /\.onion$/!d' "$RESULTS_FILE" > "$RESULTS_FILE.tmp" && mv "$RESULTS_FILE.tmp" "$RESULTS_FILE"
sort -u "$RESULTS_FILE" -o "$RESULTS_FILE"
echo -e "\e[31mOnions Found:\e[0m $(wc -l < "$RESULTS_FILE")"
echo

# Display 10 Results
head "$RESULTS_FILE"
echo
echo "Saved results to "$PWD"/"$RESULTS_FILE""
echo

# Check for TOR Connection
echo "Starting Tor service"
sudo systemctl start tor
echo

echo "Attempting to connect to the Dark Web..."
echo
# Starting Tor in the Netherlands
# Example Country Codes: nl,de,us,ca,mx,ru,br,bo,gb,fr,ir,by,cn
sudo torghostng -id nl
echo
echo -e "\e[031mEstablishing dark web connection:\e[0m"
    
# Simulated Progress Bar
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
echo
echo -e "\e[31mConnection Established. You can now access .onion sites.\e[0m $COUNT"

# Get Dark Web IP
# Get location details using ipinfo.io
# Fetch Public IP using multiple sources (fallback if one fails)
# Check if connected to Tor & extract IP correctly
TOR_IP_JSON=$(curl --socks5-hostname 127.0.0.1:9050 -s --max-time 4 https://check.torproject.org/api/ip)
TOR_IP=$(echo "$TOR_IP_JSON" | jq -r '.IP // empty')

# Fetch Public IP and Location
if [[ -n "$TOR_IP" ]]; then
    EXT="$TOR_IP"
    LOCATION=$(curl --socks5-hostname 127.0.0.1:9050 -s "http://ip-api.com/json/$EXT")
else
    EXT=$(curl -s https://api64.ipify.org || curl -s https://ifconfig.me || curl -s https://checkip.amazonaws.com)
    LOCATION=$(curl -s "http://ip-api.com/json/$EXT")
fi

# Extract Country, State, and City (Handle Errors)
COUNTRY=$(echo "$LOCATION" | jq -r '.country // "Unavailable"')
REGION=$(echo "$LOCATION" | jq -r '.regionName // "Unavailable"')
CITY=$(echo "$LOCATION" | jq -r '.city // "Unavailable"')
# Get local Kali IP
KALI=$(hostname -I | awk '{print $1}')

# Print in table format
echo "---------------------------------"
printf "| %-12s | %-20s |\n" "Label" "Value"
echo "---------------------------------"
printf "| %-12s | %-20s |\n" "Public IP" "$EXT"
printf "| %-12s | %-20s |\n" "Country" "$COUNTRY"
printf "| %-12s | %-20s |\n" "State" "$REGION"
printf "| %-12s | %-20s |\n" "City" "$CITY"
printf "| %-12s | %-20s |\n" "Kali IP" "$KALI"
echo "---------------------------------"
echo
COUNT=$(wc -l < "$RESULTS_FILE")
chmod -R 777 "$PWD"
echo
echo -e "\e[31mGetting More Info on Onions\e[0m $COUNT"
python3 onion_verifier.py | tee onion_verifier.log
echo

ONIONS=onion_page_titles.csv
# Darksheets Results
echo
echo -e "\e[031mOpening DarkSheets results with LibreOffice\e[0m"
echo

# Open spreadsheet with all results
qterminal -e libreoffice --calc "$PWD"/$ONIONS & disown > /dev/null 2>&1 &
echo "The $ONIONS have been saved to: "$PWD""
echo

# Open Firefox
echo -e "\e[031mPro Tip: Use NoScript on the Dark Web! Block Javascript!\e[0m"
#HIT1=$(awk 'FNR == 2 {print $1}' $ONIONS)
#HIT1=$(awk '$0 ~ /\.onion/ {print $0; exit}' $ONIONS)
#HIT1=$(awk '$0 ~ /\.onion/ {match($0, /http?:\/\/[^ ]*\.onion/); if (RSTART) print substr($0, RSTART, RLENGTH); exit}' $ONIONS)
# Extract top 3 unique .onion URLs matching the search query
readarray -t HITS < <(awk -v search="$SEARCH" '
    BEGIN { count = 0 }
    NR > 1 && $1 ~ /\.onion/ {  # Skip header, process .onion URLs
        url = $1;
        sub(/\.onion.*/, ".onion", url);  # Keep only the .onion domain
        
        title = tolower($2);
        search_lower = tolower(search);

        score = 0;
        if (index(title, search_lower)) { score += 10 }  # Strong match in title
        if (index(url, search_lower)) { score += 5 }      # Some match in URL

        results[url] = score;
    }
    END {
        # Sort results by score (descending) and print top 3 unique URLs
        n = 0;
        PROCINFO["sorted_in"] = "@val_num_desc"
        for (url in results) {
            print url
            if (++n == 3) break
        }
    }
' "$ONIONS")

# Assign extracted values (fallback to empty string if fewer than 3)
HIT1="${HITS[0]:-}"
HIT2="${HITS[1]:-}"
HIT3="${HITS[2]:-}"

# Debugging (optional)
echo "HIT1: $HIT1"
echo "HIT2: $HIT2"
echo "HIT3: $HIT3"
echo

echo "Opening Dark Web Sites in Firefox"
qterminal -e qterminal -e su -c "firefox $HIT1" kali & disown > /dev/null 2>&1 &
qterminal -e qterminal -e su -c "firefox $HIT2" kali & disown > /dev/null 2>&1 &
qterminal -e qterminal -e su -c "firefox $HIT3" kali & disown > /dev/null 2>&1 &
echo

RESULTS_FILE=results.onion.csv
echo "GoWitness Getting Screenshots, Be patient and let it run"
echo
qterminal -e ./gowitness file -f $RESULTS_FILE -p socks5://127.0.0.1:9050 & disown > /dev/null 2>&1 &&
PID1=$!
wait $PID1  # Wait for GoWitness screenshots to finish


echo "Starting GoWitness Server, Open http://localhost:7171/ when the screenshots are ready"
echo
qterminal -e ./gowitness server & disown > /dev/null 2>&1 &&
PID2=$!
sleep 5  # Allow the server some time to start

echo "Opening GoWitness Results in Firefox"
GOSERVER="http://localhost:7171/gallery"
qterminal -e qterminal -e su -c "firefox $GOSERVER" kali & disown > /dev/null 2>&1 &
echo

echo "Friendly reminder to exit the Dark Web type: torghostng -x"
# Ask the user if they want to disconnect from the dark web
echo
read -p "Do you want to disconnect from dark web? (y/n): " DISCONNECT 

if [[ "$DISCONNECT" == "y" || "$DISCONNECT" == "Y" ]]; then
echo
echo "⚡ Attempting to disconnect from the Dark Web..."

    echo
    echo "Exiting Dark Web"
    echo
    echo -e "\e[031mBack to the real world\e[0m"
    echo
    sudo torghostng -x

fi
echo

#Pay Me later
