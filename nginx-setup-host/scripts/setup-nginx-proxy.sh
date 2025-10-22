#!/bin/bash

# Скрипт настройки nginx reverse proxy для Docker контейнеров
set -e

echo "=== Настройка nginx reverse proxy ==="

# Переменные из окружения Docker
DOMAIN1="${SITE1_DOMAIN:-site1.example.com}"
DOMAIN2="${SITE2_DOMAIN:-site2.example.com}"
DOCKER_PORT1="${PORT1:-8001}"
DOCKER_PORT2="${PORT2:-8002}"
NGINX_DIR="/etc/nginx"
SITES_AVAILABLE="$NGINX_DIR/sites-available"
SITES_ENABLED="$NGINX_DIR/sites-enabled"
SITE_CONFIG="docker-app-proxy"

echo "Домены: $DOMAIN1, $DOMAIN2"
echo "Порты: $DOCKER_PORT1, $DOCKER_PORT2"

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
echo "  - $DOMAIN1 -> localhost:$DOCKER_PORT1"
echo "  - $DOMAIN2 -> localhost:$DOCKER_PORT2"

cat > "/tmp/$SITE_CONFIG" << EOF
# Reverse Proxy конфигурация для Docker приложений
# Файл создан автоматически скриптом setup-nginx-proxy.sh

# Сервер для $DOMAIN1
server {
    listen 80;
    server_name $DOMAIN1 www.$DOMAIN1;

    location / {
        proxy_pass http://localhost:$DOCKER_PORT1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# Сервер для $DOMAIN2
server {
    listen 80;
    server_name $DOMAIN2 www.$DOMAIN2;

    location / {
        proxy_pass http://localhost:$DOCKER_PORT2;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
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
echo "  http://$DOMAIN1 -> Docker контейнер на порту $DOCKER_PORT1"
echo "  http://$DOMAIN2 -> Docker контейнер на порту $DOCKER_PORT2"