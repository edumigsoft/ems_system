# ADR-0007: REST API Error Messages

**Status:** Aceito
**Data:** 2026-02-16
**Decisores:** Equipe de Desenvolvimento
**Relacionado:** ADR-0001 (Result Pattern), ADR-0002 (DioErrorHandler)

## Contexto

### Problema
As mensagens de erro retornadas pela API REST estavam técnicas e pouco amigáveis ao usuário:

```json
{
  "error": "Exception: ValidationException: Invalid data"
}
```

Isso causava:
- Usuários vendo stack traces e mensagens técnicas
- Dificuldade de internacionalização
- Inconsistência entre diferentes endpoints
- Exposição de detalhes internos da implementação

### Estado Anterior
- Rotas usavam `error.toString()` diretamente
- `HttpResponseHelper` apenas encapsulava exceções sem processamento
- Cliente tentava extrair mensagens úteis do JSON (ADR-0002)
- Sem padrão definido para estrutura de erro

## Decisão

Implementar sistema padronizado de mensagens de erro amigáveis através do `ErrorMessageMapper`.

### Formato de Resposta Padrão

```json
{
  "error": "Título curto do erro (user-friendly)",
  "message": "Mensagem descritiva para o usuário em português",
  "statusCode": 400,
  "details": {
    "field1": ["mensagem de erro 1"],
    "field2": ["mensagem de erro 2"]
  }
}
```

**Campos:**
- `error` (obrigatório): Título curto e direto do erro
- `message` (obrigatório): Descrição user-friendly do que aconteceu
- `statusCode` (obrigatório): Código HTTP correspondente
- `details` (opcional): Informações adicionais estruturadas (ex: campos de validação)

### Mapeamento de Exceções

| Exceção | Status | Título | Mensagem | Details |
|---------|--------|--------|----------|---------|
| `ValidationException` | 400 | "Dados inválidos" | "Verifique os campos e tente novamente" | Campos com erros |
| `UnauthorizedException` | 401 | "Não autorizado" | "Faça login novamente" | - |
| `DataException` | 400/500* | "Erro ao processar requisição" | exception.message | - |
| `StorageException` | 500 | "Erro no servidor" | "Erro ao acessar dados. Tente novamente mais tarde." | - |
| `Exception` (genérico) | 500 | "Erro interno" | "Ocorreu um erro inesperado. Tente novamente mais tarde." | - |

\* DataException pode ser 400 ou 500 dependendo do statusCode especificado na exceção.

### Implementação

```dart
// ErrorMessageMapper
class ErrorMessageMapper {
  static ErrorResponse fromException(Exception error);
}

class ErrorResponse {
  final String error;
  final String message;
  final int statusCode;
  final Map<String, dynamic>? details;

  Map<String, dynamic> toJson() => {...};
}
```

### Integração com HttpResponseHelper

```dart
Failure(error: final e) {
  final errorResponse = ErrorMessageMapper.fromException(e);
  return Response(
    errorResponse.statusCode,
    body: json.encode(errorResponse.toJson()),
    headers: {'content-type': 'application/json'},
  );
}
```

## Consequências

### Positivas
- ✅ **Melhor UX:** Mensagens compreensíveis para usuários finais
- ✅ **Consistência:** Formato padronizado em toda a API
- ✅ **Manutenibilidade:** Mensagens centralizadas, fácil de atualizar
- ✅ **Segurança:** Não expõe detalhes internos da implementação
- ✅ **Internacionalização:** Facilita i18n futuro (mensagens em um lugar)
- ✅ **Compatibilidade:** Integra perfeitamente com DioErrorHandler (ADR-0002)
- ✅ **Testabilidade:** Mapeamentos claramente definidos e testáveis

### Negativas
- ⚠️ **Migração:** Requer atualização de todas as rotas existentes
- ⚠️ **Camada Extra:** Adiciona lógica de mapeamento no servidor
- ⚠️ **Manutenção:** Novos tipos de exceção precisam ser mapeados

### Neutras
- 📝 Logs internos continuam com stack traces completos (apenas resposta ao cliente é amigável)
- 📝 Cliente já está preparado para extrair mensagens (ADR-0002)

## Compatibilidade

### Com DioErrorHandler (Cliente)
O `DioErrorHandler` (ADR-0002) extrai mensagens usando:
```dart
final message = data['message'] ?? data['error'] ?? data['detail'];
```

O novo formato fornece ambos `message` e `error`, garantindo compatibilidade total.

### Com APIs Existentes
- Migração incremental possível (rotas não migradas ainda funcionam)
- Novo formato é retrocompatível (cliente prefere `message`, fallback para `error`)

## Exemplos de Uso

### Em Rotas

```dart
// ANTES
Failure(error: final error) =>
  error is ValidationException
    ? Response(400, body: jsonEncode({'error': error.toString()}))
    : Response(401, body: jsonEncode({'error': error.toString()})),

// DEPOIS
Failure(error: final error) {
  final errorResponse = ErrorMessageMapper.fromException(error);
  return Response(
    errorResponse.statusCode,
    body: json.encode(errorResponse.toJson()),
    headers: {'content-type': 'application/json'},
  );
}
```

### ValidationException com Details

```dart
// Servidor retorna:
{
  "error": "Dados inválidos",
  "message": "Verifique os campos e tente novamente",
  "statusCode": 400,
  "details": {
    "name": ["Nome é obrigatório"],
    "email": ["Email inválido"],
    "password": ["Senha deve ter no mínimo 8 caracteres"]
  }
}

// Cliente recebe mensagem clara:
// "Dados inválidos: Verifique os campos e tente novamente"
// E pode exibir erros por campo usando 'details'
```

## Referências

- ADR-0001: Result Pattern
- ADR-0002: DioErrorHandler (cliente)
- RFC 7807: Problem Details for HTTP APIs (inspiração)
- REST API Error Handling Best Practices

## Notas de Implementação

1. **ErrorMessageMapper** deve ser testado para todas as exceções de domínio
2. **HttpResponseHelper** deve usar o mapper automaticamente
3. Rotas devem delegar para `HttpResponseHelper.toResponse()`
4. Mensagens devem ser em **português brasileiro**
5. Logs internos devem manter stack traces completos (não simplificar)
6. Testes de integração devem validar formato JSON das respostas
