# Changelog

Este arquivo documenta as mudanças no **Auth Feature** e seus subpacotes.

Para detalhes completos sobre cada subpacote, consulte os CHANGELOGs individuais.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [1.0.0] - 2026-01-19

### Added
- Sistema completo de autenticação JWT
- Login com email/senha
- Registro de novos usuários
- Refresh Token com rotação automática
- Recuperação de senha (Forgot/Reset Password)
- Alteração de senha para usuários autenticados
- RBAC (Role-Based Access Control) em dois níveis:
  - Papéis globais (UserRole: owner, admin, manager, user)
  - Papéis por feature (FeatureUserRole: owner, admin, manager, member, viewer)
- AuthMiddleware para proteção de rotas
- FeatureRoleMiddleware para verificação granular de permissões
- Implementação de referência com ProjectUserRole
- Subpacotes: auth_shared, auth_server, auth_client, auth_ui
- Documentação completa com exemplos de uso

### Security
- Hashing de senhas com bcrypt
- JWT tokens (access + refresh)
- Refresh token rotation para maior segurança
- Soft delete de usuários e sessões
