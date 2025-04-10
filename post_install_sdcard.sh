#!/bin/bash

# Проверка и установка пароля
if [ "$(passwd --status deck | tr -s " " | cut -d " " -f 2)" != "P" ]; then
    echo "deck:deck" | sudo chpasswd
fi

# Отключение automount
sudo steamos-readonly disable
sudo rm -f /usr/lib/udev/rules.d/99-sdcard-mount.rules
sudo udevadm control --reload
sudo udevadm trigger

# Настройка сервисов
if ! systemctl list-unit-files | grep -q hdd_minimize_write; then
    cat <<EOF | sudo tee /etc/systemd/system/hdd_minimize_write.service >/dev/null
[Unit]
Description=Minimize HDD writes
[Service]
ExecStart=/bin/sh -c 'for m in \$(mount | grep sda | cut -d" " -f3); do mount -o remount,noatime \$m; done'
[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable hdd_minimize_write
    sudo systemctl start hdd_minimize_write
fi

sudo steamos-readonly enable
