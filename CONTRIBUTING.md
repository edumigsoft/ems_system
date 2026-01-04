# Guia de Contribuição

Obrigado por considerar contribuir para o EMS System! Este documento fornece diretrizes para contribuir com o projeto.

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Padrões de Desenvolvimento](#padrões-de-desenvolvimento)
- [Processo de Submissão](#processo-de-submissão)

## 🤝 Código de Conduta

Este projeto adota um código de conduta que esperamos que todos os participantes sigam. Por favor, seja respeitoso e profissional em todas as interações.

## 🚀 Como Contribuir

### Reportar Bugs

Ao reportar bugs, inclua:
- Descrição clara do problema
- Passos para reproduzir
- Comportamento esperado vs. comportamento atual
- Screenshots (se aplicável)
- Versão do Flutter/Dart
- Sistema operacional

### Sugerir Melhorias

- Use a aba de Issues para sugestões
- Descreva claramente o problema que a sugestão resolve
- Inclua exemplos de uso, se possível

### Pull Requests

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/amazing-feature`)
3. Commit suas mudanças (`git commit -m 'Add amazing feature'`)
4. Push para a branch (`git push origin feature/amazing-feature`)
5. Abra um Pull Request

## 📁 Estrutura do Projeto

O EMS System é um monorepo organizado em:

- **`apps/`** - Aplicações (Flutter app, admin web)
- **`servers/`** - Servidores backend (Dart/Shelf)
- **`packages/`** - Pacotes compartilhados
  - `core/` - Funcionalidades core compartilhadas
  - `design_system/` - Sistema de design
  - `{features}/` - Features isoladas
- **`scripts/`** - Scripts de automação
- **`docs/`** - Documentação adicional
- **`containers/`** - Configurações Docker

## 🎯 Padrões de Desenvolvimento

### Código

- Siga as [Effective Dart Guidelines](https://dart.dev/guides/language/effective-dart)
- Use `dart format` antes de commitar
- Execute `dart analyze` e corrija warnings
- Mantenha cobertura de testes acima de 80%

### Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new authentication feature
fix: resolve login button crash
docs: update README with setup instructions
test: add unit tests for user service
refactor: simplify profile page logic
```

Tipos de commit:
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `test`: Testes
- `chore`: Tarefas de manutenção

### Testes

- Escreva testes unitários para toda nova funcionalidade
- Testes devem estar em `test/` espelhando a estrutura de `lib/`
- Use mocks quando apropriado
- Execute: `dart test` ou `flutter test`

### Documentação

- Documente todas as classes e métodos públicos
- Use comentários `///` para documentação de API
- Mantenha o README atualizado
- Adicione exemplos quando apropriado

## 📝 Processo de Submissão

### Checklist antes de submeter PR

- [ ] Código segue os padrões do projeto
- [ ] Executou `dart format` / `flutter format`
- [ ] Executou `dart analyze` / `flutter analyze` sem erros
- [ ] Todos os testes passam
- [ ] Adicionou testes para novas funcionalidades
- [ ] Atualizou documentação relevante
- [ ] Atualizou CHANGELOG.md

### Review de Código

- Pelo menos 1 aprovação necessária
- CI/CD deve passar
- Code coverage não deve diminuir

## 🔧 Configuração do Ambiente

### Requisitos

- Flutter SDK: `>=3.0.0`
- Dart SDK: `>=3.0.0`

### Setup

```bash
# Clone o repositório
git clone https://github.com/edumigsoft/ems_system.git
cd ems_system

# Instale dependências
flutter pub get

# Execute os testes
flutter test

# Execute o app
cd apps/app
flutter run
```

## 📞 Dúvidas?

Se tiver dúvidas sobre como contribuir, abra uma Issue com a tag `question`.

---

Agradecemos sua contribuição! 🎉
