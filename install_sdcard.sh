#!/bin/bash

# Try to unmount partitions
sudo umount /dev/sda8
sudo umount /dev/sda7
sudo umount /dev/sda6

# Modify the repair script to use sda instead of nvme0n1
sed 's/nvme0n1/sda/g' ~/tools/repair_device.sh > ~/tools/repair_device_sda.sh
sudo chmod +x ~/tools/repair_device_sda.sh

echo
echo vvvvvvvvvv
echo "Please press PROCEED at the FIRST prompt to start."
echo "Then press CANCEL on the NEXT prompt to NOT reboot the machine."
echo ^^^^^^^^^^
echo
sleep 3

# Run the repair script
sudo ~/tools/repair_device_sda.sh all

# Delete automount sdcard udev rule
cmd echo "mount -o rw,remount / ; steamos-readonly disable; rm /usr/lib/udev/rules.d/99-sdcard-mount.rules" | steamos-chroot --disk /dev/sda --partset A --

cmd echo "mount -o rw,remount / ; steamos-readonly disable; rm /usr/lib/udev/rules.d/99-sdcard-mount.rules" | steamos-chroot --disk /dev/sda --partset B --

echo "Start to insert script!"

# Mount home partition and mkdir deck's home directory
sudo mkdir -p /run/media/home
sudo mount /dev/sda8 /run/media/home
sudo mkdir -p /run/media/home/deck/ &>/dev/null
sudo mkdir -p /run/media/home/deck/.ryanrudolf &>/dev/null
sudo chown deck:deck /run/media/home/deck
sudo chown deck:deck /run/media/home/deck/.ryanrudolf

# Copy post_install script
FILE="/run/media/home/deck/.ryanrudolf/post_install_sda.sh"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
sudo cp "$SCRIPT_DIR/post_install_sdcard.sh" "$FILE"
sudo chmod +x "$FILE"
sudo chown deck:deck "$FILE"

# Update .profile
cat <<EOF | sudo tee /run/media/home/deck/.profile >/dev/null
~/.ryanrudolf/post_install_sda.sh
EOF

sudo umount /run/media/home
echo "Done!"
