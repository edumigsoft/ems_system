# Dockerfile
FROM postgres:latest

# Instala dependências necessárias para compilar o pg_cron
RUN apt-get update && apt-get install -y \
    build-essential \
    postgresql-server-dev-all \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clona e instala o pg_cron
RUN git clone https://github.com/citusdata/pg_cron.git /pg_cron \
    && cd /pg_cron \
    && make \
    && make install
