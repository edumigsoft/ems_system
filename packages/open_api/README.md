# Open API Feature

Este pacote agrupa todas as funcionalidades relacionadas à implementação e integração da **Open API (Swagger)** no EMS System. Ele é responsável por definir, servir e consumir as especificações da API.

## Módulos

A feature é dividida nos seguintes submódulos:

| Pacote | Responsabilidade |
| :--- | :--- |
| [**open_api_shared**](./open_api_shared/README.md) | Contém a lógica central, geradores, definições de contratos e utilitários compartilhados entre cliente e servidor. |
| [**open_api_server**](./open_api_server/README.md) | Implementação do servidor para expor a documentação da API e rotas relacionadas. |
| [**open_api_ui**](./open_api_ui/README.md) | Interfaces visuais para visualização da documentação (Swagger UI ou similar) dentro da aplicação Flutter. |

## Estrutura

Esta feature segue a [Estrutura Padrão de Pacotes (ADR-0005)](../../docs/adr/0005-standard-package-structure.md).

```
packages/open_api/
├── open_api_shared/    # Lógica de Domínio e Compartilhada
├── open_api_server/    # Implementação Backend/Server
└── open_api_ui/        # Implementação Frontend/UI
```

## Como Usar

### Servidor

Para adicionar suporte OpenAPI ao seu servidor, consulte a documentação do módulo `open_api_server`.

### UI

Para exibir a documentação da API no app, consulte o módulo `open_api_ui`.

## Desenvolvimento

Consulte o [guia de contribuição](./CONTRIBUTING.md) para detalhes sobre como desenvolver e testar esta feature.
