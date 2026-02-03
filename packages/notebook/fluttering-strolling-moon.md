# Plano: Notebook Mobile-Ready

## Contexto

O pacote `packages/notebook/` implementa a feature completa (4/4 variantes) mas possui **5 bugs bloqueadores para mobile** e diversas lacunas de UX. Este plano corrige os bugs na ordem correta e aplica as melhorias necessárias, sem alterações no `notebook_shared` ou `notebook_client` (não são necessárias).

---

## Bugs Identificados (priorizados)

| # | Bug | Arquivo : Linha | Severidade |
|---|-----|-----------------|------------|
| 1 | Server armazena caminho absoluto no DB; não há endpoint para baixar o arquivo | `notebook_routes.dart:598`, sem rota GET de download | Bloqueador — upload funciona mas arquivo é inacessível pelo cliente |
| 2 | `uploadDocument()` cria `Dio()` sem base URL nem token de auth | `notebook_detail_view_model.dart:386` | Bloqueador — upload sempre falha |
| 3 | `PdfViewerPage` cria `Dio()` sem auth; usa `document.path` como URL | `pdf_viewer_page.dart:72` | Bloqueador — PDF nunca carrega após fix do Bug 1 |
| 4 | Download usa `getDownloadsDirectory()` (null no Android); `Process.run` não funciona no mobile; `Dio()` sem auth | `document_list_widget.dart:285,294,337` | Bloqueador no mobile |
| 5 | Opção "Arquivo Local" pede ao usuário para digitar caminho no filesystem — sem sentido no mobile | `document_upload_widget.dart:209` | UX quebrada no mobile |

---

## Pacotes Recomendados

### Já presentes (manter, não adicionar nada)
| Pacote | Uso atual | Papel no plano |
|--------|-----------|----------------|
| `pdfx: ^2.7.0` | PDF viewer | Mantém — boa performance no mobile com pinch-to-zoom |
| `file_picker: ^6.1.1` | Selecionar arquivos | Mantém — retorna `path` no mobile (não `bytes`) |
| `permission_handler: ^11.3.0` | Permissões | Presente mas **nunca chamado** — será usado no download |
| `path_provider: ^2.1.2` | Diretórios do app | Usado para cache local de PDFs e imagens |
| `url_launcher: ^6.2.5` | Abrir URLs/arquivos | Usado para abrir arquivo baixado no viewer nativo |
| `dio: ^5.9.0` | HTTP com interceptores | O singleton já configurado com base URL + auth |

### Não são necessários pacotes novos
- **`cached_network_image`** — fora do cogitado. O token de auth é gerenciado pelo `AuthInterceptor` no Dio e pode ser renovado a qualquer momento. `CachedNetworkImage` faz requests HTTP próprios (sem Dio), e hardcoding de token nos `headers` quebra após refresh. A solução correta é baixar via Dio e cachear manualmente com `path_provider`, que é consistente com a abordagem do PDF cache abaixo.
- **`flutter_caching_manager`** — não necessário. Cache manual com `getApplicationCacheDirectory()` + Dio é suficiente para PDFs e thumbnails de imagem.

---

## Arquivos a Modificar (7 arquivos, 0 em `_shared` ou `_client`)

```
packages/notebook/
├── notebook_server/lib/src/routes/
│   └── notebook_routes.dart              ← Bug 1: caminho relativo + endpoint download
└── notebook_ui/lib/
    ├── notebook_module.dart              ← Injetar Dio no ViewModel
    ├── view_models/
    │   └── notebook_detail_view_model.dart ← Bug 2: usar Dio injetado + helpers
    ├── pages/
    │   └── notebook_detail_page.dart     ← Passar dio/notebookId aos widgets
    └── widgets/
        ├── pdf_viewer_page.dart          ← Bug 3: auth + cache local
        ├── document_list_widget.dart     ← Bug 4: download mobile + thumbnails cachados
        └── document_upload_widget.dart   ← Bug 5: esconder "Local Path" no mobile
```

---

## Implementação Detalhada

### 1. `notebook_routes.dart` — Server

**1A. Armazenar nome relativo, não caminho absoluto (Bug 1)**

Linha 598 atual:
```dart
path: savedFilePath,   // savedFilePath = p.join(_uploadsPath, uniqueFileName) — absoluto
```
Mudar para:
```dart
path: uniqueFileName,  // só o nome do arquivo; server reconstrói o path no download
```
`uniqueFileName` já existe na linha 566. `savedFilePath` continua sendo usado na linha 570 para escrever no disco — não muda. Apenas o que vai para o banco muda.

