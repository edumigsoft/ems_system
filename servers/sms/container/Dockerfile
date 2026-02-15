# Estágio de Build
FROM dart:stable AS build

WORKDIR /app

# --- 1. CRIAR WORKSPACE MÍNIMO PARA SMS ---
# Criar pubspec.yaml root customizado apenas com pacotes necessários para SMS
RUN echo 'name: sms_system_build' > /app/pubspec.yaml && \
    echo 'publish_to: none' >> /app/pubspec.yaml && \
    echo '' >> /app/pubspec.yaml && \
    echo 'environment:' >> /app/pubspec.yaml && \
    echo '  sdk: ^3.10.7' >> /app/pubspec.yaml && \
    echo '' >> /app/pubspec.yaml && \
    echo 'workspace:' >> /app/pubspec.yaml && \
    echo '  - servers/sms/server_v1' >> /app/pubspec.yaml && \
    echo '  - packages/core/core_server' >> /app/pubspec.yaml && \
    echo '  - packages/core/core_shared' >> /app/pubspec.yaml && \
    echo '  - packages/open_api/open_api_server' >> /app/pubspec.yaml && \
    echo '  - packages/open_api/open_api_shared' >> /app/pubspec.yaml && \
    echo '  - packages/auth/auth_server' >> /app/pubspec.yaml && \
    echo '  - packages/auth/auth_shared' >> /app/pubspec.yaml && \
    echo '  - packages/user/user_server' >> /app/pubspec.yaml && \
    echo '  - packages/user/user_shared' >> /app/pubspec.yaml && \
    echo '  - packages/school/school_server' >> /app/pubspec.yaml && \
    echo '  - packages/school/school_shared' >> /app/pubspec.yaml

# --- 2. CÓPIA DE PUBSPEC.YAML DOS PACOTES ---
# Copiar pubspec.yaml de cada pacote para estrutura de workspace

# Core
COPY packages/core/core_shared/pubspec.yaml /app/packages/core/core_shared/pubspec.yaml
COPY packages/core/core_server/pubspec.yaml /app/packages/core/core_server/pubspec.yaml

# Open API
COPY packages/open_api/open_api_shared/pubspec.yaml /app/packages/open_api/open_api_shared/pubspec.yaml
COPY packages/open_api/open_api_server/pubspec.yaml /app/packages/open_api/open_api_server/pubspec.yaml

# Auth
COPY packages/auth/auth_shared/pubspec.yaml /app/packages/auth/auth_shared/pubspec.yaml
COPY packages/auth/auth_server/pubspec.yaml /app/packages/auth/auth_server/pubspec.yaml

# User
COPY packages/user/user_shared/pubspec.yaml /app/packages/user/user_shared/pubspec.yaml
COPY packages/user/user_server/pubspec.yaml /app/packages/user/user_server/pubspec.yaml

# School
COPY packages/school/school_shared/pubspec.yaml /app/packages/school/school_shared/pubspec.yaml
COPY packages/school/school_server/pubspec.yaml /app/packages/school/school_server/pubspec.yaml

# Server pubspec
COPY servers/sms/server_v1/pubspec.yaml /app/servers/sms/server_v1/pubspec.yaml

# --- 3. INSTALAR DEPENDÊNCIAS (com workspace) ---
WORKDIR /app
RUN dart pub get

# --- 4. COPIAR CÓDIGO FONTE DOS PACOTES ---
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

# School
COPY packages/school/school_shared /app/packages/school/school_shared
COPY packages/school/school_server /app/packages/school/school_server

# --- 5. COPIAR CÓDIGO FONTE DO SERVIDOR ---
COPY servers/sms/server_v1 /app/servers/sms/server_v1

# --- 6. COPIAR ARQUIVOS .ENV ---
COPY servers/sms/server_v1/.env /app/servers/sms/server_v1/.env
COPY servers/sms/container/.env /app/servers/sms/container/.env

# --- 7. COMPILAÇÃO ---
WORKDIR /app/servers/sms/server_v1
RUN dart compile exe bin/server.dart -o bin/server

# Estágio de Produção
FROM scratch

# Metadados OCI
LABEL org.opencontainers.image.source="https://github.com/edumigsoft/ems_system"
LABEL org.opencontainers.image.description="SMS Server - Backend Dart/Shelf"
LABEL org.opencontainers.image.licenses="MIT"

COPY --from=build /runtime/ /

# Copiar executável compilado
COPY --from=build /app/servers/sms/server_v1/bin/server /app/bin/server

ENV PORT=8080
ENV INTERFACE=0.0.0.0

EXPOSE 8080

CMD ["/app/bin/server"]