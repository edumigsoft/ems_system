# Plano: Compatibilidade Web para EMS System

## Resumo Executivo

O EMS System possui estrutura web (pasta `web/` nos apps) mas **não é compatível com web** devido a 5 bloqueadores críticos que causam crashes no navegador. Este plano implementa compatibilidade web completa usando o padrão de **imports condicionais** com implementações específicas por plataforma, mantendo a arquitetura existente de 4 variantes (_shared, _ui, _client, _server).

**Impacto:** Permitirá acesso ao sistema via navegador web (Chrome, Firefox, Safari, Edge) sem necessidade de instalar aplicativos nativos.

## Problemas Críticos Identificados

### 1. Core Logging (core_shared) - CRÍTICO
**Arquivo:** `packages/core/core_shared/lib/src/service/log_service.dart`

**Problemas:**
- Linha 1: `import 'dart:io';` - biblioteca não disponível na web
- Linhas 74-111: `_initializeLogFile()` usa File I/O (File, Directory, writeAsString)
- Linhas 138-150: `_getSystemDocumentsDirectory()` usa Platform.environment e Platform checks
- Crash imediato na web quando `writeToFile=true`

**Impacto:** App não inicia na web se logging com arquivo estiver habilitado.

### 2. Token Storage (auth_client) - SEGURANÇA CRÍTICA
**Arquivo:** `packages/auth/auth_client/lib/src/storage/token_storage.dart`

**Problemas:**
- Linha 2: Dependência direta de `flutter_secure_storage`
- Linha 16: Acoplamento concreto à implementação
- Web: fallback para localStorage **não criptografado** (tokens em texto plano)
- Linha 26: Comentário admite limitação de segurança na web

**Impacto:** Vulnerabilidade de segurança grave - tokens acessíveis via JavaScript no navegador.

### 3. Gerenciamento de Documentos (notebook_ui) - FUNCIONALIDADE
**Arquivo:** `packages/notebook/notebook_ui/lib/widgets/document_list_widget.dart`

**Problemas:**
- Linha 4: `import 'package:path_provider/path_provider.dart';`
- Linha 6: `import 'dart:io';`
- Linha 285: `getDownloadsDirectory()` - não existe na web
- Linhas 337-342: `Process.run('xdg-open' / 'open' / 'explorer')` - dart:io não funciona na web

**Impacto:** Download e abertura de arquivos completamente quebrados na web.

### 4. Upload de Documentos (notebook_ui) - UX
**Arquivo:** `packages/notebook/notebook_ui/lib/widgets/document_upload_widget.dart`

**Problemas:**
- Linhas 208-218: Mostra opção "Arquivo Local" (caminho no PC) que não funciona na web
- UI oferece funcionalidade impossível no navegador

**Impacto:** Usuários tentam usar feature quebrada, experiência ruim.

### 5. Visualizador PDF (notebook_ui) - FUNCIONALIDADE
**Arquivo:** `packages/notebook/notebook_ui/lib/widgets/pdf_viewer_page.dart`

**Problemas:**
- Linha 39 do pubspec: `pdfx: ^2.7.0` com suporte web limitado
- Renderização de PDFs pode falhar ou não carregar corretamente

**Impacto:** PDFs não visualizam na web.

## Arquitetura da Solução

### Padrão: Imports Condicionais com Interface de Abstração

```
lib/src/platform/
├── service.dart                    # Export com conditional imports
├── service_interface.dart          # Interface abstrata (contrato)
├── service_io.dart                 # Implementação mobile/desktop (dart:io)
└── service_web.dart                # Implementação web (dart:html)
```

**Vantagens:**
- Zero overhead em runtime (resolução em compile-time)
- Type-safe
- Mantém arquitetura limpa
- Segue convenções do projeto

### Injeção de Dependências (DI)

Usar GetIt (já em uso no projeto) para registrar implementações por plataforma:

```dart
// No main.dart de cada app
import 'package:flutter/foundation.dart' show kIsWeb;

void setupDI() {
  if (kIsWeb) {
    getIt.registerSingleton<SecureStorage>(SecureStorageWeb());
  } else {
    getIt.registerSingleton<SecureStorage>(SecureStorageNative());
  }
}
```

