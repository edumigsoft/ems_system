# Core Client

Cliente HTTP compartilhado para todos os pacotes client do sistema.

## 📋 Visão Geral

Este pacote fornece componentes relacionados à camada de cliente e comunicação externa, incluindo mixins para tratamento de erros HTTP e repositórios base.

## Estrutura do Pacote

A organização interna é focada em facilitar a implementação de clients e repositórios:

```
lib/src/
  ├── mixins/          # Mixins compartilhados (ex: DioErrorHandler)
  └── repositories/    # Classes, interfaces e implementações base para repositórios
```

## Responsabilidades

- **Mixins**: Fornecer tratamento de erros padronizado (ex: mapear erros `Dio` para falhas de domínio).
- **Repositories**: Oferecer estruturas base para implementação de repositórios que consomem dados externos.

## Instalação

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  core_client:
    path: packages/core/core_client
```
