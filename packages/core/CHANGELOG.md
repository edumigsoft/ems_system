# Changelog

Este arquivo documenta as mudanças no **EMS System Core** workspace e seus subpacotes.

Para detalhes completos sobre cada subpacote, consulte os CHANGELOGs individuais linkados abaixo.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## 2026-01-18

### 🎉 Lançamento Inicial - Todos os Subpacotes v1.0.0

#### Subpacotes Liberados

- **[core_shared v1.0.0](core_shared/CHANGELOG.md)**  
  Pacote fundamental com utilitários compartilhados, padrão Result, bases para injeção de dependências, validadores e logging estruturado.

- **[core_client v1.0.0](core_client/CHANGELOG.md)**  
  Infraestrutura HTTP/Dio para comunicação com APIs, incluindo mixins e repositórios base para o lado cliente.

- **[core_server v1.0.0](core_server/CHANGELOG.md)**  
  Infraestrutura completa para servidor com Shelf, JWT, bcrypt, Drift e PostgreSQL, incluindo serviços de segurança e middlewares.

- **[core_ui v1.0.0](core_ui/CHANGELOG.md)**  
  Componentes Flutter para UI, incluindo layouts responsivos, arquitetura MVVM, validação de formulários e sistema de navegação modular.

#### Estrutura do Workspace

- ✅ Sistema de versionamento automatizado via `bump_version.sh`
- ✅ Documentação completa: `README.md`, `CONTRIBUTING.md`, `LICENSE.md`
- ✅ Badges e metadados do repositório em todos os subpacotes
- ✅ Sincronização automática de versões entre workspace e subpacotes
