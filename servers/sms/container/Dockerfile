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

# Se o SMS tiver pacotes exclusivos (ex: packages/sms/sms_shared), adicione aqui:
# COPY packages/sms/sms_shared /app/packages/sms/sms_shared

# --- 2. CÓPIA DO CÓDIGO FONTE DO SERVIDOR (SMS) ---
# ATENÇÃO: Verifique se o caminho da pasta bate com sua estrutura real
COPY servers/sms_server/server_v1 /app/servers/sms_server/server_v1

# --- 3. PREPARAÇÃO E DEPENDÊNCIAS ---
WORKDIR /app/servers/sms_server/server_v1

# Remove referência ao workspace
RUN sed -i '/resolution: workspace/d' pubspec.yaml

RUN dart pub get

# --- 4. COMPILAÇÃO ---
RUN dart compile exe bin/server.dart -o bin/server

# Estágio de Produção
FROM scratch

COPY --from=build /runtime/ /

# ATENÇÃO: Caminho de origem ajustado para o SMS
COPY --from=build /app/servers/sms_server/server_v1/bin/server /app/bin/server

ENV PORT=8080
ENV INTERFACE=0.0.0.0

EXPOSE 8080

CMD ["/app/bin/server"]