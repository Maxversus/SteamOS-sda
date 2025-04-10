#!/bin/bash

# Попытка размонтирования разделов
sudo umount /dev/sda8
sudo umount /dev/sda7
sudo umount /dev/sda6

# Модифицируем repair_device.sh для использования sda вместо nvme0n1
sed 's/nvme0n1/sda/g' ~/tools/repair_device.sh > ~/tools/repair_device_hdd.sh
sudo chmod +x ~/tools/repair_device_hdd.sh

echo
echo vvvvvvvvvv
echo На первом запросе нажмите PROCEED для начала установки
echo На втором запросе нажмите CANCEL чтобы отменить перезагрузку
echo ^^^^^^^^^^
echo
sleep 3

# Запуск скрипта восстановления
sudo ~/tools/repair_device_hdd.sh all

# Удаляем правило automount для SD-карты (если присутствует)
cmd echo "mount -o rw,remount / ; steamos-readonly disable; rm -f /usr/lib/udev/rules.d/99-sdcard-mount.rules" | steamos-chroot --disk /dev/sda --partset A --
cmd echo "mount -o rw,remount / ; steamos-readonly disable; rm -f /usr/lib/udev/rules.d/99-sdcard-mount.rules" | steamos-chroot --disk /dev/sda --partset B --

echo Начинаем установку скриптов!

# Монтируем home раздел
sudo mkdir -p /run/media/home
sudo mount /dev/sda8 /run/media/home

# Создаем директории и копируем скрипты
sudo mkdir -p /run/media/home/deck/.ryanrudolf
sudo chown -R deck:deck /run/media/home/deck

FILE=/run/media/home/deck/.ryanrudolf/post_install_hdd.sh
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
sudo cp "$SCRIPT_DIR/post_install_hdd.sh" "$FILE"
sudo chmod +x "$FILE"
sudo chown deck:deck "$FILE"

# Добавляем автозапуск в .profile
cat > /run/media/home/deck/.profile <<EOF
~/.ryanrudolf/post_install_hdd.sh
EOF

sudo umount /run/media/home
echo "Установка завершена!"
