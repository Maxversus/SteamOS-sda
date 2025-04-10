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

echo "Done!"
