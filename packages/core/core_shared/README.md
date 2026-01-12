# Core Shared

Este pacote contém componentes base, utilitários e lógicas compartilhadas essenciais para o funcionamento do sistema. Ele serve como um "kernel" reutilizável.

## Estrutura do Pacote

A estrutura interna reflete as funcionalidades utilitárias e transversais fornecidas:

```
lib/src/
  ├── commons/              # Classes e constantes comuns
  ├── converters/           # Conversores de dados (ex: JSON, Data)
  ├── dependency_injector/  # Configuração e interfaces para injeção de dependência
  ├── exceptions/           # Exceções base do sistema
  ├── messages/             # Centralização de mensagens (i18n ou constantes)
  ├── result/               # Implementação do padrão Result para tratamento de erros
  ├── service/              # Interfaces e classes base para serviços
  ├── utils/                # Funções utilitárias gerais
  └── validators/           # Lógicas e mixins de validação
```

## Dependências

Verifique o `pubspec.yaml` para a lista completa, mas as principais incluem `zard` para validação e pacotes de utilidade geral.

## Instalação

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  core_shared:
    path: packages/core/core_shared
```
