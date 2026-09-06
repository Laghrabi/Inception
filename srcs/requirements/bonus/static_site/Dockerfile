FROM debian:bookworm

RUN apt-get update && apt-get install -y python3 \
    && apt-get clean && rm -rf /val/lib/apt/lists/*

COPY html /var/www/html

WORKDIR /var/www/html

CMD ["python3", "-m", "http.server", "8000"]