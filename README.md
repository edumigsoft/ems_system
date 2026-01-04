# EMS System (EduMig System)

Sistema de Gestão de features para o EduMig.

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