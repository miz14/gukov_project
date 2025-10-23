FROM nginx:latest

# Устанавливаем зависимости
RUN apk add --no-cache bash nginx certbot certbot-nginx

RUN apt-get update && apt-get install -y \
    certbot \
    python3-certbot-nginx \
    cron \
    curl \
    && rm -rf /var/lib/apt/lists/*
    
# Создаем директорию для скриптов
RUN mkdir -p /scripts

# Копируем скрипт в образ
COPY scripts/setup-nginx-proxy.sh /scripts/
COPY scripts/setup-nginx-ssl.sh /scripts/

# Даем права на выполнение
RUN chmod +x /scripts/setup-nginx-proxy.sh /scripts/setup-nginx-ssl.sh

# Настраиваем sudo для работы без пароля (опционально)
RUN echo 'nginx ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Запускаем скрипт (используем shell форму для правильного выполнения)
CMD ["/bin/bash", "-c", "/scripts/setup-nginx-proxy.sh"]