import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart'
    show Result, Success, Failure, DataException;
import 'package:zard/zard.dart';

/// Mixin que fornece funcionalidades completas de validação e gerenciamento
/// de estado de formulários.
///
/// Este mixin isola a biblioteca de validação (atualmente Zard) permitindo
/// substituição futura sem impacto no código consumidor.
///
/// **Funcionalidades:**
/// - Registro e gerenciamento de `TextEditingController`
/// - Validação de formulários usando schemas (Zard isolado)
/// - Gerenciamento de erros por campo
/// - Controle de estado (dirty, touched, submitting)
/// - Submit com validação integrada
///
/// **Exemplo de uso:**
/// ```dart
/// class MyFormViewModel extends ChangeNotifier with FormValidationMixin {
///   MyFormViewModel() {
///     registerField('email');
///     registerField('password');
///   }
///
///   Future<Result<User>> submit() {
///     final data = {
///       'email': getFieldValue('email'),
///       'password': getFieldValue('password'),
///     };
///
///     return submitForm<User>(
///       data: data,
///       schema: UserValidator.schema,
///       onValid: (validatedData) async {
///         return userRepository.login(validatedData);
///       },
///     );
///   }
///
///   @override
///   void dispose() {
///     disposeFormResources();
///     super.dispose();
///   }
/// }
/// ```
mixin FormValidationMixin on ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADO INTERNO DO FORMULÁRIO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Controllers de texto para cada campo do formulário.
  final Map<String, TextEditingController> _controllers = {};

  /// Erros de validação por campo.
  final Map<String, String?> _errors = {};

  /// Campos que foram modificados pelo usuário.
  final Map<String, bool> _dirtyFields = {};

  /// Campos que receberam foco pelo menos uma vez.
  final Map<String, bool> _touchedFields = {};

  /// Indica se o formulário está sendo submetido.
  bool _isSubmitting = false;

  /// Indica se uma validação está em andamento.
  final bool _isValidating = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS PÚBLICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Retorna mapa imutável de erros de validação.
  Map<String, String?> get formErrors => Map.unmodifiable(_errors);

  /// Indica se o formulário está em processo de submit.
  bool get isSubmitting => _isSubmitting;

  /// Indica se uma validação está em andamento.
  bool get isValidating => _isValidating;

  /// Indica se algum campo foi modificado.
  bool get isFormDirty => _dirtyFields.values.any((dirty) => dirty);

  /// Indica se há erros de validação.
  bool get hasErrors => _errors.isNotEmpty;

  /// Indica se o formulário é válido (sem erros).
  bool get isFormValid => _errors.isEmpty;

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTRO E GERENCIAMENTO DE CAMPOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Registra um campo do formulário e retorna seu `TextEditingController`.
  ///
  /// Se o campo já foi registrado, retorna o controller existente.
  ///
  /// [fieldName] - Nome único do campo
  /// [initialValue] - Valor inicial opcional
  /// [validateOnChange] - Se deve validar a cada mudança (padrão: false)
  ///
  /// **Exemplo:**
  /// ```dart
  /// TextField(
  ///   controller: viewModel.registerField('email'),
  ///   decoration: InputDecoration(
  ///     errorText: viewModel.getFieldError('email'),
  ///   ),
  /// )
  /// ```
  TextEditingController registerField(
    String fieldName, {
    String? initialValue,
    bool validateOnChange = false,
  }) {
    if (!_controllers.containsKey(fieldName)) {
      final controller = TextEditingController(text: initialValue ?? '');

      controller.addListener(() {
        _dirtyFields[fieldName] = true;

        if (validateOnChange) {
          // TODO: Implementar validação incremental se necessário
          // Por enquanto, validação acontece apenas no submit
        }

        notifyListeners();
      });

      _controllers[fieldName] = controller;
    }

    return _controllers[fieldName]!;
  }

  /// Obtém o valor atual de um campo.
  ///
  /// Retorna string vazia se o campo não existe.
  String getFieldValue(String fieldName) {
    return _controllers[fieldName]?.text ?? '';
  }

  /// Define o valor de um campo programaticamente.
  ///
  /// Marca o campo como dirty.
  void setFieldValue(String fieldName, String value) {
    final controller = _controllers[fieldName];
    if (controller != null) {
      controller.text = value;
      _dirtyFields[fieldName] = true;
      notifyListeners();
    }
  }

  /// Marca um campo como touched (recebeu foco).
  void setFieldTouched(String fieldName, {bool touched = true}) {
    _touchedFields[fieldName] = touched;
    notifyListeners();
  }

  /// Verifica se um campo foi modificado.
  bool isFieldDirty(String fieldName) {
    return _dirtyFields[fieldName] ?? false;
  }

  /// Verifica se um campo recebeu foco.
  bool isFieldTouched(String fieldName) {
    return _touchedFields[fieldName] ?? false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GERENCIAMENTO DE ERROS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Obtém o erro de validação de um campo específico.
  ///
  /// Retorna `null` se não há erro.
  String? getFieldError(String fieldName) => _errors[fieldName];

  /// Define um erro manual para um campo.
  ///
  /// Útil para erros de servidor ou validações customizadas.
  void setFieldError(String fieldName, String error) {
    _errors[fieldName] = error;
    notifyListeners();
  }

  /// Limpa erros de validação.
  ///
  /// Se [fieldName] for fornecido, limpa apenas esse campo.
  /// Caso contrário, limpa todos os erros.
  void clearErrors([String? fieldName]) {
    if (fieldName != null) {
      _errors.remove(fieldName);
    } else {
      _errors.clear();
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDAÇÃO (ISOLAMENTO DO ZARD)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Valida dados usando um schema (Zard isolado como detalhe de implementação).
  ///
  /// [data] - Dados a serem validados (`Map<String, dynamic>`)
  /// [schema] - Schema de validação do Zard
  ///
  /// Retorna [Success] com dados validados ou [Failure] com erros.
  ///
  /// **Nota:** Erros de validação são automaticamente mapeados para `_errors`
  /// e podem ser acessados via `getFieldError()`.
  Result<Map<String, dynamic>> validateForm({
    required Map<String, dynamic> data,
    required ZMap schema,
  }) {
    _errors.clear();

    try {
      final result = schema.parse(data);
      notifyListeners();
      return Success(result);
    } on ZardError catch (e) {
      // Mapeia erros do Zard para o estado interno
      for (final issue in e.issues) {
        // ignore: avoid_dynamic_calls
        final path = issue.path as List?;
        final fieldName = path?.join('.') ?? 'unknown';
        _errors[fieldName] = issue.message;
      }
      notifyListeners();
      return Failure(DataException('Erro de validação: ${e.messages}'));
    } catch (e) {
      notifyListeners();
      return Failure(
        DataException('Erro inesperado na validação: ${e.toString()}'),
      );
    }
  }

  /// Valida um campo específico.
  ///
  /// [value] - Valor do campo
  /// [fieldSchema] - Schema de validação do campo
  /// [fieldName] - Nome do campo (para mensagens de erro)
  ///
  /// Remove o erro do campo se validação passar.
  Result<T> validateField<T>({
    required T value,
    required dynamic fieldSchema,
    required String fieldName,
  }) {
    try {
      // ignore: avoid_dynamic_calls
      final result = fieldSchema.parse(value);
      _errors.remove(fieldName);
      notifyListeners();
      return Success(result as T);
    } on ZardError catch (e) {
      _errors[fieldName] = e.messages;
      notifyListeners();
      return Failure(DataException('Erro no campo $fieldName: ${e.messages}'));
    } catch (e) {
      notifyListeners();
      return Failure(
        DataException('Erro inesperado no campo $fieldName: ${e.toString()}'),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBMIT DO FORMULÁRIO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Submete o formulário após validação bem-sucedida.
  ///
  /// [data] - Dados do formulário a validar
  /// [schema] - Schema de validação
  /// [onValid] - Callback executado se validação passar
  ///
  /// Gerencia automaticamente:
  /// - Estado de loading (`_isSubmitting`)
  /// - Validação antes de executar callback
  /// - Limpeza de dirty state em caso de sucesso
  ///
  /// **Exemplo:**
  /// ```dart
  /// submitForm<User>(
  ///   data: {'email': email, 'password': password},
  ///   schema: LoginValidator.schema,
  ///   onValid: (validatedData) async {
  ///     return authRepository.login(validatedData);
  ///   },
  /// );
  /// ```
  Future<Result<T>> submitForm<T>({
    required Map<String, dynamic> data,
    required ZMap schema,
    required Future<Result<T>> Function(Map<String, dynamic>) onValid,
  }) async {
    if (_isSubmitting) {
      return Failure(
        DataException('Formulário já está sendo enviado'),
      );
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      // Valida dados
      final validation = validateForm(data: data, schema: schema);

      if (validation case Failure(error: final error)) {
        return Failure(error);
      }

      // Executa callback com dados validados
      final result = await onValid(data);

      // Limpa dirty state em caso de sucesso
      if (result case Success()) {
        _dirtyFields.clear();
        notifyListeners();
      }

      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reseta o formulário para valores iniciais.
  ///
  /// Se [initialValues] for fornecido, preenche os campos com esses valores.
  /// Caso contrário, limpa todos os campos.
  ///
  /// Também limpa erros, dirty state e touched state.
  void resetForm([Map<String, String>? initialValues]) {
    if (initialValues != null) {
      initialValues.forEach((key, value) {
        _controllers[key]?.text = value;
      });
    } else {
      for (final controller in _controllers.values) {
        controller.clear();
      }
    }

    _errors.clear();
    _dirtyFields.clear();
    _touchedFields.clear();
    notifyListeners();
  }

  /// Dispose de todos os recursos do formulário.
  ///
  /// **IMPORTANTE:** Chame este método no `dispose()` do ViewModel.
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   disposeFormResources();
  ///   super.dispose();
  /// }
  /// ```
  void disposeFormResources() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _errors.clear();
    _dirtyFields.clear();
    _touchedFields.clear();
  }
}
