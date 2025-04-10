#!/bin/bash

# Размонтирование разделов
sudo umount /dev/sda8 || true
sudo umount /dev/sda7 || true
sudo umount /dev/sda6 || true

# Модификация repair script
sed 's/nvme0n1/sda/g' ~/tools/repair_device.sh > ~/tools/repair_device_hdd.sh
sudo chmod +x ~/tools/repair_device_hdd.sh

echo
echo "vvvvvvvvvv"
echo "На первом запросе нажмите PROCEED для начала установки"
echo "На втором запросе нажмите CANCEL чтобы отменить перезагрузку"
echo "^^^^^^^^^^"
echo
sleep 3

# Запуск repair script
sudo ~/tools/repair_device_hdd.sh all

# Удаление udev rules
sudo steamos-chroot --disk /dev/sda --partset A -- rm -f /usr/lib/udev/rules.d/99-sdcard-mount.rules
sudo steamos-chroot --disk /dev/sda --partset B -- rm -f /usr/lib/udev/rules.d/99-sdcard-mount.rules

echo "Начинаем установку скриптов!"

# Монтирование home раздела
sudo mkdir -p /run/media/home
sudo mount /dev/sda8 /run/media/home

# Создание директорий
sudo mkdir -p /run/media/home/deck/.ryanrudolf
sudo chown -R deck:deck /run/media/home/deck

# Копирование post-install скрипта
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
sudo cp "$SCRIPT_DIR/post_install_hdd.sh" "/run/media/home/deck/.ryanrudolf/"
sudo chmod +x "/run/media/home/deck/.ryanrudolf/post_install_hdd.sh"
sudo chown deck:deck "/run/media/home/deck/.ryanrudolf/post_install_hdd.sh"

# Настройка .profile
echo -e "\n~/.ryanrudolf/post_install_hdd.sh" | sudo tee -a /run/media/home/deck/.profile >/dev/null

# Размонтирование
sudo umount /run/media/home
echo "Установка завершена!"
