#!/bin/bash
set -e

echo "Starting SSL certificate setup..."

# Проверяем наличие необходимых переменных
if [ -z "$SITE1_DOMAIN" ] || [ -z "$SITE2_DOMAIN" ]; then
    echo "Error: SITE1_DOMAIN and SITE2_DOMAIN environment variables are required"
    exit 1
fi

# Ждем запуска nginx
echo "Waiting for nginx to be ready..."
sleep 10

# Функция для получения сертификата
setup_certificate() {
    local domain="$1"
    local www_domain="www.$domain"
    echo "Setting up SSL certificate for: $domain, $www_domain"
    
    # Проверяем, есть ли уже сертификат
    if certbot certificates | grep -q "$domain"; then
        echo "Certificate for $domain already exists, skipping..."
        return 0
    fi
    
    # Получаем сертификат используя nginx plugin
    if certbot --nginx --non-interactive --agree-tos \
        --email "admin@$domain" \
        -d "$domain" -d "$www_domain" \
        --redirect; then
        echo "Successfully obtained certificate for: $domain, $www_domain"
    else
        echo "Failed to obtain certificate for: $domain, $www_domain"
        echo "Trying standalone mode as fallback..."
        
        # Останавливаем nginx временно для standalone режима
        nginx -s stop
        sleep 2
        
        if certbot certonly --standalone --non-interactive --agree-tos \
            --email "admin@$domain" \
            -d "$domain" -d "$www_domain"; then
            echo "Successfully obtained certificate in standalone mode"
            # Запускаем nginx обратно
            nginx
            sleep 2
        else
            echo "Failed to obtain certificate in standalone mode"
            nginx
            return 1
        fi
    fi
}

# Настраиваем сертификаты для каждого домена
setup_certificate "$SITE1_DOMAIN"
setup_certificate "$SITE2_DOMAIN"

# Настраиваем автоматическое обновление сертификатов
echo "Setting up certificate auto-renewal..."
echo "0 12 * * * /usr/bin/certbot renew --quiet && nginx -s reload" | crontab -
service cron start

echo "SSL certificate setup completed successfully!"

# Проверяем конфигурацию nginx
nginx -t

echo "Nginx configuration with SSL is ready!"