## 🆕 Novo objetivo e estrutura

### Objetivo

O novo objetivo é desenvolver sistemas orientados por *features* (funcionalidades) modulares e escaláveis, com aplicativos cliente (app) e servidor (server) independentes, baseados inicialmente no conceito do sistema EMS. Os sistemas (`EMS`, `SMS`, etc.) compartilharão pacotes de código específicos (features, core, design, etc.), mas manterão sua própria configuração de ambiente (`.env`) e banco de dados, promovendo autonomia e flexibilidade.

Para otimizar a manutenção e evitar duplicação desnecessária, serão utilizados pacotes de código compartilhados (features, core, design, localizações, etc.). A localização seguirá a seguinte estratégia: existirá um pacote `localizations` para traduções comuns, e pacotes específicos (`localizations_ems`, `localizations_sms`, etc.) para traduções exclusivas de cada sistema. Inicialmente, o `design_system` será compartilhado, com planos futuros de diferenciação.

O sistema deve ser capaz de gerenciar eficientemente uma variedade de *features*, que podem ser comuns a múltiplos sistemas ou específicas para um sistema particular.

### Estrutura de Repositórios

A arquitetura será baseada em múltiplos repositórios Git independentes, organizados conforme abaixo:

```text
repositorio_pai/                    # Repo Git: Portal de entrada e documentação geral
├── README.md                       # Visão geral da organização e links para outros repositórios
├── scripts/
│   └── auditoria.sh                # Scripts gerais para utilidades como auditoria
├── repositorio_ems/                # Repo Git: Código e documentação específica do sistema EMS (EduMigSoft System)
│   ├── apps/
│   │   ├── v1/                     # Repo Git: Aplicativo cliente EMS versão 1 (nome sugerido: edumanager_app ou suiteedu_app)
│   │   └── v2/                     # Repo Git: Aplicativo cliente EMS versão 2 (nome sugerido: edumanager_app ou suiteedu_app)
│   ├── servers/
│   │   ├── v1/                     # Repo Git: Servidor EMS versão 1 (nome sugerido: edumanager_server ou suiteedu_server)
│   │   └── v2/                     # Repo Git: Servidor EMS versão 2 (nome sugerido: edumanager_server ou suiteedu_server)
│   └── docs/
├── repositorio_sms/                # Repo Git: Código e documentação específica do sistema SMS (School Management System)
│   ├── apps/
│   │   ├── v1/                     # Repo Git: Aplicativo cliente SMS versão 1 (nome sugerido: schoolpilot_app)
│   │   └── v2/                     # Repo Git: Aplicativo cliente SMS versão 2 (nome sugerido: schoolpilot_app)
│   ├── servers/
│   │   ├── v1/                     # Repo Git: Servidor SMS versão 1 (nome sugerido: schoolpilot_server)
│   │   └── v2/                     # Repo Git: Servidor SMS versão 2 (nome sugerido: schoolpilot_server)
│   └── docs/
├── repositorio_core/               # Repo Git: Pacotes fundamentais compartilhados (ex: autenticação, utils)
├── repositorio_user/               # Repo Git: Pacote de funcionalidades relacionadas a Usuários
├── repositorio_school/             # Repo Git: Pacote de funcionalidades relacionadas a Escolas (exclusivo SMS)
├── repositorio_students/           # Repo Git: Pacote de funcionalidades relacionadas a Alunos (exclusivo SMS)
└── ... (outros pacotes de features) # Repo Git: Outros pacotes de funcionalidades específicas/compartilhadas
```

**Ideias de features:**

*   **Comuns:** Gestão de tarefas, Gestão de projetos, Gestão de usuários, Gestão de finanças, Gestão de imagens.
*   **Específicas (ex: SMS):** Gestão de alunos, Gestão de turmas, Gestão de notas, Gestão de professores.

**Nomenclatura dos Sistemas e Aplicativos/Servidores:**

*   **Sistema Pai:** `ems_system` (EduMigSoft System)
*   **Sistema Filho - SMS:**
    *   **Nome do Sistema:** `sms_system` (School Management System)
    *   **Nome do Aplicativo/Servidor:** `schoolpilot_app` / `schoolpilot_server` (alinhado com o título comercial do aplicativo: "SchoolPilot")
*   **Sistema Filho - EMS (Agregador):**
    *   **Nome do Sistema:** `ems` (filho de `ems_system`)
    *   **Nomes Sugeridos para Aplicativo/Servidor:**
        *   `edumanager_app` / `edumanager_server` (direto e funcional)
        *   `suiteedu_app` / `suiteedu_server` (corporativo, sugestivo de conjunto de ferramentas)
        *   `orbitedu_app` / `orbitedu_server` (criativo e moderno)
        *   `aura_app` / `aura_server` (se `Aura` for evoluída para representar a plataforma completa)

### Por que esta decisão?

1.  **Autonomia e Isolamento:** Cada repositório (sistema, versão, feature) é independente, permitindo que equipes diferentes trabalhem com liberdade, usando seus próprios ciclos de desenvolvimento, CI/CD e versionamento.
2.  **Flexibilidade e Escalabilidade:** Facilita o crescimento e a adição de novos sistemas ou features sem impactar diretamente os existentes.
3.  **Reutilização Controlada:** O uso de pacotes compartilhados (publicados via `pub.dev` ou outro registry) permite reutilização de código, mas com controle de versão rigoroso (SemVer), evitando quebras inesperadas.
4.  **Preparação para Evolução:** A estrutura é mais alinhada com modelos de microsserviços ou arquiteturas distribuídas, preparando o terreno para evoluções futuras.
5.  **Evita Complexidade de Monorepo:** Descarta a complexidade de ferramentas como `melos` e gerenciamento centralizado de múltiplos pacotes em um único repositório, optando por uma abordagem mais direta e baseada em dependências versionadas.

### Problemas possíveis

1.  **Gestão de Dependências:** Coordenar versões de pacotes compartilhados entre múltiplos repositórios pode se tornar complexo.
2.  **Coordenação entre Times:** Requer processos claros de comunicação e planejamento quando mudanças em pacotes base afetam múltiplos sistemas.
3.  **Documentação Distribuída:** Mantê-la centralizada e atualizada exige disciplina.

### Soluções possíveis

1.  **Versionamento Semântico (SemVer):** Aplicar rigorosamente SemVer nos pacotes compartilhados (`core`, `user`, etc.) e gerenciar suas versões nos `pubspec.yaml` dos apps e servers.
2.  **Processos de Comunicação:** Estabelecer fluxos de comunicação claros entre equipes para anunciar mudanças importantes em pacotes compartilhados.
3.  **Documentação Centralizada:** Manter no `repositorio_pai` uma documentação de alto nível, visão geral da arquitetura e links para documentações específicas de cada repositório.
4.  **Scripts de Automação:** Criar scripts locais para facilitar tarefas repetitivas que envolvem múltiplos repositórios (ex: `git pull` em todos, rodar testes básicos).
5.  **Testes Integrados:** Configurar pipelines de CI/CD que testem a compatibilidade entre diferentes versões de pacotes e aplicações dependentes.