# Core Server

O `core_server` é o pacote de infraestrutura backend para o EMS System, fornecendo implementações base para servidores Shelf, conexões com banco de dados (Drift/Postgres) e utilitários de segurança.

> **Nota**: Este pacote segue uma estrutura de **Platform/Infrastructure** e por isso não adere estritamente à divisão `domain/data` dos pacotes de feature core.

## Funcionalidades

- **Server Foundation**: Classes base para setup de servidores Shelf (`src/servers`).
- **Database**: Configuração do Drift e mixins para tabelas Postgres (`src/database`).
- **Security**: Implementação de JWT, Bcrypt e middlewares de autorização (`src/security`).
- **Routes Helpers**: Utilitários para definição de rotas e Health Checks (`src/routes`).

## Estrutura

```
lib/src/
  commons/       # Utilitários comuns e inicialização
  database/      # Configuração Drift e Mixins de Tabela
  middleware/    # Middlewares Shelf (Auth, CORS, RateLimit)
  routes/        # Rotas base e health checks
  security/      # Serviços de Criptografia e Tokens (JWT)
  servers/       # Base para servidor Shelf
  utils/         # Helpers HTTP
```

## Dependências Principais

- **shelf / shelf_router**: Framework HTTP.
- **drift / postgres**: ORM e Driver de Banco de Dados.
- **dart_jsonwebtoken**: Manipulação de JWT.
- **bcrypt**: Hashing de senhas.

## Como Usar

### Criando uma Tabela Drift

Use o `DriftTableMixinPostgres` para ganhar automaticamente campos de auditoria e UUID:

```dart
class MyTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'my_table';
  
  TextColumn get name => text()();
}
```

### Configurando Segurança

Utilize `SecurityService` para gestão de tokens:

```dart
final security = JWTSecurityService(jwtKey: 'secret');
final tokenResult = await security.generateToken(claims, 'audience');
```
