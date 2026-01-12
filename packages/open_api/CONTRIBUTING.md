# Guia de Contribuição - Open API

Obrigado por contribuir para o módulo **Open API** do EMS System!

Este documento complementa o [Guia de Contribuição Principal](../../CONTRIBUTING.md) com diretrizes específicas para este pacote.

## Estrutura do Pacote

Este módulo segue a estrutura de feature definida na ADR-0005:

- **`open_api_shared`**: Contém entidades, casos de uso e contratos de repositório (Core).
- **`open_api_server`**: Implementações de servidor e endpoints.
- **`open_api_client`**: Implementações de cliente HTTP (se existir).
- **`open_api_ui`**: Componentes visuais e páginas Flutter.

## Padrões Específicos

### Geração de Código

O pacote Open API faz uso extensivo de geração de código. Ao modificar arquivos `.yaml` de especificação ou modelos:

1. Execute o script de geração (se houver): `./scripts/generate_openapi.sh` (exemplo)
2. Ou use o build_runner: `dart run build_runner build --delete-conflicting-outputs`

### Versionamento

Ao fazer alterações que afetam a API pública, lembre-se de atualizar o `CHANGELOG.md` neste diretório e nos sub-pacotes afetados.

## Como Testar

Execute os testes de todos os sub-módulos:

```bash
# Na raiz do projeto
./scripts/run_tests.sh packages/open_api
```

Ou individualmente em cada sub-pacote:

```bash
cd open_api_shared
dart test
```

## Dúvidas

Consulte o README principal da feature ou abra uma issue no repositório.
