#!/bin/bash

# Проверка root прав
if [ "$EUID" -ne 0 ]; then
  echo "Запустите скрипт с sudo!"
  exit 1
fi

# Предупреждение о опасности
echo -e "\033[1;31mВНИМАНИЕ! Этот скрипт уничтожит ВСЕ данные на /dev/sda!\033[0m"
read -p "Вы уверены что хотите продолжить? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

# Принудительное размонтирование
echo "Шаг 1/6: Принудительное размонтирование разделов"
for partition in /dev/sda*; do
  umount -l $partition 2>/dev/null
done
swapoff -a

# Убийство процессов использующих диск
echo "Шаг 2/6: Завершение процессов использующих диск"
lsof +f -- /dev/sda* | awk 'NR>1 {print $2}' | sort | uniq | xargs -r kill -9
sleep 2

# Модификация скрипта восстановления
echo "Шаг 3/6: Подготовка скрипта восстановления"
sed 's/nvme0n1/sda/g; s/--disk "${disk}"/--disk "${disk}" --no-reread/g' ~/tools/repair_device.sh > ~/tools/repair_device_hdd.sh
chmod +x ~/tools/repair_device_hdd.sh

# Запуск процесса установки
echo "Шаг 4/6: Запуск установки SteamOS"
echo -e "\n\033[33mНа первом запросе выберите PROCEED, на втором - CANCEL\033[0m\n"
~/tools/repair_device_hdd.sh --no-reread all

# Повторное размонтирование
echo "Шаг 5/6: Финализация установки"
umount -l /dev/sda* 2>/dev/null
swapoff -a

# Настройка окружения
echo "Шаг 6/6: Настройка пост-установочных скриптов"
mkdir -p /run/media/home
mount /dev/sda8 /run/media/home

mkdir -p /run/media/home/deck/.ryanrudolf
cp post_install_hdd.sh /run/media/home/deck/.ryanrudolf/
chmod +x /run/media/home/deck/.ryanrudolf/post_install_hdd.sh
chown -R deck:deck /run/media/home/deck

# Добавление в автозагрузку
echo "~/.ryanrudolf/post_install_hdd.sh" >> /run/media/home/deck/.profile

umount /run/media/home

echo -e "\n\033[32mУстановка завершена! Выполните перезагрузку.\033[0m"
