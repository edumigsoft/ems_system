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

# --- 2. CÓPIA DO CÓDIGO FONTE DO SERVIDOR (EMS) ---
COPY servers/ems/server_v1 /app/servers/ems/server_v1

# --- 3. PREPARAÇÃO E DEPENDÊNCIAS ---
WORKDIR /app/servers/ems/server_v1

# Removemos a referência ao workspace para o build ser independente
RUN sed -i '/resolution: workspace/d' pubspec.yaml

# Baixa as dependências
RUN dart pub get

# --- 4. COMPILAÇÃO ---
RUN dart compile exe bin/server.dart -o bin/server

# Estágio de Produção (Imagem Mínima)
FROM scratch

# Copia bibliotecas do sistema necessárias
COPY --from=build /runtime/ /

# Copia o executável compilado
COPY --from=build /app/servers/ems/server_v1/bin/server /app/bin/server

# Variáveis padrão (serão sobrescritas pelo docker-compose/.env)
ENV PORT=8181
ENV INTERFACE=0.0.0.0

EXPOSE 8080

CMD ["/app/bin/server"]