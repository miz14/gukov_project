#!/bin/bash

# Скрипт настройки SSL сертификатов для nginx
set -e

echo "=== Настройка SSL сертификатов ==="

# Переменные из окружения Docker
DOMAIN1="${1:-site1.example.com}"
DOMAIN2="${2:-site2.example.com}"
EMAIL="${3:-admin@example.com}"

echo "Домены: $DOMAIN1, $DOMAIN2"
echo "Email для сертификатов: $EMAIL"

# Проверяем наличие необходимых переменных
if [ -z "$EMAIL" ] || [ "$EMAIL" = "admin@example.com" ]; then
    echo "Ошибка: Не указан email для сертификатов"
    echo "Установите переменную CERTBOT_EMAIL"
    exit 1
fi

# Получаем SSL сертификаты
echo "Получение SSL сертификатов для доменов..."
certbot --nginx --non-interactive --agree-tos --email "$EMAIL" \
    -d "$DOMAIN1" \
    -d "www.$DOMAIN1" \
    -d "$DOMAIN2" \
    -d "www.$DOMAIN2" \
    --redirect  # Автоматически добавляет редирект с HTTP на HTTPS

# Настраиваем автоматическое обновление сертификатов
echo "Настройка автоматического обновления сертификатов..."

# Создаем cron задание для обновления сертификатов
echo "0 12 * * * /usr/bin/certbot renew --quiet" > /etc/cron.d/certbot-renewal
chmod 644 /etc/cron.d/certbot-renewal

# Запускаем cron службу
service cron start

# Проверяем конфигурацию nginx
echo "Проверка конфигурации nginx..."
nginx -t

echo ""
echo "=== Настройка SSL завершена успешно! ==="
echo "SSL сертификаты получены для:"
echo "  - $DOMAIN1"
echo "  - www.$DOMAIN1"
echo "  - $DOMAIN2"
echo "  - www.$DOMAIN2"
echo ""
echo "Автоматическое обновление настроено через cron"
echo "Проверить статус сертификатов: certbot certificates"