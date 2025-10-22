FROM nginx

# Создаем директорию для скриптов
RUN mkdir /scripts

# Копируем скрипт в образ
COPY scripts/setup-nginx-proxy.sh /scripts

# Даем права на выполнение
RUN chmod +x /scripts/setup-nginx-proxy.sh