> **Nota migração:** Linhas existentes no DB com path absoluto não serão afetadas automaticamente. Um script de migração (fora do scope deste plano) pode ser feito para extrair apenas o basename das linhas antigas.

**1B. Adicionar endpoint `GET /<id>/documents/<docId>/download`**

Adicionar no `router` getter (após a rota de upload, linha 131):
```dart
router.get(
  '/<id>/documents/<docId>/download',
  Pipeline()
      .addMiddleware(authedMiddleware)
      .addHandler(
        (req) => _downloadDocument(req, req.params['id']!, req.params['docId']!),
      ),
);
```

Novo handler na classe:
```dart
Future<Response> _downloadDocument(Request request, String id, String docId) async {
  final authContext = request.context['authContext'] as AuthContext?;
  if (authContext == null) {
    return Response.forbidden(
      jsonEncode({'error': 'Authentication required'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final result = await documentRepository.getById(docId);

  return result.when(
    success: (document) async {
      if (document.notebookId != id) {
        return Response.notFound(
          jsonEncode({'error': 'Document not found in this notebook'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (document.storageType != DocumentStorageType.server) {
        return Response(400,
          body: jsonEncode({'error': 'Document is not server-hosted'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final filePath = p.join(_uploadsPath, document.path);
      final file = File(filePath);
      if (!await file.exists()) {
        return Response.notFound(
          jsonEncode({'error': 'File not found on disk'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final bytes = await file.readAsBytes();
      return Response.ok(bytes, headers: {
        'Content-Type': document.mimeType ?? 'application/octet-stream',
        'Content-Disposition': 'attachment; filename="${document.name}"',
        'Content-Length': bytes.length.toString(),
      });
    },
    failure: (_) => Response.notFound(
      jsonEncode({'error': 'Document not found'}),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
```

`Response.ok` aceita `List<int>` como body natively no Shelf. O check `notebookId != id` previne acesso cruzado entre notebooks.

---

### 2. `notebook_detail_view_model.dart` — ViewModel hub

**2A. Injetar Dio no construtor (Bug 2)**

```dart
final Dio _dio;   // ← novo campo

NotebookDetailViewModel({
  required NotebookApiService notebookService,
  required DocumentReferenceApiService documentService,
  required TagApiService tagService,
  required Dio dio,            // ← novo parâmetro
}) : _notebookService = notebookService,
     _documentService = documentService,
     _tagService = tagService,
     _dio = dio;               // ← novo
```

**2B. Usar `_dio` no `uploadDocument()` (linha 386-387)**

Trocar:
```dart
final dio = Dio();
final response = await dio.post<Map<String, dynamic>>(
```
Por:
```dart
final response = await _dio.post<Map<String, dynamic>>(
```
O resto do método (`FormData`, `onSendProgress`, parsing da resposta) não muda.

**2C. Expor `dio` como getter público**

```dart
/// Dio configurado com base URL e interceptores de auth.
/// Exposto para widgets que precisam fazer downloads autenticados.
Dio get dio => _dio;
```

**2D. Método helper para construir URL de download**

```dart
/// URL relativa para download de documento no servidor.
/// Retorna null se o documento não for server-hosted ou notebook não carregado.
String? getDocumentDownloadUrl(DocumentReferenceDetails document) {
  if (_notebook == null) return null;
  if (document.storageType != DocumentStorageType.server) return null;
  return '/notebooks/${_notebook!.id}/documents/${document.id}/download';
}
```

---

### 3. `notebook_module.dart` — DI wiring

Adicionar `dio` na factory do ViewModel (linha 48-53):
```dart
di.registerFactory<NotebookDetailViewModel>(
  () => NotebookDetailViewModel(
    notebookService: di.get<NotebookApiService>(),
    documentService: di.get<DocumentReferenceApiService>(),
    tagService: di.get<TagApiService>(),
    dio: di.get<Dio>(),    // ← novo: mesmo Dio usado pelos ApiServices
  ),
);
```
`di.get<Dio>()` já é usado na mesma classe nas linhas 33 e 37. Sem nova regist registração necessária.

---

### 4. `pdf_viewer_page.dart` — PDF com auth + cache (Bug 3)

