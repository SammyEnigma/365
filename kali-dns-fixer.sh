#!/bin/bash

echo "=== Fix DNS (Linux) ==="
echo nameserver 1.1.1.1 > /etc/resolv.conf
echo nameserver 8.8.8.8 >> /etc/resolv.conf

# -------------------------
# 1. Flush Linux DNS cache
# -------------------------
echo "[+] Flushing system DNS cache..."
if command -v systemd-resolve >/dev/null 2>&1; then
    sudo systemd-resolve --flush-caches
elif command -v resolvectl >/dev/null 2>&1; then
    sudo resolvectl flush-caches
else
    echo "[!] DNS flush command not found on this system."
fi

# -------------------------
# 2. Clear Chrome host cache
# -------------------------
echo "[+] Clearing Chrome DNS cache..."

CHROME_URL="http://localhost:9222"
TMP_FILE=$(mktemp)

# Enable remote debugging if needed
CHROME_PATH=$(command -v google-chrome || command -v chromium-browser || command -v chromium)

if [ -z "$CHROME_PATH" ]; then
    echo "[!] Chrome/Chromium not found. Skipping Chrome cache clear."
else
    echo "[+] Starting temporary Chrome instance with remote debugging port..."
    "$CHROME_PATH" --remote-debugging-port=9222 --user-data-dir=$(mktemp -d) >/dev/null 2>&1 &
    CHROME_PID=$!

    # Wait for Chrome to initialize
    sleep 3

    # Clear host cache
    curl -s "$CHROME_URL/json" >/dev/null 2>&1
    curl -s "$CHROME_URL/json/clear-host-cache" >/dev/null 2>&1
    curl -s "$CHROME_URL/json/flush-socket-pools" >/dev/null 2>&1

    kill $CHROME_PID >/dev/null 2>&1
    echo "[+] Chrome DNS + socket pools cleared."
fi

# -------------------------
# 3. Disable Chrome Secure DNS (Linux)
# -------------------------
echo "[+] Fixing Disabling Chrome Secure DNS..."

PREFS_DIR="$HOME/.config/google-chrome/Default"
CHROMIUM_DIR="$HOME/.config/chromium/Default"

if [ -d "$PREFS_DIR" ]; then
    sed -i 's/"dns_over_https":{"enabled":true/"dns_over_https":{"enabled":false/g' "$PREFS_DIR/Preferences"
    echo "[+] Chrome Secure DNS disabled."
elif [ -d "$CHROMIUM_DIR" ]; then
    sed -i 's/"dns_over_https":{"enabled":true/"dns_over_https":{"enabled":false/g' "$CHROMIUM_DIR/Preferences"
    echo "[+] Chromium Secure DNS disabled."
else
    echo "[!] Preferences file not found. Secure DNS may still be enabled."
fi

# -------------------------
# 4. Open captive portal trigger page (non-HTTPS)
# -------------------------
echo "[+] Opening captive portal test page..."
xdg-open "http://ipleak.net" >/dev/null 2>&1

echo "=== Done! Welcome back to the real world. ==="
