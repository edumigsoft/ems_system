# Estágio de Build
FROM dart:stable AS build

WORKDIR /app

# --- 1. CÓPIA DE PACOTES COMPARTILHADOS ---
# Copiamos os mesmos pacotes, pois o SMS provavelmente usa a mesma base (Core, Auth, etc)
COPY packages/core/core_shared /app/packages/core/core_shared
COPY packages/core/core_server /app/packages/core/core_server
COPY packages/open_api/open_api_shared /app/packages/open_api/open_api_shared
COPY packages/open_api/open_api_server /app/packages/open_api/open_api_server

COPY packages/auth/auth_shared /app/packages/auth/auth_shared
COPY packages/auth/auth_server /app/packages/auth/auth_server

COPY packages/user/user_shared /app/packages/user/user_shared
COPY packages/user/user_server /app/packages/user/user_server

# School
COPY packages/school/school_shared /app/packages/school/school_shared
COPY packages/school/school_server /app/packages/school/school_server

# --- 2. OTIMIZAÇÃO: Cachear camada de dependências ---
WORKDIR /app/servers/sms/server_v1

# Copiar apenas pubspec para instalar dependências primeiro
COPY servers/sms/server_v1/pubspec.yaml .

# Remover workspace e instalar deps (essa camada será cacheada)
RUN sed -i '/resolution: workspace/d' pubspec.yaml
RUN dart pub get

# --- 3. COPIAR CÓDIGO FONTE ---
COPY servers/sms/server_v1 /app/servers/sms/server_v1

# --- 4. COMPILAÇÃO ---
RUN dart compile exe bin/server.dart -o bin/server

# Estágio de Produção
FROM scratch

# Build ARG e ENV para versão
ARG VERSION=unknown
ENV APP_VERSION=$VERSION

# Metadados OCI
LABEL org.opencontainers.image.source="https://github.com/edumigsoft/ems_system"
LABEL org.opencontainers.image.description="SMS Server - Backend Dart/Shelf"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version="$VERSION"

COPY --from=build /runtime/ /

# Copiar executável compilado
COPY --from=build /app/servers/sms/server_v1/bin/server /app/bin/server

ENV PORT=8080
ENV INTERFACE=0.0.0.0

EXPOSE 8080

CMD ["/app/bin/server"]