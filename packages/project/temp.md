# 📋 Feature: Gerenciamento de Projetos

> Sistema flexível e progressivo para gerenciamento de projetos, tarefas e anotações

---

## 📖 Índice

- [Visão Geral](#visão-geral)
- [Para Usuários](#para-usuários)
  - [Como Usar](#como-usar)
  - [Modos de Criação](#modos-de-criação)
  - [Evoluindo seus Itens](#evoluindo-seus-itens)
- [Para Desenvolvedores](#para-desenvolvedores)
  - [Arquitetura](#arquitetura)
  - [Estrutura de Pastas](#estrutura-de-pastas)
  - [Modelos de Dados](#modelos-de-dados)
  - [API Endpoints](#api-endpoints)
  - [Banco de Dados](#banco-de-dados)
  - [Exemplos de Código](#exemplos-de-código)

---

## 🎯 Visão Geral

A feature de **Gerenciamento de Projetos** é um sistema completo para organizar trabalho, ideias e tarefas. O diferencial está na **flexibilidade progressiva**: você começa simples e expande conforme suas necessidades crescem.

### Princípios de Design

1. **Simplicidade Inicial** - Comece com o mínimo necessário
2. **Evolução Orgânica** - Adicione complexidade quando precisar
3. **Sem Bloqueios** - Todos os recursos disponíveis desde o início
4. **Múltiplas Formas** - Escolha o nível de detalhe para cada item

---

## 👥 Para Usuários

### 📍 Como Usar

A feature está organizada em um menu principal na sidebar do sistema:

```
📋 Gerenciamento de Projetos
   📊 Visão Geral ........... Dashboard com estatísticas
   📁 Meus Projetos ........ Lista de todos os projetos
   ✅ Tarefas .............. Gerenciamento de tarefas
   📓 Cadernos ............. Anotações e documentação
   🎯 Board Kanban ......... Visualização em quadros
   🏷️  Tags ................ Gerenciar tags globais (opcional)
   📈 Relatórios ........... Análises e métricas
```

### 🎨 Modos de Criação

Cada tipo de item pode ser criado de diferentes formas, dependendo do que você precisa no momento:

#### ✅ **Nova Tarefa**

Ao clicar em "+ Nova Tarefa", escolha entre:

| Modo | O que é | Quando usar |
|------|---------|-------------|
| ⚡ **Rápida** | Apenas título e prazo opcional | Lembretes simples, tarefas do dia a dia |
| 📋 **Completa** | Com projeto, categoria, prioridade, descrição | Tarefas complexas de trabalho |
| 🔄 **Recorrente** | Repetição automática (diária, semanal, mensal) | Rotinas e hábitos |

**Exemplo - Tarefa Rápida:**
```
Título: Comprar leite
Prazo: Hoje
```

**Exemplo - Tarefa Completa:**
```
Título: Implementar autenticação JWT
Projeto: Desenvolvimento App
Categoria: Backend
Prioridade: Alta
Prazo: 25/01/2026
Descrição: Configurar JWT no servidor...
```

---

#### 📓 **Novo Caderno**

Ao clicar em "+ Novo Caderno", escolha entre:

| Modo | O que é | Quando usar |
|------|---------|-------------|
| 💭 **Nota Rápida** | Texto simples, sem estrutura | Ideias soltas, anotações rápidas |
| 📖 **Caderno Organizado** | Com hierarquia, seções e tags | Documentação, estudos, planejamento |
| 📌 **Lembrete** | Nota com notificação programada | Lembretes importantes com hora marcada |

**Exemplo - Nota Rápida:**
```
"Ideia: adicionar modo escuro no app"
```

**Exemplo - Caderno Organizado:**
```
Título: Documentação da API
Projeto: Desenvolvimento App
Tags: documentação, backend, api

Conteúdo:
# Endpoints
## Autenticação
- POST /auth/login
- POST /auth/register
...
```

**Exemplo - Caderno com Documentos (NOVO!):**
```
Título: Resolução 45/2023 - Direitos de Alunos Atípicos

📝 Resumo/Anotações:
Esta resolução estabelece direitos fundamentais para alunos 
com necessidades especiais nas salas de recurso. Os principais 
pontos incluem:

- Atendimento individualizado obrigatório
- Material didático adaptado conforme necessidade
- Carga horária mínima de 4 horas semanais
- Profissionais especializados com formação específica
...
[resumo pode ser bem extenso, com formatação rica]

🏷️ Tags: 
- resolução
- sala_de_recurso  
- educação_especial
- legislação

📎 Documentos Anexados:
┌─────────────────────────────────────────────┐
│ 📄 resolucao_45_2023.pdf                   │
│    Servidor • 2.3 MB • PDF                  │
│    [👁️ Visualizar] [⬇️ Download]            │
├─────────────────────────────────────────────┤
│ 📄 parecer_juridico.docx                   │
│    Local • C:/Documentos/pareceres/...     │
│    [📂 Abrir Local]                         │
├─────────────────────────────────────────────┤
│ 🔗 Portal MEC - Resolução Completa         │
│    https://portal.mec.gov.br/resolucao-45  │
│    [🌐 Abrir Link]                          │
└─────────────────────────────────────────────┘

📁 Projeto: (opcional)
- Adequação da Escola XYZ aos Requisitos Legais
```

#### Como Adicionar Documentos a um Caderno

**Modo Simples (Usuário Leigo):**

1. Abra o caderno
2. Clique em **"📎 Adicionar Documento"**
3. Escolha uma opção:
   - **"📤 Enviar Arquivo"** → Arraste ou selecione arquivo do seu computador
   - **"🔗 Adicionar Link"** → Cole a URL de um documento online
   - **"📂 Arquivo Local"** → Indique onde está o arquivo no seu PC

4. O documento aparecerá na lista
5. Clique em **👁️ Visualizar** para ver direto na tela (PDFs e imagens)
6. Clique em **⬇️ Download** para baixar

**Modo Avançado:**

- Adicionar múltiplos documentos de uma vez
- Organizar documentos em categorias
- Adicionar descrição para cada documento
- Ver histórico de versões (se houver múltiplos uploads)

> 💡 **Dica:** Documentos enviados ao servidor ficam disponíveis de qualquer lugar. Referências locais funcionam apenas no seu computador.

---

#### 📁 **Novo Projeto**

Ao clicar em "+ Novo Projeto", escolha entre:

| Modo | O que é | Quando usar |
|------|---------|-------------|
| 🎯 **Simples** | Apenas nome e cor | Começar rápido, definir depois |
| 📊 **Completo** | Com datas, objetivos, cliente, categorias | Projetos profissionais estruturados |
| 📋 **Template** | Estrutura pré-configurada | Projetos recorrentes (ex: sprints) |

**Exemplo - Projeto Simples:**
```
Nome: Redesign Website
Cor: 🔵 Azul
```

**Exemplo - Projeto Completo:**
```
Nome: Desenvolvimento App Mobile
Descrição: Aplicativo para gestão de tarefas
Cor: 🟢 Verde
Data Início: 15/01/2026
Data Fim: 15/04/2026
Cliente: Interno - Equipe de Produto
Status: Em andamento
```

---

### 🔄 Evoluindo seus Itens

**A grande vantagem:** Você NÃO precisa criar tudo de novo se quiser adicionar mais informações depois!

#### Como expandir um Projeto Simples

**Dia 1 - Criação:**
```
📁 Redesign Website
   Cor: 🔵 Azul
   
   💡 Adicionar mais informações ➕
```

**Dia 3 - Adicionou descrição:**
```
📁 Redesign Website
   Cor: 🔵 Azul
   📝 Descrição: Reformular o site institucional
   
   💡 Adicionar prazos ➕
   💡 Adicionar cliente ➕
```

**Dia 7 - Projeto Completo:**
```
📁 Redesign Website
   Cor: 🔵 Azul
   📝 Descrição: Reformular o site institucional
   📅 Início: 20/01/2026
   ⏰ Prazo: 20/03/2026
   👤 Cliente: Marketing Interno
   📊 Status: Em andamento
   
   ✅ 5 Tarefas concluídas
   📓 3 Cadernos
   🎯 Board Kanban ativo
```

#### Como fazer:

1. Abra o projeto clicando nele
2. Clique em **⚙️ Configurações do Projeto** (canto superior direito)
3. Preencha os campos que desejar
4. Salve - pronto! Suas informações foram adicionadas

> 💡 **Dica:** O mesmo funciona para Tarefas e Cadernos. Comece simples, expanda quando precisar!

---

## 🛠️ Para Desenvolvedores

### 🏗️ Arquitetura

A feature segue uma **arquitetura modular e em camadas**, com separação clara entre client, server e shared:

```
features/project_management/
├── shared/           # Entidades puras (sem dependências externas)
├── client/           # Código Flutter (UI + API calls)
├── server/           # Código Dart/Shelf (API + Business Logic)
└── sub_features/     # Módulos específicos
```

#### Princípios Arquiteturais

1. **Separation of Concerns** - Cada camada tem sua responsabilidade
2. **Dependency Inversion** - Shared não depende de nada, client e server dependem de shared
3. **Feature-First** - Organização por features, não por camadas técnicas
4. **Progressive Enhancement** - Campos opcionais permitem evolução

#### ⚠️ IMPORTANTE: Separação de Camadas

**SHARED (shared/) - Pura Dart:**
- ✅ Apenas Dart puro (sem dependências externas)
- ✅ Entidades, enums, value objects
- ✅ Lógica de negócio pura
- ❌ NÃO pode importar Flutter
- ❌ NÃO pode importar Dio, HTTP, etc
- ❌ NÃO pode importar bibliotecas de UI

**CLIENT (client/) - Dart + Dependências:**
- ✅ Pode importar shared/
- ✅ Pode importar Dio, HTTP
- ✅ Lógica de comunicação com API
- ❌ NÃO pode importar Flutter widgets

**UI (ui/) - Flutter:**
- ✅ Pode importar shared/
- ✅ Pode importar client/
- ✅ Pode importar Flutter completo
- ✅ Widgets, páginas, state management

**SERVER (server/) - Dart + Shelf:**
- ✅ Pode importar shared/
- ✅ Pode importar Shelf, PostgreSQL
- ✅ Routes, controllers, repositories
- ❌ NÃO pode importar Flutter

**Exemplo de conversão entre camadas:**
```dart
// SHARED: SimpleTime (pura Dart)
class SimpleTime {
  final int hour;
  final int minute;
}

// UI: Extension para converter (só existe na camada ui/)
extension SimpleTimeExtension on SimpleTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

extension TimeOfDayExtension on TimeOfDay {
  SimpleTime toSimpleTime() => SimpleTime(hour, minute);
}

// USO na UI:
final simpleTime = SimpleTime(9, 30);
final timeOfDay = simpleTime.toTimeOfDay(); // Conversão só na UI
```

---

### 📂 Estrutura de Pastas

```
lib/features/project_management/
│
├── shared/
│   ├── entities/
│   │   ├── project.dart           # Entidade Project (imutável)
│   │   ├── task.dart              # Entidade Task
│   │   ├── notebook.dart          # Entidade Notebook
│   │   └── category.dart          # Entidade Category
│   │
│   ├── enums/
│   │   ├── project_status.dart    # active, archived, completed
│   │   ├── task_priority.dart     # low, medium, high, urgent
│   │   ├── task_status.dart       # todo, inProgress, blocked, done
│   │   └── category_type.dart     # task, notebook, both
│   │
│   └── exceptions/
│       ├── project_not_found_exception.dart
│       └── validation_exception.dart
│
├── sub_features/
│   │
│   ├── projects/
│   │   ├── client/
│   │   │   ├── datasources/
│   │   │   │   └── project_remote_datasource.dart
│   │   │   ├── repositories/
│   │   │   │   └── project_repository_impl.dart
│   │   │   └── models/
│   │   │       └── project_model.dart         # Project + JSON serialization
│   │   │
│   │   ├── server/
│   │   │   ├── routes/
│   │   │   │   └── project_routes.dart        # Definição de rotas
│   │   │   ├── controllers/
│   │   │   │   └── project_controller.dart    # Handlers das requisições
│   │   │   ├── repositories/
│   │   │   │   └── project_repository.dart    # Acesso ao banco
│   │   │   └── models/
│   │   │       └── project_db_model.dart      # Mapeamento DB
│   │   │
│   │   └── ui/
│   │       ├── pages/
│   │       │   ├── project_list_page.dart
│   │       │   ├── project_detail_page.dart
│   │       │   └── project_settings_page.dart
│   │       ├── widgets/
│   │       │   ├── project_card.dart
│   │       │   ├── project_creation_modal.dart
│   │       │   └── project_expansion_card.dart
│   │       ├── state/
│   │       │   └── project_provider.dart      # State management
│   │       └── extensions/
│   │           └── time_extensions.dart       # SimpleTime ↔ TimeOfDay
│   │
│   ├── tasks/
│   │   ├── client/
│   │   ├── server/
│   │   └── ui/
│   │
│   ├── notebooks/
│   │   ├── client/
│   │   ├── server/
│   │   └── ui/
│   │
│   └── boards/
│       ├── client/
│       ├── server/
│       └── ui/
│
└── core/
    ├── client/
    │   └── dio_config.dart            # Configuração HTTP client
    ├── server/
    │   ├── middleware/
    │   │   ├── auth_middleware.dart
    │   │   └── error_handler.dart
    │   └── database/
    │       └── connection.dart
    └── ui/
        ├── theme/
        └── widgets/
```

---

### 📊 Modelos de Dados

#### Entidade: Project (shared)

```dart
// shared/entities/project.dart

class Project {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
  
  // Campos OPCIONAIS - permitem evolução progressiva
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? client;
  final ProjectStatus? status;
  final List<String>? tags;
  final DateTime? updatedAt;
  
  const Project({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.description,
    this.startDate,
    this.endDate,
    this.client,
    this.status,
    this.tags,
    this.updatedAt,
  });
  
  /// Verifica se o projeto tem informações completas
  bool get isComplete => 
    description != null && 
    startDate != null && 
    client != null;
  
  /// Verifica se o projeto é "simples" (apenas campos básicos)
  bool get isSimple => 
    description == null && 
    startDate == null && 
    client == null;
  
  /// Cria uma cópia com novos valores (imutabilidade)
  Project copyWith({
    String? name,
    String? color,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? client,
    ProjectStatus? status,
    List<String>? tags,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      client: client ?? this.client,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      updatedAt: DateTime.now(),
    );
  }
}
```

#### Enums Compartilhados (shared/enums/)

```dart
// shared/enums/project_status.dart
enum ProjectStatus {
  active,      // Projeto ativo/em andamento
  archived,    // Arquivado (pausado/guardado)
  completed,   // Concluído
}

// shared/enums/task_priority.dart
enum TaskPriority {
  low,         // Baixa prioridade
  medium,      // Média prioridade
  high,        // Alta prioridade
  urgent,      // Urgente
}

// shared/enums/task_status.dart
enum TaskStatus {
  todo,        // A fazer
  inProgress,  // Em progresso
  blocked,     // Bloqueada
  done,        // Concluída
}

// shared/enums/category_type.dart
enum CategoryType {
  task,        // Categoria apenas para tarefas
  notebook,    // Categoria apenas para cadernos
  both,        // Categoria para ambos
}

// shared/enums/recurrence_type.dart
enum RecurrenceType {
  daily,       // Diária
  weekly,      // Semanal
  monthly,     // Mensal
  custom,      // Personalizada
}

// shared/enums/notebook_type.dart
enum NotebookType {
  quick,       // Nota rápida
  organized,   // Caderno organizado
  reminder,    // Lembrete
}

// shared/enums/document_storage_type.dart
enum DocumentStorageType {
  server,      // Armazenado no servidor
  local,       // Caminho local do usuário
  url,         // URL externa
}
```

**Nota sobre TimeOfDay:**
```dart
// TimeOfDay é uma classe do Flutter (não enum)
// NÃO pode ser usado no shared/ pois cria dependência

// SOLUÇÃO: Usar SimpleTime no shared (pura Dart)
// shared/value_objects/simple_time.dart
class SimpleTime {
  final int hour;    // 0-23
  final int minute;  // 0-59
  
  const SimpleTime(this.hour, this.minute);
  
  /// Valida se é um horário válido
  bool get isValid => hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  
  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is SimpleTime && hour == other.hour && minute == other.minute;
  
  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

// CONVERSÃO acontece apenas na camada UI (client/ui/)
// ui/extensions/time_extensions.dart
extension TimeOfDayExtension on TimeOfDay {
  SimpleTime toSimpleTime() => SimpleTime(hour, minute);
}

extension SimpleTimeExtension on SimpleTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

// EXEMPLO DE USO:
// No shared: Recurrence tem SimpleTime (pura Dart)
// No UI: Converte SimpleTime ↔ TimeOfDay quando necessário
// No server: Usa SimpleTime diretamente ou converte para String
```

#### Entidade: Task (shared)

```dart
// shared/entities/task.dart

class Task {
  final String id;
  final String title;
  final DateTime createdAt;
  
  // Campos OPCIONAIS
  final String? projectId;        // Vinculação com projeto
  final String? notebookId;       // Vinculação com caderno
  final String? description;
  final DateTime? dueDate;
  final TaskPriority? priority;
  final TaskStatus? status;
  final List<String>? categories;
  final Recurrence? recurrence;   // Para tarefas recorrentes
  final DateTime? completedAt;
  
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.projectId,
    this.notebookId,
    this.description,
    this.dueDate,
    this.priority,
    this.status,
    this.categories,
    this.recurrence,
    this.completedAt,
  });
  
  /// Verifica se é uma tarefa "rápida" (mínimo de campos)
  bool get isQuick => 
    projectId == null && 
    priority == null && 
    categories == null;
  
  /// Verifica se é recorrente
  bool get isRecurring => recurrence != null;
  
  /// Verifica se está concluída
  bool get isCompleted => completedAt != null;
}

// Modelo para recorrência
class Recurrence {
  final RecurrenceType type;      // daily, weekly, monthly, custom
  final int interval;              // A cada X dias/semanas/meses
  final SimpleTime? preferredTime; // Horário preferido (em vez de TimeOfDay)
  final DateTime? endDate;         // Até quando repetir (opcional)
  
  const Recurrence({
    required this.type,
    this.interval = 1,
    this.preferredTime,
    this.endDate,
  });
}
```

#### Entidade: Notebook (shared)

```dart
// shared/entities/notebook.dart

class Notebook {
  final String id;
  final String title;
  final String content;            // Markdown ou texto rico (resumo/anotações)
  final DateTime createdAt;
  
  // Campos OPCIONAIS
  final String? projectId;         // Vinculação com projeto
  final String? parentId;          // Para hierarquia (subpáginas)
  final List<String>? tags;
  final NotebookType? type;        // quick, organized, reminder
  final DateTime? reminderDate;    // Para tipo "reminder"
  final bool? notifyOnReminder;
  final DateTime? updatedAt;
  
  // NOVO: Documentos anexados/referenciados
  final List<DocumentReference>? documents;
  
  const Notebook({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.projectId,
    this.parentId,
    this.tags,
    this.type,
    this.reminderDate,
    this.notifyOnReminder,
    this.updatedAt,
    this.documents,
  });
  
  /// Verifica se é uma nota rápida
  bool get isQuickNote => type == NotebookType.quick;
  
  /// Verifica se é um lembrete
  bool get isReminder => type == NotebookType.reminder;
  
  /// Verifica se tem subpáginas (é pai)
  bool get hasChildren => parentId == null;
  
  /// Verifica se tem documentos anexados
  bool get hasDocuments => documents != null && documents!.isNotEmpty;
}

/// Representa uma referência a um documento (arquivo ou URL)
class DocumentReference {
  final String id;
  final String name;               // Nome do arquivo/documento
  final String path;               // Caminho ou URL
  final DocumentStorageType storageType; // server, local, url
  final String? mimeType;          // Ex: application/pdf, image/png
  final int? sizeBytes;            // Tamanho do arquivo (se aplicável)
  final DateTime uploadedAt;
  
  const DocumentReference({
    required this.id,
    required this.name,
    required this.path,
    required this.storageType,
    this.mimeType,
    this.sizeBytes,
    required this.uploadedAt,
  });
  
  /// Verifica se é um PDF
  bool get isPdf => mimeType?.contains('pdf') ?? false;
  
  /// Verifica se é uma imagem
  bool get isImage => mimeType?.startsWith('image/') ?? false;
  
  /// Verifica se está no servidor (pode fazer download)
  bool get isOnServer => storageType == DocumentStorageType.server;
  
  /// Verifica se é apenas uma URL externa
  bool get isExternalUrl => storageType == DocumentStorageType.url;
  
  /// Retorna tamanho formatado
  String get formattedSize {
    if (sizeBytes == null) return 'Desconhecido';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

---

### 🔌 API Endpoints

#### Projects

```dart
// server/routes/project_routes.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ProjectRoutes {
  final ProjectController _controller;
  
  ProjectRoutes(this._controller);
  
  Router get router {
    final router = Router();
    
    // CRUD básico
    router.get('/projects', _controller.listProjects);
    router.get('/projects/<id>', _controller.getProject);
    router.post('/projects', _controller.createProject);
    router.put('/projects/<id>', _controller.updateProject);
    router.patch('/projects/<id>', _controller.partialUpdateProject);  // 👈 Importante!
    router.delete('/projects/<id>', _controller.deleteProject);
    
    // Relacionamentos
    router.get('/projects/<projectId>/tasks', _controller.getProjectTasks);
    router.get('/projects/<projectId>/notebooks', _controller.getProjectNotebooks);
    router.get('/projects/<projectId>/stats', _controller.getProjectStats);
    
    return router;
  }
}
```

#### Controller: Update Parcial (permite evolução)

```dart
// server/controllers/project_controller.dart

class ProjectController {
  final ProjectRepository _repository;
  
  ProjectController(this._repository);
  
  /// PATCH /projects/{id}
  /// Atualiza apenas os campos enviados (permite evolução progressiva)
  Future<Response> partialUpdateProject(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      // Busca projeto atual
      final project = await _repository.findById(id);
      if (project == null) {
        return Response.notFound(
          jsonEncode({'error': 'Projeto não encontrado'}),
        );
      }
      
      // Atualiza apenas campos que vieram no request
      final updated = project.copyWith(
        name: data['name'],
        description: data['description'],
        startDate: data['startDate'] != null 
          ? DateTime.parse(data['startDate']) 
          : null,
        endDate: data['endDate'] != null 
          ? DateTime.parse(data['endDate']) 
          : null,
        client: data['client'],
        status: data['status'] != null
          ? ProjectStatus.values.byName(data['status'])
          : null,
      );
      
      await _repository.update(updated);
      
      return Response.ok(
        jsonEncode(ProjectModel.fromEntity(updated).toJson()),
        headers: {'Content-Type': 'application/json'},
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}
```

#### Notebooks

```dart
// server/routes/notebook_routes.dart

class NotebookRoutes {
  final NotebookController _controller;
  
  NotebookRoutes(this._controller);
  
  Router get router {
    final router = Router();
    
    // CRUD básico
    router.get('/notebooks', _controller.listNotebooks);
    router.get('/notebooks/<id>', _controller.getNotebook);
    router.post('/notebooks', _controller.createNotebook);
    router.patch('/notebooks/<id>', _controller.partialUpdateNotebook);
    router.delete('/notebooks/<id>', _controller.deleteNotebook);
    
    // NOVO: Gestão de documentos
    router.post('/notebooks/<notebookId>/documents', _controller.uploadDocument);
    router.post('/notebooks/<notebookId>/documents/reference', _controller.addDocumentReference);
    router.get('/notebooks/<notebookId>/documents', _controller.listDocuments);
    router.get('/notebooks/<notebookId>/documents/<documentId>/download', _controller.downloadDocument);
    router.get('/notebooks/<notebookId>/documents/<documentId>/view', _controller.viewDocument);
    router.delete('/notebooks/<notebookId>/documents/<documentId>', _controller.deleteDocument);
    
    // Filtros
    router.get('/notebooks/by-tag/<tag>', _controller.getNotebooksByTag);
    router.get('/notebooks/by-project/<projectId>', _controller.getNotebooksByProject);
    
    return router;
  }
}
```

#### Exemplo: Upload de Documento

```dart
// server/controllers/notebook_controller.dart

import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class NotebookController {
  final NotebookRepository _notebookRepo;
  final DocumentRepository _documentRepo;
  final String uploadsDirectory = '/uploads/notebooks';
  
  NotebookController(this._notebookRepo, this._documentRepo);
  
  /// POST /notebooks/{notebookId}/documents
  /// Upload de arquivo para o servidor
  Future<Response> uploadDocument(Request request, String notebookId) async {
    try {
      // Verifica se o notebook existe
      final notebook = await _notebookRepo.findById(notebookId);
      if (notebook == null) {
        return Response.notFound(
          jsonEncode({'error': 'Caderno não encontrado'}),
        );
      }
      
      // Lê o arquivo do multipart/form-data
      final contentType = request.headers['content-type'];
      if (contentType == null || !contentType.contains('multipart/form-data')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Content-Type deve ser multipart/form-data'}),
        );
      }
      
      final boundary = contentType.split('boundary=')[1];
      final transformer = MimeMultipartTransformer(boundary);
      final bodyStream = request.read();
      final parts = await transformer.bind(bodyStream).toList();
      
      String? fileName;
      List<int>? fileBytes;
      
      for (var part in parts) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition != null && contentDisposition.contains('filename=')) {
          // Extrai nome do arquivo
          final match = RegExp(r'filename="(.+)"').firstMatch(contentDisposition);
          fileName = match?.group(1);
          
          // Lê bytes do arquivo
          fileBytes = await part.toList().then((lists) {
            return lists.expand((list) => list).toList();
          });
          break;
        }
      }
      
      if (fileName == null || fileBytes == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Nenhum arquivo enviado'}),
        );
      }
      
      // Valida tamanho (máximo 50MB)
      const maxSize = 50 * 1024 * 1024;
      if (fileBytes.length > maxSize) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Arquivo muito grande. Máximo: 50MB'}),
        );
      }
      
      // Gera ID único para o arquivo
      final fileId = Uuid().v4();
      final fileExtension = path.extension(fileName);
      final safeName = '${fileId}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      
      // Cria diretório se não existir
      final notebookDir = path.join(uploadsDirectory, notebookId);
      await Directory(notebookDir).create(recursive: true);
      
      // Salva arquivo
      final filePath = path.join(notebookDir, safeName);
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      // Detecta MIME type
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      
      // Salva referência no banco
      final documentRef = DocumentReference(
        id: fileId,
        name: fileName,
        path: filePath,
        storageType: DocumentStorageType.server,
        mimeType: mimeType,
        sizeBytes: fileBytes.length,
        uploadedAt: DateTime.now(),
      );
      
      await _documentRepo.create(notebookId, documentRef);
      
      return Response.ok(
        jsonEncode(DocumentReferenceModel.fromEntity(documentRef).toJson()),
        headers: {'Content-Type': 'application/json'},
      );
      
    } catch (e, stackTrace) {
      print('Erro no upload: $e\n$stackTrace');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
  
  /// POST /notebooks/{notebookId}/documents/reference
  /// Adiciona referência a documento externo (URL ou caminho local)
  Future<Response> addDocumentReference(Request request, String notebookId) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final name = data['name'] as String?;
      final documentPath = data['path'] as String?;
      final storageType = data['storageType'] as String?;
      
      if (name == null || documentPath == null || storageType == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Campos obrigatórios: name, path, storageType'}),
        );
      }
      
      // Valida storage type
      final type = DocumentStorageType.values.byName(storageType);
      
      // Valida URL se for externa
      if (type == DocumentStorageType.url) {
        final uri = Uri.tryParse(documentPath);
        if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
          return Response.badRequest(
            body: jsonEncode({'error': 'URL inválida'}),
          );
        }
      }
      
      final documentRef = DocumentReference(
        id: Uuid().v4(),
        name: name,
        path: documentPath,
        storageType: type,
        mimeType: data['mimeType'],
        sizeBytes: data['sizeBytes'],
        uploadedAt: DateTime.now(),
      );
      
      await _documentRepo.create(notebookId, documentRef);
      
      return Response.ok(
        jsonEncode(DocumentReferenceModel.fromEntity(documentRef).toJson()),
        headers: {'Content-Type': 'application/json'},
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
  
  /// GET /notebooks/{notebookId}/documents/{documentId}/download
  /// Faz download do arquivo (apenas para storageType = server)
  Future<Response> downloadDocument(
    Request request,
    String notebookId,
    String documentId,
  ) async {
    try {
      final document = await _documentRepo.findById(documentId);
      
      if (document == null) {
        return Response.notFound(
          jsonEncode({'error': 'Documento não encontrado'}),
        );
      }
      
      if (document.storageType != DocumentStorageType.server) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Este documento não está no servidor'}),
        );
      }
      
      final file = File(document.path);
      if (!await file.exists()) {
        return Response.notFound(
          jsonEncode({'error': 'Arquivo não encontrado no servidor'}),
        );
      }
      
      final bytes = await file.readAsBytes();
      
      return Response.ok(
        bytes,
        headers: {
          'Content-Type': document.mimeType ?? 'application/octet-stream',
          'Content-Disposition': 'attachment; filename="${document.name}"',
          'Content-Length': bytes.length.toString(),
        },
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
  
  /// GET /notebooks/{notebookId}/documents/{documentId}/view
  /// Visualiza o arquivo no navegador (inline, não download)
  Future<Response> viewDocument(
    Request request,
    String notebookId,
    String documentId,
  ) async {
    try {
      final document = await _documentRepo.findById(documentId);
      
      if (document == null || document.storageType != DocumentStorageType.server) {
        return Response.notFound();
      }
      
      final file = File(document.path);
      if (!await file.exists()) {
        return Response.notFound();
      }
      
      final bytes = await file.readAsBytes();
      
      return Response.ok(
        bytes,
        headers: {
          'Content-Type': document.mimeType ?? 'application/octet-stream',
          'Content-Disposition': 'inline; filename="${document.name}"',
        },
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}
```

---

### 🗄️ Banco de Dados

#### Schema PostgreSQL

```sql
-- ============================================
-- PROJECTS
-- ============================================
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  color VARCHAR(7) NOT NULL,  -- Formato: #RRGGBB
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Campos OPCIONAIS (nullable para evolução progressiva)
  description TEXT NULL,
  start_date DATE NULL,
  end_date DATE NULL,
  client VARCHAR(255) NULL,
  status VARCHAR(50) NULL,  -- active, archived, completed
  updated_at TIMESTAMP NULL,
  
  -- Soft delete (opcional)
  deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_projects_status ON projects(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_projects_created ON projects(created_at DESC);

-- ============================================
-- TASKS
-- ============================================
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(500) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Relacionamentos OPCIONAIS
  project_id UUID NULL REFERENCES projects(id) ON DELETE CASCADE,
  notebook_id UUID NULL REFERENCES notebooks(id) ON DELETE SET NULL,
  
  -- Campos OPCIONAIS
  description TEXT NULL,
  due_date TIMESTAMP NULL,
  priority VARCHAR(50) NULL,  -- low, medium, high, urgent
  status VARCHAR(50) NULL DEFAULT 'todo',  -- todo, inProgress, blocked, done
  completed_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  
  -- Recorrência (campos separados ou JSON)
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_type VARCHAR(50) NULL,  -- daily, weekly, monthly, custom
  recurrence_interval INTEGER NULL DEFAULT 1,
  recurrence_end_date DATE NULL,
  
  deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_tasks_project ON tasks(project_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_due_date ON tasks(due_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_status ON tasks(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_completed ON tasks(completed_at) WHERE completed_at IS NOT NULL;

-- ============================================
-- NOTEBOOKS
-- ============================================
CREATE TABLE notebooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(500) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Relacionamentos OPCIONAIS
  project_id UUID NULL REFERENCES projects(id) ON DELETE CASCADE,
  parent_id UUID NULL REFERENCES notebooks(id) ON DELETE CASCADE,
  
  -- Campos OPCIONAIS
  type VARCHAR(50) NULL,  -- quick, organized, reminder
  reminder_date TIMESTAMP NULL,
  notify_on_reminder BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMP NULL,
  
  deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_notebooks_project ON notebooks(project_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_notebooks_parent ON notebooks(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_notebooks_reminder ON notebooks(reminder_date) WHERE deleted_at IS NULL;

-- ============================================
-- DOCUMENT_REFERENCES (Documentos anexados aos cadernos)
-- ============================================
CREATE TABLE document_references (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notebook_id UUID NOT NULL REFERENCES notebooks(id) ON DELETE CASCADE,
  
  name VARCHAR(500) NOT NULL,              -- Nome do arquivo/documento
  path TEXT NOT NULL,                      -- Caminho no servidor, local ou URL
  storage_type VARCHAR(50) NOT NULL,       -- server, local, url
  mime_type VARCHAR(100) NULL,             -- application/pdf, image/png, etc
  size_bytes BIGINT NULL,                  -- Tamanho do arquivo
  
  uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_document_references_notebook ON document_references(notebook_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_document_references_storage_type ON document_references(storage_type) WHERE deleted_at IS NULL;

-- Para documentos no servidor, criar diretório de uploads
-- Exemplo de estrutura: /uploads/notebooks/{notebook_id}/{file_id}_{original_name}

-- ============================================
-- TAGS (Global - compartilhadas entre projetos/notebooks)
-- ============================================
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_usage ON tags(usage_count DESC);

-- ============================================
-- NOTEBOOK_TAGS (Many-to-Many)
-- ============================================
CREATE TABLE notebook_tags (
  notebook_id UUID REFERENCES notebooks(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (notebook_id, tag_id)
);

-- ============================================
-- PROJECT_TAGS (Many-to-Many)
-- ============================================
CREATE TABLE project_tags (
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (project_id, tag_id)
);

-- ============================================
-- CATEGORIES (Específicas por projeto)
-- ============================================
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(7) NULL,
  type VARCHAR(50) NOT NULL,  -- task, notebook, both
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  UNIQUE(project_id, name)
);

-- ============================================
-- TASK_CATEGORIES (Many-to-Many)
-- ============================================
CREATE TABLE task_categories (
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (task_id, category_id)
);

-- ============================================
-- VIEWS ÚTEIS
-- ============================================

-- Projetos com contagem de tarefas
CREATE VIEW projects_with_stats AS
SELECT 
  p.*,
  COUNT(DISTINCT t.id) FILTER (WHERE t.completed_at IS NULL) as pending_tasks,
  COUNT(DISTINCT t.id) FILTER (WHERE t.completed_at IS NOT NULL) as completed_tasks,
  COUNT(DISTINCT n.id) as notebooks_count
FROM projects p
LEFT JOIN tasks t ON t.project_id = p.id AND t.deleted_at IS NULL
LEFT JOIN notebooks n ON n.project_id = p.id AND n.deleted_at IS NULL
WHERE p.deleted_at IS NULL
GROUP BY p.id;

-- Tarefas de hoje
CREATE VIEW tasks_today AS
SELECT * FROM tasks
WHERE DATE(due_date) = CURRENT_DATE
  AND completed_at IS NULL
  AND deleted_at IS NULL
ORDER BY priority DESC, created_at ASC;

-- Tarefas atrasadas
CREATE VIEW tasks_overdue AS
SELECT * FROM tasks
WHERE due_date < CURRENT_TIMESTAMP
  AND completed_at IS NULL
  AND deleted_at IS NULL
ORDER BY due_date ASC;
```

---

### 💻 Exemplos de Código

#### Client: Criando uma Tarefa Rápida

```dart
// client/datasources/task_remote_datasource.dart

class TaskRemoteDataSource {
  final Dio _dio;
  final String baseUrl;
  
  TaskRemoteDataSource(this._dio, this.baseUrl);
  
  /// Cria uma tarefa RÁPIDA (apenas título e prazo)
  Future<TaskModel> createQuickTask({
    required String title,
    DateTime? dueDate,
  }) async {
    final response = await _dio.post(
      '$baseUrl/tasks',
      data: {
        'title': title,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        // Apenas campos essenciais
      },
    );
    
    return TaskModel.fromJson(response.data);
  }
  
  /// Cria uma tarefa COMPLETA
  Future<TaskModel> createCompleteTask({
    required String title,
    String? description,
    String? projectId,
    String? categoryId,
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    final response = await _dio.post(
      '$baseUrl/tasks',
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (projectId != null) 'projectId': projectId,
        if (categoryId != null) 'categoryId': categoryId,
        if (priority != null) 'priority': priority.name,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      },
    );
    
    return TaskModel.fromJson(response.data);
  }
  
  /// Expande uma tarefa (adiciona campos que faltavam)
  Future<TaskModel> expandTask({
    required String taskId,
    String? description,
    String? projectId,
    TaskPriority? priority,
  }) async {
    final response = await _dio.patch(
      '$baseUrl/tasks/$taskId',
      data: {
        if (description != null) 'description': description,
        if (projectId != null) 'projectId': projectId,
        if (priority != null) 'priority': priority.name,
      },
    );
    
    return TaskModel.fromJson(response.data);
  }
}
```

#### UI: Modal de Criação com Seleção de Modo

```dart
// ui/widgets/task_creation_modal.dart

class TaskCreationModal extends StatefulWidget {
  @override
  _TaskCreationModalState createState() => _TaskCreationModalState();
}

class _TaskCreationModalState extends State<TaskCreationModal> {
  TaskCreationMode? _selectedMode;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova Tarefa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            
            // Seleção de Modo
            if (_selectedMode == null) ...[
              _buildModeOption(
                icon: '⚡',
                title: 'Tarefa Rápida',
                description: 'Apenas título e prazo opcional',
                mode: TaskCreationMode.quick,
              ),
              SizedBox(height: 12),
              _buildModeOption(
                icon: '📋',
                title: 'Tarefa Completa',
                description: 'Com projeto, categoria e prioridade',
                mode: TaskCreationMode.complete,
              ),
              SizedBox(height: 12),
              _buildModeOption(
                icon: '🔄',
                title: 'Tarefa Recorrente',
                description: 'Repetir diariamente, semanalmente...',
                mode: TaskCreationMode.recurring,
              ),
            ]
            
            // Formulário correspondente ao modo
            else if (_selectedMode == TaskCreationMode.quick)
              _QuickTaskForm(onCancel: _resetMode)
            else if (_selectedMode == TaskCreationMode.complete)
              _CompleteTaskForm(onCancel: _resetMode)
            else if (_selectedMode == TaskCreationMode.recurring)
              _RecurringTaskForm(onCancel: _resetMode),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeOption({
    required String icon,
    required String title,
    required String description,
    required TaskCreationMode mode,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 32)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _resetMode() {
    setState(() => _selectedMode = null);
  }
}

enum TaskCreationMode { quick, complete, recurring }
```

#### UI: Card de Expansão (Adicionar Informações)

```dart
// ui/widgets/project_expansion_card.dart

class ProjectExpansionCard extends StatelessWidget {
  final Project project;
  final VoidCallback onExpand;
  
  const ProjectExpansionCard({
    required this.project,
    required this.onExpand,
  });
  
  @override
  Widget build(BuildContext context) {
    // Só mostra se o projeto ainda não tem todos os dados
    if (project.isComplete) return SizedBox.shrink();
    
    // Lista campos que estão faltando
    final missingFields = <String>[];
    if (project.description == null) missingFields.add('Descrição');
    if (project.startDate == null) missingFields.add('Data de início');
    if (project.endDate == null) missingFields.add('Prazo');
    if (project.client == null) missingFields.add('Cliente');
    
    return Card(
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: onExpand,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 12),
              Text(
                'Adicionar mais informações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Campos disponíveis: ${missingFields.join(', ')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onExpand,
                icon: Icon(Icons.edit),
                label: Text('Expandir Projeto'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### UI: Lista de Documentos Anexados

```dart
// ui/widgets/document_list.dart

class DocumentList extends StatelessWidget {
  final List<DocumentReference> documents;
  final Function(DocumentReference) onView;
  final Function(DocumentReference) onDownload;
  final Function(DocumentReference) onDelete;
  
  const DocumentList({
    required this.documents,
    required this.onView,
    required this.onDownload,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Nenhum documento anexado',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final doc = documents[index];
        return DocumentListTile(
          document: doc,
          onView: () => onView(doc),
          onDownload: () => onDownload(doc),
          onDelete: () => onDelete(doc),
        );
      },
    );
  }
}

class DocumentListTile extends StatelessWidget {
  final DocumentReference document;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  
  const DocumentListTile({
    required this.document,
    required this.onView,
    required this.onDownload,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildIcon(),
      title: Text(
        document.name,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: _buildSubtitle(),
      trailing: _buildActions(context),
    );
  }
  
  Widget _buildIcon() {
    IconData iconData;
    Color color;
    
    if (document.isPdf) {
      iconData = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (document.isImage) {
      iconData = Icons.image;
      color = Colors.blue;
    } else if (document.isExternalUrl) {
      iconData = Icons.link;
      color = Colors.green;
    } else {
      iconData = Icons.insert_drive_file;
      color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }
  
  Widget _buildSubtitle() {
    final parts = <String>[];
    
    // Tipo de armazenamento
    switch (document.storageType) {
      case DocumentStorageType.server:
        parts.add('Servidor');
        break;
      case DocumentStorageType.local:
        parts.add('Local');
        break;
      case DocumentStorageType.url:
        parts.add('URL Externa');
        break;
    }
    
    // Tamanho
    if (document.sizeBytes != null) {
      parts.add(document.formattedSize);
    }
    
    // Tipo
    if (document.mimeType != null) {
      final type = document.mimeType!.split('/').last.toUpperCase();
      parts.add(type);
    }
    
    return Text(
      parts.join(' • '),
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }
  
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão Visualizar (apenas para PDFs e imagens no servidor)
        if (document.isOnServer && (document.isPdf || document.isImage))
          IconButton(
            icon: Icon(Icons.visibility, size: 20),
            tooltip: 'Visualizar',
            onPressed: onView,
          ),
        
        // Botão Download (apenas para servidor)
        if (document.isOnServer)
          IconButton(
            icon: Icon(Icons.download, size: 20),
            tooltip: 'Download',
            onPressed: onDownload,
          ),
        
        // Botão Abrir (para local e URL)
        if (!document.isOnServer)
          IconButton(
            icon: Icon(Icons.open_in_new, size: 20),
            tooltip: document.isExternalUrl ? 'Abrir Link' : 'Abrir Local',
            onPressed: onView,
          ),
        
        // Botão Deletar
        IconButton(
          icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[300]),
          tooltip: 'Remover',
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }
  
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover documento?'),
        content: Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Remover'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      onDelete();
    }
  }
}
```

#### UI: Modal de Upload de Documento

```dart
// ui/widgets/document_upload_modal.dart

class DocumentUploadModal extends StatefulWidget {
  final String notebookId;
  
  const DocumentUploadModal({required this.notebookId});
  
  @override
  _DocumentUploadModalState createState() => _DocumentUploadModalState();
}

class _DocumentUploadModalState extends State<DocumentUploadModal> {
  DocumentUploadMode? _selectedMode;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar Documento',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            
            // Seleção de modo
            if (_selectedMode == null) ...[
              _buildModeOption(
                icon: Icons.cloud_upload,
                title: 'Enviar para Servidor',
                description: 'Upload de arquivo - disponível de qualquer lugar',
                mode: DocumentUploadMode.upload,
              ),
              SizedBox(height: 12),
              _buildModeOption(
                icon: Icons.link,
                title: 'Adicionar Link',
                description: 'URL de documento online (Google Drive, etc)',
                mode: DocumentUploadMode.url,
              ),
              SizedBox(height: 12),
              _buildModeOption(
                icon: Icons.folder,
                title: 'Arquivo Local',
                description: 'Referência a arquivo no seu computador',
                mode: DocumentUploadMode.local,
              ),
            ]
            
            // Formulários por modo
            else if (_selectedMode == DocumentUploadMode.upload)
              _UploadForm(
                notebookId: widget.notebookId,
                onCancel: _resetMode,
              )
            else if (_selectedMode == DocumentUploadMode.url)
              _UrlForm(
                notebookId: widget.notebookId,
                onCancel: _resetMode,
              )
            else if (_selectedMode == DocumentUploadMode.local)
              _LocalPathForm(
                notebookId: widget.notebookId,
                onCancel: _resetMode,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String description,
    required DocumentUploadMode mode,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _resetMode() {
    setState(() => _selectedMode = null);
  }
}

enum DocumentUploadMode { upload, url, local }

// Formulário de Upload
class _UploadForm extends StatefulWidget {
  final String notebookId;
  final VoidCallback onCancel;
  
  const _UploadForm({required this.notebookId, required this.onCancel});
  
  @override
  __UploadFormState createState() => __UploadFormState();
}

class __UploadFormState extends State<_UploadForm> {
  File? _selectedFile;
  bool _uploading = false;
  
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
    );
    
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }
  
  Future<void> _upload() async {
    if (_selectedFile == null) return;
    
    setState(() => _uploading = true);
    
    try {
      final datasource = context.read<NotebookRemoteDataSource>();
      await datasource.uploadDocument(
        notebookId: widget.notebookId,
        file: _selectedFile!,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento enviado com sucesso!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Área de drop
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: _selectedFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text('Clique ou arraste arquivo aqui'),
                    SizedBox(height: 4),
                    Text(
                      'PDF, DOC, TXT, Imagens (máx 50MB)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_drive_file, size: 48, color: Colors.blue),
                      SizedBox(height: 8),
                      Text(
                        path.basename(_selectedFile!.path),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${(_selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _selectedFile = null),
                        child: Text('Escolher outro arquivo'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
        
        SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _uploading ? null : widget.onCancel,
              child: Text('Cancelar'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: _selectedFile != null && !_uploading ? _upload : null,
              child: _uploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Enviar'),
            ),
          ],
        ),
      ],
    );
  }
}

// Formulário de URL (similar estrutura)
class _UrlForm extends StatefulWidget {
  final String notebookId;
  final VoidCallback onCancel;
  
  const _UrlForm({required this.notebookId, required this.onCancel});
  
  @override
  __UrlFormState createState() => __UrlFormState();
}

class __UrlFormState extends State<_UrlForm> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  
  Future<void> _addReference() async {
    final datasource = context.read<NotebookRemoteDataSource>();
    await datasource.addDocumentReference(
      notebookId: widget.notebookId,
      name: _nameController.text,
      path: _urlController.text,
      storageType: DocumentStorageType.url,
    );
    
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nome do documento',
            hintText: 'Ex: Resolução 45/2023',
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: 'URL',
            hintText: 'https://exemplo.com/documento.pdf',
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onCancel,
              child: Text('Cancelar'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addReference,
              child: Text('Adicionar'),
            ),
          ],
        ),
      ],
    );
  }
}
```

#### UI: Visualizador de PDF

```dart
// ui/widgets/pdf_viewer.dart

import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerPage extends StatelessWidget {
  final DocumentReference document;
  
  const PdfViewerPage({required this.document});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _downloadDocument(context),
            tooltip: 'Download',
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getDocumentPath(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar documento: ${snapshot.error}'),
            );
          }
          
          return PDFView(
            filePath: snapshot.data!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
          );
        },
      ),
    );
  }
  
  Future<String> _getDocumentPath(BuildContext context) async {
    final datasource = context.read<NotebookRemoteDataSource>();
    return await datasource.downloadDocumentToTemp(document.id);
  }
  
  Future<void> _downloadDocument(BuildContext context) async {
    // Implementar download para pasta Downloads do usuário
  }
}
```

#### Server: Repository com Update Parcial

```dart
// server/repositories/project_repository.dart

class ProjectRepository {
  final Database _db;
  
  ProjectRepository(this._db);
  
  /// Atualiza projeto (update completo - substitui todos os campos)
  Future<void> update(Project project) async {
    await _db.query('''
      UPDATE projects SET
        name = @name,
        color = @color,
        description = @description,
        start_date = @startDate,
        end_date = @endDate,
        client = @client,
        status = @status,
        tags = @tags,
        updated_at = NOW()
      WHERE id = @id AND deleted_at IS NULL
    ''', substitutionValues: {
      'id': project.id,
      'name': project.name,
      'color': project.color,
      'description': project.description,
      'startDate': project.startDate,
      'endDate': project.endDate,
      'client': project.client,
      'status': project.status?.name,
      'tags': project.tags,
    });
  }
  
  /// Atualiza parcialmente (apenas campos fornecidos)
  Future<void> partialUpdate(
    String id,
    Map<String, dynamic> fields,
  ) async {
    final updates = <String>[];
    final values = <String, dynamic>{'id': id};
    
    // Constrói query dinamicamente baseado nos campos fornecidos
    fields.forEach((key, value) {
      if (value != null) {
        updates.add('$key = @$key');
        values[key] = value;
      }
    });
    
    if (updates.isEmpty) return;
    
    updates.add('updated_at = NOW()');
    
    final query = '''
      UPDATE projects SET ${updates.join(', ')}
      WHERE id = @id AND deleted_at IS NULL
    ''';
    
    await _db.query(query, substitutionValues: values);
  }
  
  /// Busca projeto por ID
  Future<Project?> findById(String id) async {
    final result = await _db.query(
      'SELECT * FROM projects WHERE id = @id AND deleted_at IS NULL',
      substitutionValues: {'id': id},
    );
    
    if (result.isEmpty) return null;
    
    return ProjectDbModel.fromDb(result.first).toEntity();
  }
  
  /// Lista todos os projetos (com paginação opcional)
  Future<List<Project>> findAll({
    int? limit,
    int? offset,
    ProjectStatus? status,
  }) async {
    var query = 'SELECT * FROM projects WHERE deleted_at IS NULL';
    final values = <String, dynamic>{};
    
    if (status != null) {
      query += ' AND status = @status';
      values['status'] = status.name;
    }
    
    query += ' ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT @limit';
      values['limit'] = limit;
    }
    
    if (offset != null) {
      query += ' OFFSET @offset';
      values['offset'] = offset;
    }
    
    final result = await _db.query(query, substitutionValues: values);
    
    return result
      .map((row) => ProjectDbModel.fromDb(row).toEntity())
      .toList();
  }
}
```

---

### 🧪 Testes

#### Teste de Unidade: Entidade

```dart
// shared/entities/project_test.dart

import 'package:test/test.dart';

void main() {
  group('Project Entity', () {
    test('deve criar um projeto simples com campos mínimos', () {
      final project = Project(
        id: '123',
        name: 'Meu Projeto',
        color: '#3498db',
        createdAt: DateTime.now(),
      );
      
      expect(project.isSimple, true);
      expect(project.isComplete, false);
    });
    
    test('deve identificar projeto completo', () {
      final project = Project(
        id: '123',
        name: 'Meu Projeto',
        color: '#3498db',
        createdAt: DateTime.now(),
        description: 'Descrição',
        startDate: DateTime.now(),
        client: 'Cliente X',
      );
      
      expect(project.isSimple, false);
      expect(project.isComplete, true);
    });
    
    test('deve permitir copyWith para evolução', () {
      final original = Project(
        id: '123',
        name: 'Projeto Original',
        color: '#3498db',
        createdAt: DateTime.now(),
      );
      
      final expanded = original.copyWith(
        description: 'Nova descrição',
        client: 'Cliente ABC',
      );
      
      expect(expanded.id, original.id);
      expect(expanded.name, original.name);
      expect(expanded.description, 'Nova descrição');
      expect(expanded.client, 'Cliente ABC');
    });
  });
}
```

#### Teste de Integração: API

```dart
// server/routes/project_routes_test.dart

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Project API', () {
    late http.Client client;
    final baseUrl = 'http://localhost:8080';
    
    setUp(() {
      client = http.Client();
    });
    
    test('POST /projects - deve criar projeto simples', () async {
      final response = await client.post(
        Uri.parse('$baseUrl/projects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Projeto Teste',
          'color': '#3498db',
        }),
      );
      
      expect(response.statusCode, 201);
      
      final data = jsonDecode(response.body);
      expect(data['name'], 'Projeto Teste');
      expect(data['color'], '#3498db');
      expect(data['description'], null);
    });
    
    test('PATCH /projects/{id} - deve expandir projeto', () async {
      // Primeiro cria um projeto simples
      final createResponse = await client.post(
        Uri.parse('$baseUrl/projects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Projeto Teste',
          'color': '#3498db',
        }),
      );
      
      final projectId = jsonDecode(createResponse.body)['id'];
      
      // Depois expande com mais informações
      final patchResponse = await client.patch(
        Uri.parse('$baseUrl/projects/$projectId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': 'Descrição adicionada',
          'client': 'Cliente XYZ',
        }),
      );
      
      expect(patchResponse.statusCode, 200);
      
      final data = jsonDecode(patchResponse.body);
      expect(data['name'], 'Projeto Teste'); // Mantém
      expect(data['color'], '#3498db'); // Mantém
      expect(data['description'], 'Descrição adicionada'); // Novo
      expect(data['client'], 'Cliente XYZ'); // Novo
    });
  });
}
```

---

## 🚀 Como Começar

### Para Usuários

1. Acesse o menu **📋 Gerenciamento de Projetos** na sidebar
2. Clique em **+ Nova Tarefa**, **+ Novo Caderno** ou **+ Novo Projeto**
3. Escolha o modo que faz mais sentido para você naquele momento
4. Comece a usar! Você pode adicionar mais informações depois

### Para Desenvolvedores

#### 1. Configuração do Banco de Dados

```bash
# Execute o script SQL fornecido
psql -U seu_usuario -d seu_banco < database/schema.sql
```

#### 2. Configuração do Server (Dart/Shelf)

```dart
// bin/server.dart

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  // Configurar database
  final db = await Database.connect(/*...*/);
  
  // Criar repositories
  final projectRepo = ProjectRepository(db);
  final taskRepo = TaskRepository(db);
  
  // Criar controllers
  final projectController = ProjectController(projectRepo);
  final taskController = TaskController(taskRepo);
  
  // Configurar rotas
  final projectRoutes = ProjectRoutes(projectController);
  final taskRoutes = TaskRoutes(taskController);
  
  // Criar handler
  final handler = Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware(corsHeaders())
    .addHandler(
      Cascade()
        .add(projectRoutes.router)
        .add(taskRoutes.router)
        .handler
    );
  
  // Iniciar servidor
  final server = await io.serve(handler, 'localhost', 8080);
  print('Server running on http://${server.address.host}:${server.port}');
}
```

#### 3. Configuração do Client (Flutter)

```dart
// lib/main.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dio configuration
        Provider(create: (_) => Dio(BaseOptions(baseUrl: 'http://localhost:8080'))),
        
        // Datasources
        Provider(create: (context) => ProjectRemoteDataSource(
          context.read<Dio>(),
          'http://localhost:8080',
        )),
        
        // Providers/State
        ChangeNotifierProvider(create: (context) => ProjectProvider(
          context.read<ProjectRemoteDataSource>(),
        )),
      ],
      child: MaterialApp(
        title: 'Project Management',
        home: HomePage(),
      ),
    );
  }
}
```

---

## 📚 Recursos Adicionais

### Documentação

- [API Reference](docs/api-reference.md)
- [Database Schema](docs/database-schema.md)
- [UI Components](docs/ui-components.md)
- [State Management](docs/state-management.md)

### Exemplos

- [Criar Projeto Simples](examples/create-simple-project.md)
- [Expandir Projeto](examples/expand-project.md)
- [Criar Tarefa Recorrente](examples/create-recurring-task.md)

---

## 🏷️ Sistema de Tags (Categorização Global)

### Para Usuários

#### O que são Tags?

Tags são **etiquetas** que você pode adicionar a projetos e cadernos para organizá-los melhor. Diferente de categorias (que são específicas de um projeto), **tags são globais** - você pode usar as mesmas tags em diferentes projetos.

**Exemplo:**
```
📁 Projeto: Adequação Escola XYZ
   Tags: educação_especial, legislação, urgente

📓 Caderno: Resolução 45/2023
   Tags: educação_especial, legislação, sala_de_recurso

📁 Projeto: Formação de Professores  
   Tags: educação_especial, capacitação
```

Note que `educação_especial` e `legislação` são usadas em múltiplos lugares.

#### Como Usar Tags

**Modo Simples (Criação Automática):**

1. Ao criar/editar um projeto ou caderno
2. No campo "Tags", comece a digitar
3. Se a tag já existe, ela aparece como sugestão
4. Se não existe, basta pressionar Enter para criar
5. Pronto! A tag foi criada e adicionada

**Exemplo prático:**
```
Tags: [____________]
      ↓ digita "edu"
      
Tags: [edu________]
      ↓ sugestões aparecem
      
Sugestões:
✓ educação_especial (12 usos)
✓ educação_infantil (3 usos)

✨ Criar nova: "edu"
```

**Modo Avançado (Gerenciamento):**

Usuários avançados podem acessar **🏷️ Tags** no menu para:

- **Ver todas as tags** criadas no sistema
- **Renomear tags** (atualiza em todos os lugares)
- **Mesclar tags duplicadas** (ex: "educação" + "educacao" → "educação")
- **Ver onde cada tag é usada**
- **Deletar tags não usadas**
- **Ver estatísticas** (tags mais populares)

#### Diferença: Tags vs Categorias

| | Tags | Categorias |
|---|---|---|
| **Escopo** | Globais (todo o sistema) | Específicas de cada projeto |
| **Uso** | Projetos e Cadernos | Tarefas e Notebooks (dentro do projeto) |
| **Criação** | Automática ao digitar | Manual pelo usuário |
| **Exemplo** | "urgente", "legislação" | "Backend", "Frontend" (no projeto X) |

#### Boas Práticas

✅ **Use tags para temas gerais:** legislação, urgente, educação_especial  
✅ **Use categorias para organização interna do projeto:** backend, frontend, design  
✅ **Reutilize tags existentes:** O auto-complete ajuda a evitar duplicatas  
✅ **Use snake_case:** educação_especial (em vez de "Educação Especial")  
❌ **Evite criar muitas tags similares:** "educação", "educacao", "ed" são confusas

### Para Desenvolvedores - Sistema de Tags

#### Estrutura de Dados

Tags são armazenadas em tabela separada com relacionamento many-to-many:

```sql
-- Tabela global de tags
CREATE TABLE tags (
  id UUID PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL
);

-- Relacionamentos
CREATE TABLE notebook_tags (
  notebook_id UUID REFERENCES notebooks(id),
  tag_id UUID REFERENCES tags(id),
  PRIMARY KEY (notebook_id, tag_id)
);

CREATE TABLE project_tags (
  project_id UUID REFERENCES projects(id),
  tag_id UUID REFERENCES tags(id),
  PRIMARY KEY (project_id, tag_id)
);
```

#### API Principal

```dart
// Busca para auto-complete
GET /tags/search?query=edu  → Lista tags que começam com "edu"
GET /tags/popular?limit=10   → Tags mais usadas

// CRUD
POST /tags                   → Cria (ou retorna existente)
PUT /tags/{id}               → Renomeia
DELETE /tags/{id}            → Deleta (se usage_count = 0)

// Avançado  
POST /tags/{id}/merge?targetId=xyz  → Mescla duas tags
GET /tags/{id}/usage                → Onde a tag é usada
```

#### Client - Auto-complete

Use o pacote `flutter_typeahead` para criar input com sugestões:

```dart
TypeAheadField<Tag>(
  suggestionsCallback: (pattern) async {
    if (pattern.isEmpty) return await getPopularTags();
    return await searchTags(pattern);
  },
  onSuggestionSelected: (tag) {
    // Adiciona tag selecionada
  },
);
```

#### Fluxo de Criação Automática

1. Usuário digita "nova_tag" e pressiona Enter
2. Client chama `POST /tags` com `{name: "nova_tag"}`
3. Server verifica se já existe
   - Se existe: retorna a tag existente
   - Se não existe: cria e retorna
4. Client vincula tag ao notebook/project
5. Server incrementa `usage_count` automaticamente

#### Repository - Operações Importantes

```dart
// Busca com auto-complete
Future<List<Tag>> searchByPrefix(String prefix) async {
  return await _db.query('''
    SELECT * FROM tags 
    WHERE name ILIKE @prefix || '%'
    ORDER BY usage_count DESC
    LIMIT 20
  ''');
}

// Mesclar tags (exemplo: "educação" + "educacao" → "educação")
Future<void> merge(String sourceId, String targetId) async {
  // Move todos os vínculos de source para target
  // Deleta source
  // Recalcula usage_count de target
}

// Auto-incremento ao vincular
Future<void> linkToNotebook(String notebookId, String tagId) async {
  await _db.query('INSERT INTO notebook_tags ...');
  await _db.query('UPDATE tags SET usage_count = usage_count + 1 WHERE id = @tagId');
}
```

**Documentação completa da API e widgets disponível em:** `/docs/tags-api.md`

---

## 📎 Gestão de Documentos em Cadernos

### Para Usuários

#### O que são Cadernos com Documentos?

Cadernos permitem que você **faça resumos e anotações** sobre documentos importantes, e **mantenha os documentos organizados junto com suas notas**.

**Exemplo prático:**
- Você tem uma resolução governamental em PDF
- Em vez de só guardar o PDF, você cria um caderno
- No caderno, você escreve um resumo explicando o que a resolução diz
- Anexa o PDF original
- Adiciona tags para encontrar depois
- Pode vincular a um projeto se quiser

#### Tipos de Armazenamento

| Tipo | Descrição | Quando usar |
|------|-----------|-------------|
| **Servidor** | Arquivo enviado para nosso servidor | Quando você quer acessar de qualquer lugar/dispositivo |
| **Local** | Referência a arquivo no seu computador | Arquivo muito grande ou sensível que você não quer subir |
| **URL Externa** | Link para Google Drive, Dropbox, etc | Documento já está na nuvem em outro lugar |

#### Limites e Restrições

- **Tamanho máximo por arquivo:** 50 MB
- **Formatos aceitos:** PDF, DOC, DOCX, TXT, PNG, JPG, JPEG
- **Armazenamento total:** Ilimitado (por enquanto)

### Para Desenvolvedores

#### Fluxo de Upload de Documento

```
┌──────────────┐
│   Cliente    │
│   (Flutter)  │
└──────┬───────┘
       │ 1. Usuário seleciona arquivo
       │
       ▼
┌──────────────────────────────────────┐
│ FilePicker.pickFiles()               │
│ Obtém File object                    │
└──────┬───────────────────────────────┘
       │ 2. Converte para multipart/form-data
       │
       ▼
┌──────────────────────────────────────┐
│ POST /notebooks/{id}/documents       │
│ Headers: multipart/form-data         │
│ Body: arquivo binário                │
└──────┬───────────────────────────────┘
       │ 3. Servidor recebe
       │
       ▼
┌──────────────────────────────────────┐
│ NotebookController.uploadDocument()  │
│ - Valida tamanho                     │
│ - Gera ID único                      │
│ - Salva em /uploads/notebooks/{id}/  │
└──────┬───────────────────────────────┘
       │ 4. Cria registro no banco
       │
       ▼
┌──────────────────────────────────────┐
│ INSERT INTO document_references      │
│ (notebook_id, name, path, ...)       │
└──────┬───────────────────────────────┘
       │ 5. Retorna DocumentReference
       │
       ▼
┌──────────────────────────────────────┐
│ Cliente atualiza UI                  │
│ Mostra documento na lista            │
└──────────────────────────────────────┘
```

#### Estrutura de Armazenamento no Servidor

```
/uploads/
  └── notebooks/
      ├── {notebook_id_1}/
      │   ├── {file_id_1}_resolucao.pdf
      │   ├── {file_id_2}_parecer.docx
      │   └── {file_id_3}_imagem.png
      │
      ├── {notebook_id_2}/
      │   └── {file_id_4}_documento.pdf
      │
      └── ...
```

#### Client: Upload de Documento

```dart
// client/datasources/notebook_remote_datasource.dart

class NotebookRemoteDataSource {
  final Dio _dio;
  
  /// Upload de arquivo para o servidor
  Future<DocumentReference> uploadDocument({
    required String notebookId,
    required File file,
  }) async {
    final fileName = path.basename(file.path);
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    
    final response = await _dio.post(
      '/notebooks/$notebookId/documents',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
      onSendProgress: (sent, total) {
        print('Upload: ${(sent / total * 100).toStringAsFixed(0)}%');
      },
    );
    
    return DocumentReferenceModel.fromJson(response.data).toEntity();
  }
  
  /// Adiciona referência a documento externo
  Future<DocumentReference> addDocumentReference({
    required String notebookId,
    required String name,
    required String path,
    required DocumentStorageType storageType,
    String? mimeType,
  }) async {
    final response = await _dio.post(
      '/notebooks/$notebookId/documents/reference',
      data: {
        'name': name,
        'path': path,
        'storageType': storageType.name,
        if (mimeType != null) 'mimeType': mimeType,
      },
    );
    
    return DocumentReferenceModel.fromJson(response.data).toEntity();
  }
  
  /// Lista documentos de um caderno
  Future<List<DocumentReference>> getDocuments(String notebookId) async {
    final response = await _dio.get('/notebooks/$notebookId/documents');
    
    return (response.data as List)
      .map((json) => DocumentReferenceModel.fromJson(json).toEntity())
      .toList();
  }
  
  /// Baixa documento para arquivo temporário (para visualização)
  Future<String> downloadDocumentToTemp(String documentId) async {
    final response = await _dio.get(
      '/notebooks/{notebookId}/documents/$documentId/download',
      options: Options(responseType: ResponseType.bytes),
    );
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$documentId.pdf');
    await tempFile.writeAsBytes(response.data);
    
    return tempFile.path;
  }
  
  /// Faz download para pasta Downloads do usuário
  Future<String> downloadDocument({
    required String notebookId,
    required String documentId,
    required String fileName,
  }) async {
    final response = await _dio.get(
      '/notebooks/$notebookId/documents/$documentId/download',
      options: Options(responseType: ResponseType.bytes),
    );
    
    final downloadsDir = await getDownloadsDirectory();
    final file = File('${downloadsDir?.path}/$fileName');
    await file.writeAsBytes(response.data);
    
    return file.path;
  }
  
  /// Deleta documento
  Future<void> deleteDocument({
    required String notebookId,
    required String documentId,
  }) async {
    await _dio.delete('/notebooks/$notebookId/documents/$documentId');
  }
}
```

#### Server: Repository de Documentos

```dart
// server/repositories/document_repository.dart

class DocumentRepository {
  final Database _db;
  
  DocumentRepository(this._db);
  
  /// Cria nova referência de documento
  Future<void> create(String notebookId, DocumentReference document) async {
    await _db.query('''
      INSERT INTO document_references (
        id, notebook_id, name, path, storage_type, 
        mime_type, size_bytes, uploaded_at
      ) VALUES (
        @id, @notebookId, @name, @path, @storageType,
        @mimeType, @sizeBytes, @uploadedAt
      )
    ''', substitutionValues: {
      'id': document.id,
      'notebookId': notebookId,
      'name': document.name,
      'path': document.path,
      'storageType': document.storageType.name,
      'mimeType': document.mimeType,
      'sizeBytes': document.sizeBytes,
      'uploadedAt': document.uploadedAt,
    });
  }
  
  /// Busca documento por ID
  Future<DocumentReference?> findById(String id) async {
    final result = await _db.query(
      'SELECT * FROM document_references WHERE id = @id AND deleted_at IS NULL',
      substitutionValues: {'id': id},
    );
    
    if (result.isEmpty) return null;
    
    return DocumentReferenceDbModel.fromDb(result.first).toEntity();
  }
  
  /// Lista documentos de um caderno
  Future<List<DocumentReference>> findByNotebook(String notebookId) async {
    final result = await _db.query('''
      SELECT * FROM document_references 
      WHERE notebook_id = @notebookId AND deleted_at IS NULL
      ORDER BY uploaded_at DESC
    ''', substitutionValues: {'notebookId': notebookId});
    
    return result
      .map((row) => DocumentReferenceDbModel.fromDb(row).toEntity())
      .toList();
  }
  
  /// Deleta documento (soft delete)
  Future<void> delete(String id) async {
    await _db.query(
      'UPDATE document_references SET deleted_at = NOW() WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }
  
  /// Deleta fisicamente o arquivo do servidor
  Future<void> deletePhysicalFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

#### Dependências Necessárias

**Flutter (pubspec.yaml):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP e Upload
  dio: ^5.4.0
  
  # File Picker
  file_picker: ^6.1.1
  
  # PDF Viewer
  flutter_pdfview: ^1.3.2
  
  # Path manipulation
  path: ^1.8.3
  
  # Para obter diretórios do sistema
  path_provider: ^2.1.1
  
  # State management (exemplo com Provider)
  provider: ^6.1.1
```

**Server (pubspec.yaml):**
```yaml
dependencies:
  # Web framework
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  
  # Database
  postgres: ^3.0.0
  
  # MIME type detection
  mime: ^1.0.4
  
  # Path manipulation
  path: ^1.8.3
  
  # UUID generation
  uuid: ^4.2.2
```

#### Configuração de Permissões

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<manifest>
  <!-- Para acessar arquivos -->
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
  
  <!-- Para internet (upload/download) -->
  <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar suas fotos para anexar documentos</string>
<key>NSCameraUsageDescription</key>
<string>Precisamos acessar a câmera para tirar fotos de documentos</string>
```

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 💬 Suporte

Encontrou um bug ou tem uma sugestão?

- 🐛 [Reportar Bug](https://github.com/seu-repo/issues)
- 💡 [Sugerir Feature](https://github.com/seu-repo/issues)
- 📧 Email: suporte@seudominio.com

---

**Desenvolvido com ❤️ pela equipe de desenvolvimento**
