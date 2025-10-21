#!/bin/bash

# Загружаем переменные из .env
set -a
source ../.env
set +a

# Создаем конфиг для nginx
NGINX_CONF="/etc/nginx/sites-available/your-project"

sudo tee $NGINX_CONF > /dev/null <<EOF
# Автоматически сгенерировано скриптом setup-nginx.sh
# Не редактировать вручную!

server {
    listen 80;
    server_name ${SITE1_DOMAIN} www.${SITE1_DOMAIN};
    
    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /api/ {
        proxy_pass http://127.0.0.1:8001/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

server {
    listen 80;
    server_name ${SITE2_DOMAIN} www.${SITE2_DOMAIN};
    
    location / {
        proxy_pass http://127.0.0.1:8002;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /api/ {
        proxy_pass http://127.0.0.1:8002/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Активируем конфиг
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/

# Проверяем конфигурацию
sudo nginx -t

# Перезагружаем nginx
sudo systemctl reload nginx

echo "Nginx configuration applied successfully!"
echo "Domains configured:"
echo "  - ${SITE1_DOMAIN} -> port 8001"
echo "  - ${SITE2_DOMAIN} -> port 8002"