## Implementação por Fase

### FASE 1: Infraestrutura Core (2-3 dias)

#### 1.1. Criar Serviço de Detecção de Capacidades

**Novo pacote:** `packages/core/core_shared/lib/src/platform/`

**Arquivos:**
```
platform_capabilities.dart           # Export
platform_capabilities_interface.dart # Interface
platform_capabilities_io.dart        # Native
platform_capabilities_web.dart       # Web
```

**Interface:**
```dart
abstract class PlatformCapabilities {
  bool get supportsFileSystem;
  bool get supportsSecureStorage;
  bool get supportsProcessExecution;
  bool get supportsDownloadDirectory;
  bool get isWeb;
  bool get isMobile;
  bool get isDesktop;
}
```

**Uso:** Todos os serviços consultam este para verificar capacidades disponíveis.

#### 1.2. Refatorar LogService

**Modificar:** `packages/core/core_shared/lib/src/service/log_service.dart`

**Estratégia:**
1. Criar abstração `LogWriter` com implementações por plataforma
2. Remover `import 'dart:io';` do arquivo principal
3. Isolar file I/O em `LogWriterIO`
4. Criar `LogWriterWeb` usando console.log + IndexedDB opcional

**Nova estrutura:**
```
lib/src/service/log_writer/
├── log_writer.dart           # Export com conditional import
├── log_writer_interface.dart # Interface
├── log_writer_io.dart        # File-based logging
└── log_writer_web.dart       # Console + IndexedDB
```

**API modificada:**
```dart
static Future<void> init(
  LogLevel minLevel, {
  void Function(String, dynamic, StackTrace?)? auditHandler,
  LogWriter? logWriter, // NOVO: injetar implementação
}) async {
  _logWriter = logWriter ?? LogWriterConsole(); // Default seguro
  // ...
}
```

**Linhas afetadas:** 1-2 (imports), 40 (field), 55-111 (file ops), 138-161 (platform checks)

---

### FASE 2: Armazenamento Seguro (3-4 dias)

#### 2.1. Criar Abstração SecureStorage

**Novo pacote:** `packages/core/core_client/lib/src/storage/`

**Arquivos:**
```
secure_storage.dart           # Export com conditional import
secure_storage_interface.dart # Interface
secure_storage_native.dart    # Wrapper flutter_secure_storage
secure_storage_web.dart       # IndexedDB + Web Crypto API
```

**Por que core_client?**
- Infraestrutura usada por múltiplas features (auth, user settings)
- Segue padrão existente (BaseRepository em core_client)
- Evita dependências circulares

**Interface:**
```dart
abstract class SecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<Map<String, String>> readAll();
}
```

**Implementação Web (RECOMENDADA):**
```dart
class SecureStorageWeb implements SecureStorage {
  // - Usa IndexedDB para persistência
  // - Criptografa com Web Crypto API (SubtleCrypto)
  // - Chave derivada da sessão (não persistente entre tabs)
  // - Dados criptografados antes de storage
  // - Limpa automaticamente no logout
}
```

**Segurança Web:**
- **NUNCA** alcançará segurança nativa (keychain/keystore)
- IndexedDB + Web Crypto = melhor disponível na web
- Sessão única (não compartilha entre tabs)
- Timeout mais agressivo recomendado
- **Exibir aviso de segurança ao usuário**

**Dependências novas:**
```yaml
# packages/core/core_client/pubspec.yaml
dependencies:
  crypto: ^3.0.3  # Web Crypto API
```

#### 2.2. Refatorar TokenStorage

**Modificar:** `packages/auth/auth_client/lib/src/storage/token_storage.dart`

**Mudanças:**
1. Remover dependência direta de `flutter_secure_storage`
2. Injetar `SecureStorage` via construtor
3. Atualizar DI em auth_client module

**Código:**
```dart
class TokenStorage {
  final SecureStorage _storage;

  TokenStorage(this._storage); // Injetar interface

  // Resto do código permanece igual
}
```

