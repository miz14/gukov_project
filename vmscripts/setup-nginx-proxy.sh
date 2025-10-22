#!/bin/bash

# Скрипт настройки nginx reverse proxy для Docker контейнеров
set -e

echo "=== Настройка nginx reverse proxy ==="

# Переменные
DOMAIN1="${DOMAIN1:-site1.example.com}"
DOMAIN2="${DOMAIN2:-site2.example.com}"
DOCKER_PORT1="${PORT1:-8003}"
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

# Установка nginx в Alpine контейнере
if ! command -v nginx &> /dev/null; then
    echo "Установка nginx в Alpine..."
    apk update
    apk add nginx
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
        proxy_pass http://localhost:$DOCKER_PORT1;
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

# Проверяем синтаксис nginx
echo "Проверка синтаксиса nginx..."
nginx -t

# Запускаем nginx в фоновом режиме
echo "Запуск nginx..."
nginx -g "daemon off;" &

echo ""
echo "=== Настройка завершена успешно! ==="
echo "Nginx запущен в контейнере и проксирует:"
echo "  http://$DOMAIN1 -> localhost:$DOCKER_PORT1"
echo "  http://$DOMAIN2 -> localhost:$DOCKER_PORT2"