**Novo construtor:**
```dart
class PdfViewerPage extends StatefulWidget {
  final DocumentReferenceDetails document;
  final Dio dio;
  final String notebookId;

  const PdfViewerPage({
    super.key,
    required this.document,
    required this.dio,
    required this.notebookId,
  });
```

**Reescrever `_downloadPdf` com cache:**
```dart
Future<Uint8List> _downloadPdf() async {
  final cacheDir = await getApplicationCacheDirectory();
  final cacheFile = File('${cacheDir.path}/pdf_cache_${widget.document.id}.pdf');

  // Retorna cache se existir
  if (await cacheFile.exists()) {
    return await cacheFile.readAsBytes();
  }

  // Download autenticado via Dio singleton
  final url = '/notebooks/${widget.notebookId}/documents/${widget.document.id}/download';
  final response = await widget.dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );
  final bytes = Uint8List.fromList(response.data!);

  // Salva no cache para acessos futuros
  await cacheFile.writeAsBytes(bytes);
  return bytes;
}
```

Atualizar `_initializePdfController` para chamar `_downloadPdf()` (sem argumento). Atualizar AppBar title para `widget.document.name`.

Adicionar imports necessários: `dart:io`, `path_provider`.

---

### 5. `document_list_widget.dart` — Download + thumbnails no mobile (Bug 4)

**5A. Adicionar `dio` e `notebookId` aos widgets**

```dart
class DocumentListWidget extends StatelessWidget {
  final List<DocumentReferenceDetails> documents;
  final void Function(String documentId)? onDelete;
  final Dio dio;              // ← novo
  final String notebookId;   // ← novo
```

Passar para `_DocumentItem`:
```dart
_DocumentItem(
  document: doc,
  onDelete: onDelete != null ? () => onDelete!(doc.id) : null,
  dio: dio,
  notebookId: notebookId,
)
```

`_DocumentItem` recebe os mesmos dois campos novos.

**5B. Reescrever `_downloadDocument`**

Lógica mobile-correta:
- **Permissão:** Usar `getApplicationDocumentsDirectory()` no mobile — está dentro do sandbox do app, **não precisa de permissão external storage**. Permissão só seria necessária para escrever na pasta Downloads externa, que não vale a pena no mobile (padrão moderno é salvar no sandbox e abrir via intent).
- **Dio:** Usar o `dio` injetado com a URL relativa do endpoint de download.
- **Abrir arquivo:** Após salvar, usar `launchUrl(Uri.file(path))` no mobile para abrir no viewer nativo (PDF viewer do sistema, galeria, etc.).

```dart
Future<void> _downloadDocument(BuildContext context) async {
  try {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Baixando ${document.name}...'),
        ]),
        duration: const Duration(minutes: 5),
      ));
    }

    // Diretório: sandbox do app no mobile, Downloads no desktop
    final Directory targetDir;
    if (Platform.isAndroid || Platform.isIOS) {
      targetDir = await getApplicationDocumentsDirectory();
    } else {
      targetDir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
    }

    final filePath = '${targetDir.path}/${document.name}';
    final url = '/notebooks/$notebookId/documents/${document.id}/download';
    await dio.download(url, filePath);

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Download concluído: ${document.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: Platform.isAndroid || Platform.isIOS ? 'Abrir' : 'Abrir pasta',
          onPressed: () async {
            if (Platform.isAndroid || Platform.isIOS) {
              await launchUrl(Uri.file(filePath), mode: LaunchMode.platformDefault);
            } else {
              _openFileLocation(targetDir.path);
            }
          },
        ),
      ));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao baixar arquivo: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }
}
```

**5C. Substituir `Image.network` por download+cache via Dio (thumbnails)**

`_DocumentItem` passa de `StatelessWidget` para usar um `FutureBuilder` na seção de preview de imagem. O método `_loadCachedImage()` segue o mesmo padrão do PDF cache:

```dart
Future<Uint8List?> _loadCachedImage() async {
  final cacheDir = await getApplicationCacheDirectory();
  final ext = document.mimeType?.split('/').last ?? 'jpg';
  final cacheFile = File('${cacheDir.path}/img_cache_${document.id}.$ext');

  if (await cacheFile.exists()) return await cacheFile.readAsBytes();

  final url = '/notebooks/$notebookId/documents/${document.id}/download';
  try {
    final response = await dio.get<List<int>>(url,
      options: Options(responseType: ResponseType.bytes));
    final bytes = Uint8List.fromList(response.data!);
    await cacheFile.writeAsBytes(bytes);
    return bytes;
  } catch (_) {
    return null;
  }
}
```

