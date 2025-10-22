#!/bin/bash

# Скрипт настройки nginx reverse proxy для Docker контейнеров
set -e

echo "=== Настройка nginx reverse proxy ==="

# Переменные
DOMAIN1="${1:-site1.example.com}"
DOMAIN2="${2:-site2.example.com}"
DOCKER_PORT1="${3:-8001}"
DOCKER_PORT2="${4:-8002}"
NGINX_DIR="/etc/nginx"
SITES_AVAILABLE="$NGINX_DIR/sites-available"
SITES_ENABLED="$NGINX_DIR/sites-enabled"
SITE_CONFIG="docker-app-proxy"

# Проверка прав
if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: Скрипт должен запускаться с правами root"
    echo "Используйте: sudo ./setup-nginx-proxy.sh [domain1] [domain2] [port1] [port2]"
    exit 1
fi

# Проверка установки nginx
if ! command -v nginx &> /dev/null; then
    echo "Установка nginx..."
    apt update
    apt install -y nginx
fi

# Создание конфигурации nginx
echo "Создание конфигурации для доменов:"
echo "  - $DOMAIN1 -> reverse-proxy:$DOCKER_PORT1"
echo "  - $DOMAIN2 -> reverse-proxy:$DOCKER_PORT2"

cat > "/tmp/$SITE_CONFIG" << EOF
# Reverse Proxy конфигурация для Docker приложений
# Файл создан автоматически скриптом setup-nginx-proxy.sh

# Сервер для $DOMAIN1
server {
    listen 80;
    server_name $DOMAIN1 www.$DOMAIN1;

    # Базовые настройки
    client_max_body_size 100M;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 600;

    location / {
        proxy_pass http://reverse-proxy:$DOCKER_PORT1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        
        # Дополнительные настройки прокси
        proxy_redirect off;
        proxy_buffering off;
    }

    # Логи
    access_log /var/log/nginx/${DOMAIN1}_access.log;
    error_log /var/log/nginx/${DOMAIN1}_error.log;
}

# Сервер для $DOMAIN2
server {
    listen 80;
    server_name $DOMAIN2 www.$DOMAIN2;

    # Базовые настройки
    client_max_body_size 100M;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 600;

    location / {
        proxy_pass http://reverse-proxy:$DOCKER_PORT2;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        
        # Дополнительные настройки прокси
        proxy_redirect off;
        proxy_buffering off;
    }

    # Логи
    access_log /var/log/nginx/${DOMAIN2}_access.log;
    error_log /var/log/nginx/${DOMAIN2}_error.log;
}

# Блокировка всех других доменов
server {
    listen 80 default_server;
    server_name _;
    return 444;
}
EOF

# Копируем конфигурацию в nginx
echo "Копирование конфигурации в nginx..."
cp "/tmp/$SITE_CONFIG" "$SITES_AVAILABLE/$SITE_CONFIG"

# Создаем симлинк в sites-enabled если его нет
if [ ! -L "$SITES_ENABLED/$SITE_CONFIG" ]; then
    ln -s "$SITES_AVAILABLE/$SITE_CONFIG" "$SITES_ENABLED/$SITE_CONFIG"
fi

# Отключаем дефолтный сайт nginx если он есть
if [ -L "$SITES_ENABLED/default" ]; then
    rm "$SITES_ENABLED/default"
    echo "Отключен дефолтный сайт nginx"
fi

# Проверяем синтаксис nginx
echo "Проверка синтаксиса nginx..."
nginx -t

# Перезапускаем nginx
echo "Перезапуск nginx..."
systemctl restart nginx

# Проверяем статус
echo "Проверка статуса nginx..."
systemctl status nginx --no-pager

echo ""
echo "=== Настройка завершена успешно! ==="
echo ""
echo "Домены настроены:"
echo "  http://$DOMAIN1 -> Docker контейнер на порту $DOCKER_PORT1"
echo "  http://$DOMAIN2 -> Docker контейнер на порту $DOCKER_PORT2"
echo ""
echo "Не забудьте настроить DNS записи для ваших доменов!"
echo "A записи должны указывать на IP: $(hostname -I | awk '{print $1}')"
echo ""
echo "Для проверки используйте:"
echo "  curl -H 'Host: $DOMAIN1' http://localhost"
echo "  или"
echo "  curl http://$DOMAIN1"