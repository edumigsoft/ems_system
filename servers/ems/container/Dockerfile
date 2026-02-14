# Estágio de Build
FROM dart:stable AS build

WORKDIR /app

# --- 1. CÓPIA DE PACOTES COMPARTILHADOS ---
# É crucial copiar tanto os pacotes _server quanto os _shared
# Se você criar novos módulos no futuro, adicione-os aqui.

# Core & Open API
COPY packages/core/core_shared /app/packages/core/core_shared
COPY packages/core/core_server /app/packages/core/core_server
COPY packages/open_api/open_api_shared /app/packages/open_api/open_api_shared
COPY packages/open_api/open_api_server /app/packages/open_api/open_api_server

# Auth
COPY packages/auth/auth_shared /app/packages/auth/auth_shared
COPY packages/auth/auth_server /app/packages/auth/auth_server

# User
COPY packages/user/user_shared /app/packages/user/user_shared
COPY packages/user/user_server /app/packages/user/user_server

# Tag
COPY packages/tag/tag_shared /app/packages/tag/tag_shared
COPY packages/tag/tag_server /app/packages/tag/tag_server

# Notebook
COPY packages/notebook/notebook_shared /app/packages/notebook/notebook_shared
COPY packages/notebook/notebook_server /app/packages/notebook/notebook_server

# --- 2. OTIMIZAÇÃO: Cachear camada de dependências ---
WORKDIR /app/servers/ems/server_v1

# Copiar apenas pubspec para instalar dependências primeiro
COPY servers/ems/server_v1/pubspec.yaml .

# Remover workspace e instalar deps (essa camada será cacheada)
RUN sed -i '/resolution: workspace/d' pubspec.yaml
RUN dart pub get

# --- 3. COPIAR CÓDIGO FONTE ---
COPY servers/ems/server_v1 /app/servers/ems/server_v1

# --- 4. COMPILAÇÃO ---
RUN dart compile exe bin/server.dart -o bin/server

# Estágio de Produção (Imagem Mínima)
FROM scratch

# Metadados OCI
LABEL org.opencontainers.image.source="https://github.com/edumigsoft/ems_system"
LABEL org.opencontainers.image.description="EMS Server - Backend Dart/Shelf"
LABEL org.opencontainers.image.licenses="MIT"

# Copia bibliotecas do sistema necessárias
COPY --from=build /runtime/ /

# Copia o executável compilado
COPY --from=build /app/servers/ems/server_v1/bin/server /app/bin/server

# Variáveis padrão (serão sobrescritas pelo docker-compose/.env)
ENV PORT=8181
ENV INTERFACE=0.0.0.0

EXPOSE 8080

CMD ["/app/bin/server"]