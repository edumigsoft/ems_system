# Changelog

Este arquivo documenta as mudanças no **User Feature** e seus subpacotes.

Para detalhes completos sobre cada subpacote, consulte os CHANGELOGs individuais.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [1.0.0] - 2026-01-19

### Added
- Sistema completo de gestão de usuários
- CRUD de usuários (Create, Read, Update, Delete)
- Endpoints de perfil do usuário (`/users/me`)
- Endpoints administrativos para gestão de usuários
- Suporte a papéis hierárquicos (UserRole: owner, admin, manager, user)
- Atualização administrativa de usuários (AdminUpdate)
- Validação de email e username únicos
- Soft delete de usuários
- Integração com Auth para autenticação e autorização
- Subpacotes: user_shared, user_server, user_client, user_ui
- Componentes UI:
  - UserProfilePage - Página de perfil
  - UserEditPage - Edição de perfil
  - UserListPage - Listagem administrativa
  - UserCard - Card de exibição
  - UserAvatar - Avatar com fallback
- ViewModels para arquitetura MVVM
- Documentação completa com exemplos

### Features
- Perfil de usuário com nome, email, username, bio, avatarUrl
- Verificação de email (emailVerified)
- Controle de ativação (isActive)
- Atualização de papel por administradores
- Listagem e busca de usuários (admin)
