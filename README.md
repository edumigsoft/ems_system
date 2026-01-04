# EMS System (EduMigSoft System)

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/edumigsoft/ems_system/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Sistema de Gestão de features para o EduMigSoft.

## 📊 Status do Projeto

| Módulo | Status | Versão | Descrição |
|--------|--------|--------|-----------|
| Core Shared | 🟡 Em desenvolvimento | 0.1.0 | Funcionalidades compartilhadas |
| Core Server | 🟡 Em desenvolvimento | 0.1.0 | Núcleo do servidor |
| Core Client | 🟡 Em desenvolvimento | 0.1.0 | Núcleo do cliente |
| UI Components | 🟡 Em desenvolvimento | 0.1.0 | Componentes de interface |
| Design System | 🟡 Em desenvolvimento | 0.1.0 | Sistema de design |
| App Flutter | 🔴 Planejado | 0.0.0 | Aplicativo mobile |
| Server Dart/Shelf | 🔴 Planejado | 0.0.0 | Backend API |

**Legenda:** 🟢 Ativo | 🟡 Em desenvolvimento | 🔴 Planejado

## ✨ Features

Features da ideia inicial:
- App em Flutter
- Server em Dart/Shelf
- Gestão de Users
- Gestão de Aura (Tarefas)
- Gestão de Projects (com tarefas e financeiro do projeto, não utilizará a features de financeiro)
- Gestão de Finance (com receita e despesas)

## Estrutura do Projeto

```bash
ems_system/
├── apps/
│   └── app/
│       ├── config/
│       │    ├── di/ #dependence injection
│       │    ├── dio/ # config Dio
│       │    └── env/ # config environment  
│       │
│       ├── data/
│       │    ├── local/
│       │    └── services/
│       │
│       └── ui/
│           ├── pages/
│           ├── view_models/
│           └── app_layout.dart
│
├── servers/
│   └── server/
│       ├── bin/
│       └── lib/
│           ├── config/
│           │    ├── di/
│           │    └── env/
│           └── middlewares/
│
├── packages/
│   ├── core/
│   │   ├── README.md
│   │   ├── CHANGELOG.md
│   │   ├── LICENSE.md
│   │   ├── CONTRIBUTING.md
│   │   ├── core_shared/
│   │   │   ├── README.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── lib/
│   │   │   │   └── src/
│   │   │   └── test/
│   │   ├── core_server/
│   │   │   ├── README.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── lib/
│   │   │   │   └── src/
│   │   │   └── test/
│   │   ├── core_client/
│   │   │   ├── README.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── lib/
│   │   │   │   └── src/
│   │   │   └── test/
│   │   └── ui/
│   │       ├── README.md
│   │       ├── CHANGELOG.md
│   │       ├── lib/
│   │       │   └── ui/
│   │       └── test/
│   │
│   ├── design_system/ # estrutura semelhante ao core
│   ├── images/ # estrutura semelhante ao core
│   ├── localizations/ # estrutura semelhante ao core
│   ├── open_api/ # estrutura semelhante ao core
│   └── {features}/ # estrutura semelhante ao core
│
├── scripts/
├── docs/
├── containers/
├── README.md
├── CHANGELOG.md
├── LICENSE.md
└── CONTRIBUTING.md
```