**Linhas afetadas:** 1-2 (imports), 16-28 (construtor e field), todos os usos de `_storage`

#### 2.3. Refatorar SettingsStorage

**Modificar:** `packages/user/user_client/lib/src/storage/settings_storage.dart`

**Mudanças:** Mesmo padrão do TokenStorage

**Linhas afetadas:** 11, 20-30, todos os usos de `_storage`

#### 2.4. Atualizar Registro DI nos Apps

**Modificar:** `apps/*/app_v1/lib/main.dart` (cada app)

**Adicionar:**
```dart
import 'package:core_client/core_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void setupDependencies() {
  if (kIsWeb) {
    getIt.registerSingleton<SecureStorage>(
      SecureStorageWeb(),
    );
  } else {
    getIt.registerSingleton<SecureStorage>(
      SecureStorageNative(
        const FlutterSecureStorage(/* opções nativas */),
      ),
    );
  }

  // Registrar outros serviços...
}
```

---

### FASE 3: Operações de Arquivo (2-3 dias)

#### 3.1. Criar Serviço FileOperations

**Novo pacote:** `packages/core/core_client/lib/src/services/file_operations/`

**Arquivos:**
```
file_operations.dart           # Export
file_operations_interface.dart # Interface
file_operations_native.dart    # File system nativo
file_operations_web.dart       # Web downloads
```

**Interface:**
```dart
abstract class FileOperations {
  /// Download arquivo de URL
  Future<Result<DownloadResult>> downloadFile({
    required String url,
    required String filename,
  });

  /// Abrir gerenciador de arquivos (apenas nativo)
  Future<Result<Unit>> openFileLocation(String path);

  /// Obter diretório de downloads (apenas nativo)
  Future<Result<Directory?>> getDownloadsDirectory();

  /// Verificar suporte
  bool get supportsFileManager;
  bool get supportsDownloadDirectory;
}
```

**Implementação Web:**
```dart
class FileOperationsWeb implements FileOperations {
  @override
  Future<Result<DownloadResult>> downloadFile({
    required String url,
    required String filename,
  }) async {
    // 1. Baixar bytes com Dio
    final bytes = await _fetchBytes(url);

    // 2. Criar Blob URL
    final blob = Blob([bytes]);
    final blobUrl = Url.createObjectUrlFromBlob(blob);

    // 3. Criar elemento <a> e disparar download
    final anchor = AnchorElement(href: blobUrl)
      ..setAttribute('download', filename)
      ..click();

    // 4. Limpar blob URL
    Url.revokeObjectUrl(blobUrl);

    return Success(DownloadResult.web(filename));
  }

  @override
  bool get supportsFileManager => false;

  @override
  bool get supportsDownloadDirectory => false;

  // openFileLocation e getDownloadsDirectory lançam UnsupportedError
}
```

#### 3.2. Refatorar DocumentListWidget

**Modificar:** `packages/notebook/notebook_ui/lib/widgets/document_list_widget.dart`

**Mudanças:**

1. **Remover imports diretos:**
   - Linha 4: Remover `import 'package:path_provider/path_provider.dart';`
   - Linha 6: Remover `import 'dart:io';`

2. **Adicionar injeção de dependência:**
```dart
class DocumentListWidget extends StatelessWidget {
  final List<DocumentReferenceDetails> documents;
  final void Function(String documentId)? onDelete;
  final FileOperations fileOperations; // NOVO

  const DocumentListWidget({
    super.key,
    required this.documents,
    required this.fileOperations, // NOVO
    this.onDelete,
  });
}
```

3. **Refatorar _downloadDocument (linhas 262-331):**
```dart
Future<void> _downloadDocument(BuildContext context) async {
  // Mostrar loading...

  final result = await widget.fileOperations.downloadFile(
    url: document.path,
    filename: document.name,
  );

  result.when(
    success: (downloadResult) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download concluído: ${document.name}'),
          // Só mostrar "Abrir pasta" se suportado
          action: widget.fileOperations.supportsFileManager
              ? SnackBarAction(
                  label: 'Abrir pasta',
                  onPressed: () => _openFileLocation(downloadResult.path),
                )
              : null,
        ),
      );
    },
    failure: (error) {
      // Mostrar erro...
    },
  );
}
```

