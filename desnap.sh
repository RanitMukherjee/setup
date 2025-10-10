#!/bin/bash

# Improved Auto-Desnapping Script for Ubuntu (22.04/24.04+)
# Automatically removes all snaps, snapd, cleans files, and prevents reinstallation
# No manual edits needed; handles dynamics and errors safely

set -euo pipefail  # Strict mode: exit on error, undefined vars, pipe failures

echo "=== Ubuntu Auto-Desnap Script ==="
echo "Warning: This will remove ALL snaps (including Firefox) and snapd. Backup first!"
echo "Proceed? (y/N)"
read -r confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 1
fi

# Step 1: List installed snaps for logging
echo -e "\nStep 1: Listing installed snaps..."
snap list | tee desnap-log.txt

# Step 2: Disable and mask snapd services
echo -e "\nStep 2: Disabling snapd services..."
systemctl disable --now snapd.socket snapd.service snapd.seeded.service 2>/dev/null || true
systemctl mask snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true

# Step 3: Remove all snaps dynamically (excluding snapd itself)
echo -e "\nStep 3: Removing all snaps with --purge..."
while read -r snap_name version rev tracking publisher notes; do
    if [[ "$snap_name" != "snapd" && -n "$snap_name" ]]; then
        echo "Removing $snap_name..."
        snap remove --purge "$snap_name" 2>/dev/null || true
    fi
done < <(snap list | awk 'NR>1 {print $1, $2, $3, $4, $5, $6}')

# Wait for removals to settle
sleep 5

# Step 4: Purge snapd package
echo -e "\nStep 4: Purging snapd via apt..."
apt update -qq
apt purge -y snapd || apt remove -y snapd  # Fallback to remove if purge fails

# Step 5: Clean leftover directories and user snaps
echo -e "\nStep 5: Cleaning directories and cache..."
rm -rf /var/snap /var/lib/snapd /var/cache/snapd /snap ~/snap /home/*/snap 2>/dev/null || true
rm -f /etc/apt/sources.list.d/*snap*

# Step 6: Prevent reinstallation - Hold snapd and apt pinning
echo -e "\nStep 6: Holding snapd and creating apt pinning..."
apt-mark hold snapd 2>/dev/null || true
cat > /etc/apt/preferences.d/nosnap.pref << EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# Step 7: Final update and verification
echo -e "\nStep 7: Updating apt and verifying..."
apt update -qq
if command -v snap >/dev/null 2>&1; then
    echo "Warning: Snap command still available; reboot to fully purge."
else
    echo "Snapd removed successfully!"
fi
if systemctl is-enabled snapd >/dev/null 2>&1; then
    echo "Warning: Snapd service still enabled; check manually."
else
    echo "Snapd services disabled/masked."
fi

echo -e "\n=== Desnapping Complete! ==="
echo "Log saved to desnap-log.txt"
echo "Reboot now: sudo reboot"
echo "Post-reboot: Install Firefox deb via 'sudo add-apt-repository ppa:mozillateam/ppa && sudo apt update && sudo apt install firefox' [web:7]"
echo "For app store: sudo apt install gnome-software [web:6]"

