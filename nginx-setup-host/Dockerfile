FROM alpine

# Создаем директорию для скриптов
RUN mkdir -p /scripts

# Копируем скрипт в образ
COPY setup-nginx-proxy.sh /scripts/setup-nginx-proxy.sh

# # Даем права на выполнение
# RUN chmod +x /scripts/setup-nginx-proxy.sh

# # Устанавливаем bash для лучшей совместимости скриптов
# RUN apk add --no-cache bash nginx