4. **Refatorar _openFileLocation (linhas 333-347):**
```dart
Future<void> _openFileLocation(String path) async {
  if (!widget.fileOperations.supportsFileManager) {
    return; // Silenciosamente ignorar na web
  }

  final result = await widget.fileOperations.openFileLocation(path);
  // Tratar resultado...
}
```

**Linhas afetadas:** 4, 6, 10-18 (construtor), 262-347 (métodos)

#### 3.3. Refatorar DocumentUploadWidget

**Modificar:** `packages/notebook/notebook_ui/lib/widgets/document_upload_widget.dart`

**Mudanças:**

1. **Ocultar opção "Arquivo Local" na web (linhas 208-218):**
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// ...

if (_selectedType == null) ...[
  _TypeButton(
    icon: Icons.upload_file,
    label: 'Enviar Arquivo',
    description: 'Do seu dispositivo',
    onPressed: widget.enabled ? () => setState(...) : null,
  ),
  const SizedBox(height: 8),
  _TypeButton(
    icon: Icons.link,
    label: 'Adicionar Link',
    description: 'URL externa',
    onPressed: widget.enabled ? () => setState(...) : null,
  ),

  // Só mostrar "Arquivo Local" em plataformas nativas
  if (!kIsWeb) ...[  // NOVO
    const SizedBox(height: 8),
    _TypeButton(
      icon: Icons.folder,
      label: 'Arquivo Local',
      description: 'Caminho no seu PC',
      onPressed: widget.enabled ? () => setState(...) : null,
    ),
  ],
],
```

**Linhas afetadas:** 1 (adicionar import), 208-218 (conditional rendering)

---

### FASE 4: Visualizador PDF (2-3 dias)

#### 4.1. Substituir Pacote pdfx

**Opções avaliadas:**
- ❌ `pdfx: ^2.7.0` - suporte web limitado (atual)
- ✅ `flutter_pdfview: ^1.3.2` (nativo) + `pdf_js: ^0.1.0` (web) - RECOMENDADO

**Estratégia:** Implementações separadas por plataforma usando conditional imports.

#### 4.2. Criar PDF Viewer com Suporte Multiplataforma

**Modificar estrutura:** `packages/notebook/notebook_ui/lib/widgets/pdf_viewer/`

**Arquivos:**
```
pdf_viewer_page.dart      # Entry point agnóstico
pdf_viewer_native.dart    # Implementação flutter_pdfview
pdf_viewer_web.dart       # Implementação pdf_js
```

**Entry point:**
```dart
// pdf_viewer_page.dart
import 'pdf_viewer_native.dart'
  if (dart.library.html) 'pdf_viewer_web.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String documentName;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.documentName,
  });

  @override
  Widget build(BuildContext context) {
    return PdfViewerImplementation(
      url: url,
      documentName: documentName,
    );
  }
}
```

**Implementação nativa:**
```dart
// pdf_viewer_native.dart
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerImplementation extends StatelessWidget {
  // Usa flutter_pdfview
}
```

**Implementação web:**
```dart
// pdf_viewer_web.dart
import 'package:pdf_js/pdf_js.dart';

class PdfViewerImplementation extends StatelessWidget {
  // Usa pdf_js (wrapper do PDF.js do Mozilla)
}
```

#### 4.3. Atualizar pubspec.yaml

**Modificar:** `packages/notebook/notebook_ui/pubspec.yaml`

**Linha 39 - Remover:**
```yaml
pdfx: ^2.7.0
```

**Adicionar:**
```yaml
flutter_pdfview: ^1.3.2  # Para Android/iOS/Desktop
pdf_js: ^0.1.0           # Para Web
```

**Linha 40 - Remover:**
```yaml
permission_handler: ^11.3.0  # Não suportado na web
```

**Linha 38 - Manter mas usar condicionalmente:**
```yaml
path_provider: ^2.1.2  # Usado apenas em código nativo
```

---

### FASE 5: Atualização de Dependências (1 dia)

#### 5.1. Adicionar Dependências Web

**Modificar:** `packages/core/core_client/pubspec.yaml`

```yaml
dependencies:
  # Existentes...

  # NOVO: Para implementação web de SecureStorage
  crypto: ^3.0.3  # Web Crypto API
