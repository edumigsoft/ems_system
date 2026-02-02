# Backend Implementation - Notebook Server

## Resumo das Alterações

Implementação dos endpoints necessários para suportar as funcionalidades de documentos e hierarquia de notebooks no frontend.

## ✅ Endpoints Implementados

### 1. Busca de Notebooks Filhos (Hierarquia)

**Endpoint JÁ EXISTIA**: `GET /api/v1/notebooks?parentId={id}`

Este endpoint já estava implementado desde o início! O frontend pode usá-lo imediatamente.

**Query Parameters:**
- `parent_id`: ID do notebook pai para buscar filhos
- `active_only`: Filtrar apenas ativos (padrão: true)
- `search`: Busca por título/conteúdo
- `project_id`: Filtrar por projeto
- `type`: Filtrar por tipo (quick, organized, reminder)
- `tags`: Filtrar por tags (separadas por vírgula)
- `overdue_only`: Apenas com reminders vencidos

**Exemplo:**
```http
GET /api/v1/notebooks?parent_id=123e4567-e89b-12d3-a456-426614174000
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "title": "Caderno Filho 1",
    "parent_id": "123e4567-e89b-12d3-a456-426614174000",
    ...
  }
]
```

---

### 2. Listar Documentos de um Notebook

**Novo Endpoint**: `GET /api/v1/notebooks/{notebookId}/documents`

**Query Parameters:**
- `storage_type`: Filtrar por tipo de armazenamento (server, local, url)

**Exemplo:**
```http
GET /api/v1/notebooks/123e4567-e89b-12d3-a456-426614174000/documents
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "id": "doc-123",
    "name": "documento.pdf",
    "path": "/uploads/documento_1234567890.pdf",
    "storage_type": "server",
    "mime_type": "application/pdf",
    "size_bytes": 1024000,
    "notebook_id": "123e4567-e89b-12d3-a456-426614174000",
    "created_at": "2026-01-25T10:00:00Z",
    "updated_at": "2026-01-25T10:00:00Z"
  }
]
```

---

### 3. Upload de Arquivo (TODO)

**Endpoint**: `POST /api/v1/notebooks/{notebookId}/documents/upload`

**Status**: ⏸️ Temporariamente retorna 501 Not Implemented

**Motivo**: Aguardando integração de biblioteca multipart/form-data adequada.

**Bibliotecas Sugeridas**:
- `shelf_multipart` (se disponível)
- `mime_multipart`
- Implementação customizada com stream parsing

**Quando implementado, esperará:**
```http
POST /api/v1/notebooks/123/documents/upload
Content-Type: multipart/form-data
Authorization: Bearer {token}

--boundary
Content-Disposition: form-data; name="file"; filename="documento.pdf"
Content-Type: application/pdf

[binary data]
--boundary--
```

**Response esperada:**
```json
{
  "id": "doc-123",
  "name": "documento.pdf",
  "path": "/uploads/documento_1234567890.pdf",
  "storage_type": "server",
  "mime_type": "application/pdf",
  "size_bytes": 1024000,
  "notebook_id": "123"
}
```

---

## 📦 Novos Componentes Criados

### Repositórios

**DocumentReferenceRepositoryServer**
- Localização: `lib/src/repository/document_reference_repository_server.dart`
- Implementa: `DocumentReferenceRepository` do `notebook_shared`
- Métodos:
  - `create(DocumentReferenceCreate)` - Criar referência
  - `getById(String)` - Buscar por ID
  - `getByNotebookId(String, {DocumentStorageType?})` - Listar por notebook
  - `update(DocumentReferenceUpdate)` - Atualizar
  - `delete(String)` - Deletar permanentemente

### Rotas

**NotebookRoutes (atualizado)**
- Adicionados novos endpoints:
  - `GET /notebooks/{id}/documents` - Listar documentos
  - `POST /notebooks/{id}/documents/upload` - Upload (TODO)
- Integra `DocumentReferenceRepository`

---

## 🔧 Alterações no Módulo

**init_notebook_module.dart**
- Registra `DocumentReferenceRepositoryServer` no DI
- Passa `DocumentReferenceRepository` para `NotebookRoutes`
- Parâmetro `uploadsPath` removido temporariamente

---

## 📝 Dependências Adicionadas

```yaml
dependencies:
  mime: ^2.0.0     # Para detectar MIME types
  path: ^1.9.0     # Para manipulação de caminhos
```

---

## ✅ Status da Análise

```bash
dart analyze
# Output: No issues found!
```

Todo o código passa na análise sem erros ou warnings.

---

## 🎯 Próximos Passos

### Frontend (Imediato)

1. **Descomentar código de busca de filhos** em `notebook_detail_view_model.dart:191`:
   ```dart
   Future<void> loadChildren() async {
     if (_notebook == null) return;

     final result = await _notebookService.getAll(
       parentId: _notebook!.id,
     );

     if (result case Success(value: final data)) {
       _childNotebooks = data;
       notifyListeners();
     }
   }
   ```

2. **Chamar `loadChildren()`** após carregar o notebook pai.

### Backend (Futuro)

3. **Implementar upload de arquivo**:
   - Adicionar biblioteca multipart adequada
   - Implementar parsing de multipart/form-data
   - Salvar arquivo em disco
   - Criar referência no banco de dados
   - Remover endpoint da implementação em `notebook_routes.dart:502`

4. **Melhorias opcionais**:
   - Validação de tipo de arquivo (whitelist de MIME types)
   - Limite de tamanho de arquivo
   - Antivírus scan
   - Armazenamento em cloud (S3, etc.)
   - Geração de thumbnails para imagens

---

## 📊 Comparação: Frontend vs Backend

| Funcionalidade | Frontend | Backend | Status |
|----------------|----------|---------|--------|
| Buscar cadernos filhos | ✅ Implementado | ✅ Endpoint existe | 🟢 Pronto para usar |
| Listar documentos | ✅ Implementado | ✅ Endpoint criado | 🟢 Pronto para usar |
| Upload de arquivo | ✅ UI pronta | ⏸️ Aguardando lib | 🟡 Pendente |

---

## 🔍 Exemplo de Uso Completo

### 1. Buscar Notebook Pai
```http
GET /api/v1/notebooks/parent-123
Authorization: Bearer {token}
```

### 2. Buscar Filhos
```http
GET /api/v1/notebooks?parent_id=parent-123
Authorization: Bearer {token}
```

### 3. Buscar Documentos do Pai
```http
GET /api/v1/notebooks/parent-123/documents
Authorization: Bearer {token}
```

### 4. Adicionar Referência Manual (URL)
```http
POST /api/v1/documents
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Documento Externo",
  "path": "https://example.com/doc.pdf",
  "storage_type": "url",
  "mime_type": "application/pdf",
  "notebook_id": "parent-123"
}
```

---

**Data de Implementação**: 2026-01-25
**Versão**: 1.0.0
**Status**: ✅ Backend pronto para hierarquia e listagem de documentos
