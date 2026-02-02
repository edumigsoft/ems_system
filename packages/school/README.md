# School - Gestão de Instituições de Ensino

Feature principal responsável pela gestão de escolas, turnos, salas e infraestrutura educacional.

## 📋 Visão Geral

O módulo **School** gerencia as informações institucionais, incluindo dados das escolas, configuração de turnos, salas de aula e outros recursos físicos e organizacionais.

## 🏗️ Arquitetura

Esta feature segue a arquitetura **Great Schism** com sub-features organizadas da seguinte forma:

### Sub-Features

- **`school_core`**: Lógica de domínio, entidades de escola, use cases
- **`school_client`**: Cliente HTTP para comunicação com o servidor
- **`school_server`**: API REST, banco de dados e implementações
- **`school_ui`**: Interface de gerenciamento de escolas

## 📦 Funcionalidades

- Cadastro e gerenciamento de escolas
- Configuração de turnos (matutino, vespertino, noturno, integral)
- Gestão de salas de aula
- Controle de infraestrutura
- Distribuição de recursos
- Dados institucionais e contatos

## 🔗 Dependências

- `core_shared`: Utilitários e interfaces base
- `core_client`: Cliente HTTP base
- `core_server`: Infraestrutura de servidor e banco de dados

## 🚀 Como Usar

### Cliente

```dart
import 'package:school_client/school_client.dart';

final schoolRepository = SchoolRepositoryClient(baseUrl: 'http://localhost:8080');
```

### Servidor

```dart
import 'package:school_server/school_server.dart';

void main() async {
  await runSchoolServer(port: 8080);
}
```

## 📚 Documentação Adicional

Consulte os READMEs específicos de cada pacote para detalhes de implementação.