```

#### 5.2. Verificar Compatibilidade

**Ação:** Executar em todos os pacotes:
```bash
flutter pub get
dart analyze
```

---

### FASE 6: Documentação e Testes (3-4 dias)

#### 6.1. Criar ADR de Padrão de Abstração

**Novo arquivo:** `docs/adr/0007-platform-abstraction-pattern.md`

**Conteúdo:**
- Decisão de usar conditional imports
- Justificativa vs feature flags
- Padrão de interface + implementações
- Considerações de segurança web
- Exemplos de uso

#### 6.2. Criar Widget de Aviso de Segurança Web

**Novo arquivo:** `packages/core/core_ui/lib/widgets/platform_notice_widget.dart`

**Propósito:** Informar usuários sobre limitações de segurança na web

**Uso:**
```dart
// Na tela de login
if (kIsWeb) {
  PlatformNoticeWidget(
    type: NoticeType.securityWarning,
    message: 'Versão web usa armazenamento de sessão. '
             'Para melhor segurança, use nossos apps desktop ou mobile.',
  )
}
```

#### 6.3. Atualizar READMEs

**Arquivos a atualizar:**

1. **packages/core/core_shared/README.md**
   - Documentar PlatformCapabilities
   - Documentar LogWriter abstraction
   - Explicar limitações web

2. **packages/core/core_client/README.md**
   - Documentar SecureStorage interface
   - Documentar FileOperations service
   - **AVISO DE SEGURANÇA** para web

3. **packages/auth/auth_client/README.md**
   - Aviso de segurança web
   - Comportamento de sessão diferente

4. **packages/notebook/notebook_ui/README.md**
   - Documentar limitações web
   - Features específicas por plataforma

#### 6.4. Estratégia de Testes

**Testes Unitários:**

1. Cada implementação de plataforma (mock capabilities)
2. Interfaces implementadas corretamente
3. Error handling para operações não suportadas
4. Degradação graciosa

**Testes de Integração:**

1. **Web-specific:**
   - Download via blob funciona
   - SecureStorage persiste na sessão
   - PDF viewer renderiza
   - UI oculta features não suportadas

2. **Cross-platform:**
   - Build compila para todas as plataformas
   - DI funciona corretamente
   - Fallbacks ativam quando necessário

**Checklist de Teste Manual:**
- [ ] `flutter build web` completa sem erros
- [ ] App inicia no Chrome sem crashes
- [ ] Login/logout funciona
- [ ] Tokens persistem no refresh (dentro da sessão)
- [ ] Download de documentos funciona (download do navegador)
- [ ] Upload de documentos funciona
- [ ] PDF viewer funciona
- [ ] Opção "Arquivo Local" oculta na web
- [ ] Botão "Abrir pasta" oculto na web
- [ ] Sem erros dart:io no console do navegador
- [ ] Aviso de segurança aparece na web

---

## Ordem de Implementação (OBRIGATÓRIA)

**CRITICAL PATH (sequencial):**

```
1. PlatformCapabilities (FASE 1.1)
   ↓
2. LogService Refactoring (FASE 1.2)
   ↓  [Remove dart:io de core_shared - BLOQUEADOR]
3. SecureStorage Abstraction (FASE 2.1-2.4)
   ↓  [Remove acoplamento flutter_secure_storage]
4. FileOperations Service (FASE 3.1)
   ↓  [Remove acoplamento path_provider]
5. Widget Refactoring (FASE 3.2-3.3)
   ↓  [Usa novos serviços]
6. PDF Viewer Replacement (FASE 4.1-4.3)
   ↓  [Independente mas precisa FileOperations]
