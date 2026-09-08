#!/bin/bash
#
# change-login-background.sh
# Detects the active display manager (LightDM or GDM3) and sets a custom
# login-screen background image.
#
set -euo pipefail

BACKGROUND_DIR="/usr/share/backgrounds"

# ---------------------------------------------------------------------------
# 1. Detect the display manager in use
# ---------------------------------------------------------------------------
detect_display_manager() {
    if [ -f /etc/X11/default-display-manager ]; then
        basename "$(cat /etc/X11/default-display-manager)"
        return
    fi

    if systemctl list-unit-files 2>/dev/null | grep -qi '^lightdm.service'; then
        echo "lightdm"
    elif systemctl list-unit-files 2>/dev/null | grep -qi '^gdm3.service\|^gdm.service'; then
        echo "gdm3"
    elif command -v lightdm >/dev/null 2>&1; then
        echo "lightdm"
    elif command -v gdm3 >/dev/null 2>&1; then
        echo "gdm3"
    else
        echo "unknown"
    fi
}

DM="$(detect_display_manager)"
echo "Detected display manager: ${DM}"

if [[ "$DM" != "lightdm" && "$DM" != "gdm3" ]]; then
    echo "Error: no supported display manager (LightDM or GDM3) detected." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Ask the user for the path to the image
# ---------------------------------------------------------------------------
read -rp "Enter full path to the image to use as the lock/login screen background: " IMG_PATH

if [ ! -f "$IMG_PATH" ]; then
    echo "Error: file '$IMG_PATH' not found." >&2
    exit 1
fi

FILENAME="$(basename "$IMG_PATH")"
DEST_PATH="${BACKGROUND_DIR}/${FILENAME}"

echo "This will:"
echo "  1. Copy '${IMG_PATH}' to '${DEST_PATH}'"
echo "  2. Update the ${DM} greeter config to use it"
echo "  3. Prompt you to reboot"
read -rp "Continue? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# ---------------------------------------------------------------------------
# 3. Copy the image into place
# ---------------------------------------------------------------------------
sudo cp "$IMG_PATH" "$DEST_PATH"
sudo chmod 644 "$DEST_PATH"
echo "Copied image to ${DEST_PATH}"

# ---------------------------------------------------------------------------
# 4. Update the appropriate greeter config
# ---------------------------------------------------------------------------
if [ "$DM" == "lightdm" ]; then
    CONF="/etc/lightdm/lightdm-gtk-greeter.conf"

    # Make sure the file and [greeter] section exist
    sudo touch "$CONF"
    if ! grep -q '^\[greeter\]' "$CONF" 2>/dev/null; then
        echo "[greeter]" | sudo tee -a "$CONF" >/dev/null
    fi

    if grep -q '^background\s*=' "$CONF"; then
        sudo sed -i "s|^background\s*=.*|background=${DEST_PATH}|" "$CONF"
    else
        sudo sed -i "/^\[greeter\]/a background=${DEST_PATH}" "$CONF"
    fi

    echo "Updated ${CONF}:"
    grep -A2 '^\[greeter\]' "$CONF"

elif [ "$DM" == "gdm3" ]; then
    # GDM3 uses gsettings/dconf against its own login-session user (Debian/Kali),
    # not a plain text file like LightDM.
    echo "GDM3 detected. Applying background via gsettings for the greeter user..."
    sudo -u Debian-gdm dbus-launch gsettings set org.gnome.desktop.background picture-uri "file://${DEST_PATH}" 2>/dev/null \
        || echo "Note: adjust the greeter user/schema for your distro if this failed."
fi

# ---------------------------------------------------------------------------
# 5. Confirm and reboot
# ---------------------------------------------------------------------------
read -rp "Changes applied. Reboot now to see them on the login screen? [y/N] " DO_REBOOT
if [[ "$DO_REBOOT" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    echo "Reboot skipped. Changes will apply on next reboot or greeter restart."
fi
