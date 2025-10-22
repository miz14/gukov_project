#!/bin/bash

# Скрипт удаления домена из конфигурации

if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <domain>"
    echo "Пример: $0 site3.example.com"
    exit 1
fi

DOMAIN="$1"
CONFIG_FILE="/etc/nginx/sites-available/docker-app-proxy"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Ошибка: Конфигурационный файл $CONFIG_FILE не найден"
    exit 1
fi

# Удаляем server block для домена
sed -i "/# Сервер для $DOMAIN/,/}/d" "$CONFIG_FILE"

nginx -t && systemctl reload nginx
echo "Домен $DOMAIN удален успешно!"