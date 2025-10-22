FROM alpine

# Устанавливаем зависимости
RUN apk add --no-cache bash nginx

# Создаем директорию для скриптов
RUN mkdir -p /scripts

# Копируем скрипт в образ
COPY scripts/setup-nginx-proxy.sh /scripts/

# # Даем права на выполнение
# RUN chmod +x /scripts/setup-nginx-proxy.sh