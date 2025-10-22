#!/bin/bash

# Скрипт настройки nginx reverse proxy для Docker контейнеров
set -e

echo "=== Настройка nginx reverse proxy ==="

# Переменные из окружения Docker
DOMAIN1="${SITE1_DOMAIN:-site1.example.com}"
DOMAIN2="${SITE2_DOMAIN:-site2.example.com}"
NGINX_DIR="/etc/nginx"
SITES_AVAILABLE="$NGINX_DIR/sites-available"
SITES_ENABLED="$NGINX_DIR/sites-enabled"
SITE_CONFIG="docker-app-proxy"

echo "Домены: $DOMAIN1, $DOMAIN2"

# Проверяем доступ к nginx директориям хоста
if [ ! -w "$NGINX_DIR" ]; then
    echo "Ошибка: Нет доступа для записи в $NGINX_DIR"
    echo "Убедитесь, что контейнер имеет privileged доступ"
    exit 1
fi

# Создаем необходимые директории на хосте
mkdir -p "$SITES_AVAILABLE" "$SITES_ENABLED"

# Создание конфигурации nginx
echo "Создание конфигурации для доменов:"
echo "  - $DOMAIN1 -> контейнер site1:80"
echo "  - $DOMAIN2 -> контейнер site2:80"
echo "  - API пути -> контейнер forms-data-handler:3000"

cat > "/tmp/$SITE_CONFIG" << EOF
# Reverse Proxy конфигурация для Docker приложений
# Файл создан автоматически скриптом setup-nginx-proxy.sh

# Upstreams для контейнеров
upstream site1 {
    server site1:80;
}

upstream site2 {
    server site2:80;
}

upstream forms-data-handler {
    server forms-data-handler:3000;
}

# Сервер для $DOMAIN1
server {
    listen 80;
    server_name $DOMAIN1 www.$DOMAIN1;

    location / {
        proxy_pass http://site1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Дополнительные настройки
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /api/ {
        proxy_pass http://forms-data-handler/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

# Сервер для $DOMAIN2
server {
    listen 80;
    server_name $DOMAIN2 www.$DOMAIN2;

    location / {
        proxy_pass http://site2;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /api/ {
        proxy_pass http://forms-data-handler/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}

# Блокировка всех других доменов
server {
    listen 80 default_server;
    server_name _;
    return 444;
}
EOF

# Копируем конфигурацию в nginx хоста
echo "Копирование конфигурации в nginx..."
cp "/tmp/$SITE_CONFIG" "$SITES_AVAILABLE/$SITE_CONFIG"

# Создаем симлинк в sites-enabled если его нет
if [ ! -L "$SITES_ENABLED/$SITE_CONFIG" ]; then
    ln -sf "$SITES_AVAILABLE/$SITE_CONFIG" "$SITES_ENABLED/$SITE_CONFIG"
    echo "Создан симлинк в sites-enabled"
fi

# Отключаем дефолтный сайт nginx если он есть
if [ -L "$SITES_ENABLED/default" ]; then
    rm "$SITES_ENABLED/default"
    echo "Отключен дефолтный сайт nginx"
fi


echo ""
echo "=== Настройка завершена успешно! ==="
echo "Файлы созданы на хост-машине:"
echo "  Конфиг: $SITES_AVAILABLE/$SITE_CONFIG"
echo "  Ссылка: $SITES_ENABLED/$SITE_CONFIG"
echo ""
echo "Домены настроены:"
echo "  http://$DOMAIN1 -> контейнер site1"
echo "  http://$DOMAIN2 -> контейнер site2"
echo "  API пути (/api/) -> контейнер forms-data-handler:3000"