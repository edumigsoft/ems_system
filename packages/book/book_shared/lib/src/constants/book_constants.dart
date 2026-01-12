// ============================================================================
// ROTAS
// ============================================================================

/// Caminho base da API
const String booksPath = '/books';

/// Rotas para operações CRUD

// GET All
const String booksPathGetAll = '/';

// GET By ID (Shelf format)
const String booksPathById = '/<id>';
// GET By ID (OpenAPI format)
const String booksPathByIdOpenApi = '/{id}';

// POST Create
const String booksPathCreate = '/';

// PUT Update (Shelf format)
const String booksPathUpdate = '/<id>';
// PUT Update (OpenAPI format)
const String booksPathUpdateOpenApi = '/{id}';

// DELETE (Shelf format)
const String booksPathDelete = '/<id>';
// DELETE (OpenAPI format)
const String booksPathDeleteOpenApi = '/{id}';

// ============================================================================
// VALIDAÇÕES COMPARTILHADAS
// ============================================================================

// Adicionar RegExp de validação compartilhadas
// Exemplo:
// final RegExp emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
// const String emailInvalidMessage = 'Email inválido';

// Adicionar limites e constraints
// Exemplo:
// const int nameMinLength = 3;
// const int nameMaxLength = 100;
// const String nameMinLengthMessage = 'Nome deve ter no mínimo 3 caracteres';
