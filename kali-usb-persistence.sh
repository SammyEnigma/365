#!/usr/bin/env bash
#
# kali-usb.sh
#
# Writes a Kali Linux Live ISO to a USB drive and (optionally) sets up
# USB persistence, following the official Kali docs:
# https://www.kali.org/docs/usb/usb-persistence/
#
# This script is DESTRUCTIVE to whatever drive you point it at.
# It asks for confirmation multiple times before touching anything.

set -euo pipefail

# ---------------------------------------------------------------------------
# Config / defaults
# ---------------------------------------------------------------------------
DEFAULT_ISO="/home/kali/Downloads/kali-linux-2026.2-live-amd64.iso"
MOUNT_POINT="/mnt/my_usb"
MIN_USB_BYTES=$((8 * 1000 * 1000 * 1000))   # Kali docs: at least 8GB recommended

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BOLD="\e[1m"; RESET="\e[0m"

info()  { echo -e "${GREEN}[*]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[x]${RESET} $*" >&2; }
die()   { error "$*"; exit 1; }

require_root() {
    if [[ $EUID -ne 0 ]]; then
        die "Please run this script with sudo/root: sudo $0"
    fi
}

confirm() {
    local prompt="$1"
    local answer
    read -r -p "$(echo -e "${YELLOW}${prompt}${RESET} [y/N]: ")" answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

cleanup() {
    # Best-effort cleanup if the script exits early while mounted
    if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        umount "$MOUNT_POINT" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Step 0: sanity checks
# ---------------------------------------------------------------------------
require_root

for tool in lsblk dd fdisk mkfs.ext4 partprobe udevadm findmnt; do
    command -v "$tool" >/dev/null 2>&1 || warn "Tool '$tool' not found (some steps may fail)."
done

# 'pv' gives a real progress bar with elapsed/remaining time during the write.
# Optional — offer to install, otherwise fall back to dd's status=progress.
HAVE_PV=0
if command -v pv >/dev/null 2>&1; then
    HAVE_PV=1
else
    warn "'pv' is not installed — it enables a progress bar with a time estimate."
    if confirm "Install 'pv' now (sudo apt-get install -y pv)?"; then
        apt-get update -qq && apt-get install -y pv && HAVE_PV=1
    fi
fi

# ---------------------------------------------------------------------------
# Step 1: locate the ISO
# ---------------------------------------------------------------------------
read -r -p "Path to Kali Live ISO [${DEFAULT_ISO}]: " ISO_PATH
ISO_PATH="${ISO_PATH:-$DEFAULT_ISO}"

[[ -f "$ISO_PATH" ]] || die "ISO not found at: $ISO_PATH"
ISO_SIZE="$(stat -c%s "$ISO_PATH")"
info "Using ISO: $ISO_PATH ($(( ISO_SIZE / 1000 / 1000 )) MB)"

# ---------------------------------------------------------------------------
# Step 2: show block devices and ask user to confirm the target USB drive
# ---------------------------------------------------------------------------
echo
info "Current block devices:"
lsblk -d -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS
echo

read -r -p "Enter the target USB device (e.g. /dev/sda, WITHOUT partition number): " USB
[[ -b "$USB" ]] || die "Device '$USB' does not exist or is not a block device."

# Refuse to touch the disk that root is on
ROOT_SRC="$(findmnt -no SOURCE / || true)"
ROOT_DISK="/dev/$(lsblk -no PKNAME "$ROOT_SRC" 2>/dev/null || true)"
if [[ -n "$ROOT_DISK" && "$USB" == "$ROOT_DISK" ]]; then
    die "Refusing to write to $USB — this looks like your system's root disk!"
fi

# Kali docs recommend at least 8GB for the image + persistence partition
USB_BYTES="$(blockdev --getsize64 "$USB" 2>/dev/null || echo 0)"
if [[ "$USB_BYTES" -gt 0 && "$USB_BYTES" -lt "$MIN_USB_BYTES" ]]; then
    warn "This drive is $(( USB_BYTES / 1000 / 1000 )) MB — Kali recommends at least 8GB for image + persistence."
    if ! confirm "Continue anyway?"; then
        die "Aborted — drive too small."
    fi
fi

echo
info "Details for $USB:"
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS "$USB"
echo

warn "ALL DATA on ${BOLD}${USB}${RESET}${YELLOW} will be PERMANENTLY ERASED.${RESET}"
if ! confirm "Are you SURE ${USB} is the correct USB drive?"; then
    die "Aborted by user."
fi

read -r -p "Type the device name again to confirm (${USB}): " CONFIRM_USB
[[ "$CONFIRM_USB" == "$USB" ]] || die "Confirmation did not match. Aborted."

# Unmount any mounted partitions on that device first
for part in $(lsblk -lno PATH "$USB" | tail -n +2); do
    if mount | grep -qF "$part "; then
        info "Unmounting $part"
        umount "$part" || true
    fi
done

# ---------------------------------------------------------------------------
# Step 3: ask about persistence
# ---------------------------------------------------------------------------
WANT_PERSISTENCE=0
if confirm "Do you want to set up Kali USB Persistence?"; then
    WANT_PERSISTENCE=1
    info "Persistence will be configured after imaging the USB."
else
    info "Skipping persistence setup — this will be a plain Live USB."
fi

# ---------------------------------------------------------------------------
# Step 4: write the ISO to the USB
# ---------------------------------------------------------------------------
echo
info "Writing ISO to $USB — this can take several minutes..."

if [[ "$HAVE_PV" -eq 1 ]]; then
    # -p progress bar, -t elapsed time, -e ETA (remaining time), -r rate, -b bytes done
    pv -s "$ISO_SIZE" -ptearb "$ISO_PATH" | dd of="$USB" bs=4M conv=fsync,notrunc
else
    dd if="$ISO_PATH" of="$USB" bs=4M status=progress conv=fsync
fi

sync
partprobe "$USB" || true
udevadm settle || true
info "ISO write complete."

if [[ "$WANT_PERSISTENCE" -eq 0 ]]; then
    echo
    info "Done. You now have a plain Kali Live USB on ${USB}."
    exit 0
fi

# ---------------------------------------------------------------------------
# Step 5: create the persistence partition (Kali docs)
# ---------------------------------------------------------------------------
echo
info "Creating a new partition for persistence on ${USB}..."

fdisk "$USB" <<EOF
p
n
p
3


p
w
EOF

sync
partprobe "$USB" || true
udevadm settle || true
sleep 2

echo
info "Updated partition table:"
lsblk "$USB"
echo

# Detect partition naming scheme (handles /dev/sdX vs /dev/nvmeXnY or /dev/mmcblkX)
if [[ "$USB" =~ [0-9]$ ]]; then
    PART3="${USB}p3"
else
    PART3="${USB}3"
fi

if [[ ! -b "$PART3" ]]; then
    PART3_NAME=$(lsblk -lno NAME,TYPE "$USB" | awk '$2=="part" {print $1}' | tail -n 1)
    PART3="/dev/$PART3_NAME"
fi

[[ -b "$PART3" ]] || die "Expected persistence partition ${PART3} was not found. Check 'lsblk ${USB}' manually."

warn "About to format ${PART3} as ext4 labeled 'persistence'."
if ! confirm "Proceed with formatting ${PART3}?"; then
    die "Aborted before formatting. USB image is written, but persistence is NOT configured."
fi

# ---------------------------------------------------------------------------
# Step 6: format, mount, write persistence.conf, unmount
# ---------------------------------------------------------------------------
info "Formatting ${PART3} as ext4 (label: persistence)..."
mkfs.ext4 -F -L persistence "$PART3"

info "Mounting ${PART3} at ${MOUNT_POINT}..."
mkdir -pv "$MOUNT_POINT"
mount "$PART3" "$MOUNT_POINT"

info "Writing persistence.conf..."
echo "/ union" | tee "${MOUNT_POINT}/persistence.conf" >/dev/null

info "Unmounting ${PART3}..."
umount "$PART3"
rmdir "$MOUNT_POINT"

echo
info "Done! Persistence partition created and configured on ${PART3}."
echo
echo "Next steps:"
echo "  1. Boot from ${USB}."
echo "  2. At the Kali boot menu, choose 'Live USB Persistence'."
echo "  3. Files you save while running Live will now persist across reboots."