No widget, substituir o bloco `if (isImage && ...)` por:
```dart
if (isImage && document.storageType == DocumentStorageType.server)
  Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FutureBuilder<Uint8List?>(
        future: _loadCachedImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(height: 150,
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()));
          if (snapshot.data == null)
            return Container(height: 150,
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.broken_image)));
          return Image.memory(snapshot.data!, fit: BoxFit.cover, height: 150);
        },
      ),
    ),
  ),
```

**5D. Atualizar chamada ao `PdfViewerPage`** (no método `_viewDocument`):
```dart
PdfViewerPage(
  document: document,
  dio: dio,
  notebookId: notebookId,
)
```

**5E. Manter `_openFileLocation` apenas para desktop** (já funciona no desktop, não muda).

---

### 6. `document_upload_widget.dart` — Esconder "Local Path" no mobile (Bug 5)

No bloco `if (_selectedType == null)`, envolver o botão de "Arquivo Local" com uma verificação de plataforma:

```dart
// Apenas no desktop — no mobile não há como selecionar caminho manual
if (!Platform.isAndroid && !Platform.isIOS) ...[
  const SizedBox(height: 8),
  _TypeButton(
    icon: Icons.folder,
    label: 'Arquivo Local',
    description: 'Caminho no seu PC',
    onPressed: widget.enabled
        ? () => setState(() => _selectedType = DocumentAddType.localPath)
        : null,
  ),
],
```

Adicionar `import 'dart:io';` no topo do arquivo.

---

### 7. `notebook_detail_page.dart` — Wiring final

Atualizar a instanciação do `DocumentListWidget` (linha 377-380):
```dart
DocumentListWidget(
  documents: widget.viewModel.documents ?? [],
  onDelete: _handleDeleteDocument,
  dio: widget.viewModel.dio,
  notebookId: widget.notebookId,
),
```

---

## Ordem de Execução

```
1. notebook_routes.dart         ← Server: sem dependências, testável isoladamente com curl
2. notebook_detail_view_model   ← ViewModel: Dio + helpers (define a URL pattern)
3. notebook_module.dart         ← DI: passa Dio ao ViewModel (1 linha)
4. pdf_viewer_page.dart         ← PDF: novo construtor + cache (depende do pattern do ViewModel)
5. document_list_widget.dart    ← Lista: download + thumbnails + chama PdfViewerPage
6. document_upload_widget.dart  ← Upload: esconde opção local (independente, pode ser feito a qualquer momento)
7. notebook_detail_page.dart    ← Wiring: passa dio/notebookId (último, conecta tudo)
```

O app não vai compilar até o passo 7 estar completo (parâmetros obrigatórios nos widgets).

---

## Verificação (como testar)

1. **Server — upload + download round-trip:** `curl -X POST` multipart para `/notebooks/{id}/documents/upload` com JWT. Verificar que `path` na resposta é apenas o nome do arquivo (não caminho absoluto). Then `curl -X GET` para `/notebooks/{id}/documents/{docId}/download` com JWT → deve retornar os bytes do arquivo com `Content-Type` correto.

2. **Server — auth no download:** GET sem JWT → 403. GET com docId de notebook diferente → 404.

3. **App — upload no mobile:** Emulator Android. Abrir caderno → "Enviar Arquivo" → selecionar PDF → confirmar. Observar que o upload progresso aparece e o documento aparece na lista. Verificar logs do servidor: path salvo é relativo.

4. **App — PDF view com cache:** Tapa "Visualizar" em um PDF uploadado. Fecha e reabre — deve carregar instantaneamente do cache (sem novo request de rede visível nos logs do Dio).

5. **App — download no mobile:** Menu no documento → "Baixar". Observar download completar. Tapa "Abrir" no SnackBar → deve abrir no viewer nativo do sistema.

6. **App — "Local Path" oculto:** No Android/iOS, o widget de upload deve mostrar apenas "Enviar Arquivo" e "Adicionar Link". No desktop, as três opções.

7. **App — thumbnails cachados:** Upload de uma imagem JPG. Scroll para longe e voltar. O thumbnail deve aparecer instantaneamente na segunda vez (cache). Sem segundo request para a mesma imagem nos logs.

8. **Lint:** `flutter analyze` em `notebook_ui` e `dart analyze` em `notebook_server` → 0 warnings.
