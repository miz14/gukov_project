#!/bin/bash

set -e

echo "Starting SSL certificate setup..."

# Проверяем наличие необходимых переменных
if [ -z "$SITE1_DOMAIN" ] || [ -z "$SITE2_DOMAIN" ]; then
    echo "Error: SITE1_DOMAIN and SITE2_DOMAIN environment variables are required"
    exit 1
fi

# Ждем немного, чтобы nginx успел запуститься и настроиться
echo "Waiting for nginx to be ready..."
sleep 10

# Функция для получения сертификата
setup_certificate() {
    local domains="$1"
    echo "Setting up SSL certificate for: $domains"
    
    # Проверяем, есть ли уже сертификат
    if certbot certificates | grep -q "$domains"; then
        echo "Certificate for $domains already exists, skipping..."
        return 0
    fi
    
    # Получаем сертификат (неинтерактивный режим)
    if certbot --nginx --non-interactive --agree-tos --email admin@${SITE1_DOMAIN} -d $domains; then
        echo "Successfully obtained certificate for: $domains"
    else
        echo "Failed to obtain certificate for: $domains"
        return 1
    fi
}

# Настраиваем сертификаты для каждого домена
setup_certificate "$SITE1_DOMAIN,www.$SITE1_DOMAIN"
setup_certificate "$SITE2_DOMAIN,www.$SITE2_DOMAIN"

# Настраиваем автоматическое обновление сертификатов
echo "Setting up certificate auto-renewal..."

# Создаем cron job для автоматического обновления
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

# Запускаем cron
crond

echo "SSL certificate setup completed successfully!"
echo "Certificates will be automatically renewed daily."

# Проверяем конфигурацию nginx
nginx -t

# Перезагружаем nginx для применения изменений
nginx -s reload

echo "Nginx configuration reloaded with SSL certificates"