7. Testing & Docs (FASE 6)
```

**Tracks Paralelos:**
- **Track A:** FASES 1-5 (core) - DEVE ser sequencial
- **Track B:** FASE 4 (PDF) - Pode começar após FASE 3
- **Track C:** FASE 6 (docs) - Pode ocorrer em paralelo

**Não prosseguir para próxima fase sem:**
- ✅ `dart analyze` → 0 errors, 0 warnings
- ✅ Testes unitários passando
- ✅ Build compila para native E web

---

## Arquivos Críticos (Mapa de Mudanças)

### Modificações em Arquivos Existentes

| Arquivo | Localização | Mudanças Principais | Linhas Afetadas |
|---------|-------------|---------------------|-----------------|
| **log_service.dart** | `packages/core/core_shared/lib/src/service/` | Remover dart:io, injetar LogWriter | 1-2, 40, 55-111, 138-161 |
| **token_storage.dart** | `packages/auth/auth_client/lib/src/storage/` | Injetar SecureStorage interface | 1-2, 16-28, todos os usos |
| **settings_storage.dart** | `packages/user/user_client/lib/src/storage/` | Injetar SecureStorage interface | 11, 20-30, todos os usos |
| **document_list_widget.dart** | `packages/notebook/notebook_ui/lib/widgets/` | Injetar FileOperations, remover dart:io | 4, 6, 10-18, 262-347 |
| **document_upload_widget.dart** | `packages/notebook/notebook_ui/lib/widgets/` | Conditional rendering (!kIsWeb) | 1, 208-218 |
| **pdf_viewer_page.dart** | `packages/notebook/notebook_ui/lib/widgets/` | Reestruturar com conditional imports | Arquivo completo |
| **notebook_ui/pubspec.yaml** | `packages/notebook/notebook_ui/` | Substituir pdfx, remover permission_handler | 38-40 |
| **core_client/pubspec.yaml** | `packages/core/core_client/` | Adicionar crypto: ^3.0.3 | dependencies |
| **main.dart** | `apps/*/app_v1/lib/` | Adicionar DI para SecureStorage | Função setupDependencies |

### Novos Arquivos a Criar

**FASE 1:**
- `packages/core/core_shared/lib/src/platform/platform_capabilities.dart` (export)
- `packages/core/core_shared/lib/src/platform/platform_capabilities_interface.dart`
- `packages/core/core_shared/lib/src/platform/platform_capabilities_io.dart`
- `packages/core/core_shared/lib/src/platform/platform_capabilities_web.dart`
- `packages/core/core_shared/lib/src/service/log_writer/log_writer.dart` (export)
- `packages/core/core_shared/lib/src/service/log_writer/log_writer_interface.dart`
- `packages/core/core_shared/lib/src/service/log_writer/log_writer_io.dart`
- `packages/core/core_shared/lib/src/service/log_writer/log_writer_web.dart`

**FASE 2:**
- `packages/core/core_client/lib/src/storage/secure_storage.dart` (export)
- `packages/core/core_client/lib/src/storage/secure_storage_interface.dart`
- `packages/core/core_client/lib/src/storage/secure_storage_native.dart`
- `packages/core/core_client/lib/src/storage/secure_storage_web.dart`

**FASE 3:**
- `packages/core/core_client/lib/src/services/file_operations/file_operations.dart` (export)
- `packages/core/core_client/lib/src/services/file_operations/file_operations_interface.dart`
- `packages/core/core_client/lib/src/services/file_operations/file_operations_native.dart`
- `packages/core/core_client/lib/src/services/file_operations/file_operations_web.dart`

**FASE 4:**
- `packages/notebook/notebook_ui/lib/widgets/pdf_viewer/pdf_viewer_page.dart` (novo entry point)
- `packages/notebook/notebook_ui/lib/widgets/pdf_viewer/pdf_viewer_native.dart`
- `packages/notebook/notebook_ui/lib/widgets/pdf_viewer/pdf_viewer_web.dart`

**FASE 6:**
- `packages/core/core_ui/lib/widgets/platform_notice_widget.dart`
- `docs/adr/0007-platform-abstraction-pattern.md`

---

## Mitigação de Riscos

### Risco 1: Breaking Changes no Código Existente
**Mitigação:**
- Usar abstração de interfaces (API compatível)
- Injeção de dependências (não quebra construtores)
- Factory constructors para backward compatibility
- Deprecation warnings para migração gradual

### Risco 2: Preocupações de Segurança Web
**Mitigação:**
- Documentar limitações claramente
- Exibir avisos aos usuários na web
- Implementar melhor segurança disponível (Web Crypto + IndexedDB)
- Timeout de sessão mais agressivo na web
- Links para download de apps nativos

### Risco 3: Compatibilidade do Pacote PDF
**Mitigação:**
- Testar pacotes de substituição antes de commitar
- Manter pdfx como fallback durante transição
- Criar camada de abstração para trocar implementações facilmente
- Testar com vários PDFs (tamanho, complexidade)

### Risco 4: Edge Cases de Detecção de Plataforma
**Mitigação:**
- Usar conditional imports (compile-time, zero overhead)
- Testar em todas as plataformas (web, mobile, desktop)
- Ter comportamentos de fallback para todas as operações
- Usar detecção de capacidades ao invés de plataforma

---

## Critérios de Sucesso (Definition of Done)

### DoD por Fase:

**Cada fase deve atingir:**
- ✅ `dart analyze` → 0 errors, 0 warnings
- ✅ `flutter test` → todos os testes passando
- ✅ Code review aprovado
- ✅ Documentação atualizada

### DoD Completo do Projeto:

1. ✅ `flutter build web` completa sem erros para todos os apps
2. ✅ `flutter run -d chrome` inicia apps com sucesso
3. ✅ Todos os checks de análise passam (0 errors, 0 warnings)
4. ✅ Sem imports dart:io em code paths executados na web
5. ✅ Autenticação com token funciona na web (login/logout)
6. ✅ Upload/download de documentos funciona na web
7. ✅ Visualização de PDF funciona na web
8. ✅ UI oculta graciosamente features não suportadas na web
9. ✅ Avisos de segurança aparecem para usuários web
10. ✅ Todos os testes unitários passam para native E web
11. ✅ Documentação atualizada com notas de compatibilidade web
12. ✅ ADR criado para padrão de abstração de plataforma

### Validação Pós-Implementação:

- Executar suite completa de testes no target web
- Testes cross-browser (Chrome, Firefox, Safari, Edge)
- Testes de performance (tempo de carregamento, uso de memória)
- Auditoria de segurança da implementação de storage web
- User acceptance testing com workflows reais

---

## Estimativa de Tempo

**Por Fase:**
- FASE 1 (Core Infrastructure): 2-3 dias
- FASE 2 (Secure Storage): 3-4 dias
- FASE 3 (Document Management): 2-3 dias
- FASE 4 (PDF Viewer): 2-3 dias
- FASE 5 (Dependencies): 1 dia
- FASE 6 (Docs & Testing): 3-4 dias

**Total:** 13-18 dias (1 desenvolvedor full-time)

**Critical Path:** 11-15 dias (fases sequenciais)

---

## Notas de Segurança Web

### ⚠️ AVISO IMPORTANTE

**Armazenamento na Web NÃO é tão seguro quanto nativo:**

- **Nativo:** Keychain (iOS), Keystore (Android), Credential Manager (Windows/Linux)
- **Web:** IndexedDB + Web Crypto API (melhor disponível, mas ainda vulnerável)

**Limitações Web:**
- JavaScript no navegador pode acessar storage
- Extensions maliciosas podem interceptar
- XSS vulnerabilities expõem dados
- Não há isolamento de hardware

**Mitigações Implementadas:**
1. IndexedDB com Web Crypto API (criptografia)
2. Chave de sessão (não persiste entre tabs)
3. Limpeza automática no logout
4. Timeout de sessão agressivo
5. **Aviso explícito ao usuário**

**Recomendação:** Para dados sensíveis, recomendar apps nativos aos usuários.
