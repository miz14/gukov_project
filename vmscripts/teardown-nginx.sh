#!/bin/bash

# Удаляем конфиг nginx
sudo rm -f /etc/nginx/sites-available/your-project
sudo rm -f /etc/nginx/sites-enabled/your-project

# Перезагружаем nginx
sudo systemctl reload nginx

echo "Nginx configuration removed successfully!"