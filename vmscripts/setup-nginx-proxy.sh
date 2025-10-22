#!/bin/bash

# Скрипт настройки nginx reverse proxy для Docker контейнеров
set -e

echo "=== Настройка nginx reverse proxy ==="

# Переменные
DOMAIN1="${DOMAIN1:-site1.example.com}"
DOMAIN2="${DOMAIN2:-site2.example.com}"
DOCKER_PORT1="${PORT1:-8001}"
DOCKER_PORT2="${PORT2:-8002}"
NGINX_DIR="/etc/nginx"
SITES_AVAILABLE="$NGINX_DIR/sites-available"
SITES_ENABLED="$NGINX_DIR/sites-enabled"
SITE_CONFIG="docker-app-proxy"

# Для контейнера не проверяем root права, но проверяем доступ к nginx директориям
if [ ! -w "$NGINX_DIR" ]; then
    echo "Ошибка: Нет доступа для записи в $NGINX_DIR"
    echo "Убедитесь, что контейнер имеет privileged доступ и монтирование volumes"
    exit 1
fi

# Проверяем, что nginx установлен на хосте
if ! command -v nginx &> /dev/null; then
    echo "Ошибка: nginx не установлен на хост-машине"
    echo "Установите: sudo apt update && sudo apt install nginx"
    exit 1
fi

# Создаем необходимые директории
mkdir -p "$SITES_AVAILABLE" "$SITES_ENABLED" "/var/log/nginx"

# Создание конфигурации nginx
echo "Создание конфигурации для доменов:"
echo "  - $DOMAIN1 -> localhost:$DOCKER_PORT1"
echo "  - $DOMAIN2 -> localhost:$DOCKER_PORT2"

cat > "/tmp/$SITE_CONFIG" << EOF
# Reverse Proxy конфигурация для Docker приложений
# Файл создан автоматически скриптом setup-nginx-proxy.sh

# # Сервер для $DOMAIN1
# server {
#     listen 80;
#     server_name $DOMAIN1 www.$DOMAIN1;

#     # Базовые настройки
#     client_max_body_size 100M;
#     proxy_connect_timeout 600;
#     proxy_send_timeout 600;
#     proxy_read_timeout 600;
#     send_timeout 600;

#     location / {
#         proxy_pass http://localhost:$DOCKER_PORT1;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#         proxy_set_header X-Forwarded-Host \$host;
        
#         # Дополнительные настройки прокси
#         proxy_redirect off;
#         proxy_buffering off;
#     }

#     # Логи
#     access_log /var/log/nginx/${DOMAIN1}_access.log;
#     error_log /var/log/nginx/${DOMAIN1}_error.log;
# }

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
        proxy_pass http://localhost:$DOCKER_PORT2;
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

# Перезапускаем nginx хоста
echo "Перезапуск системного nginx..."
if command -v systemctl &> /dev/null; then
    systemctl restart nginx
else
    service nginx restart
fi

echo "Настройка завершена! Файлы созданы на хост-машине:"
echo "  Конфиг: $SITES_AVAILABLE/$SITE_CONFIG"
echo "  Ссылка: $SITES_ENABLED/$SITE_CONFIG"