import 'package:flutter/foundation.dart';
import 'package:core_shared/core_shared.dart' show Result;
import 'package:core_ui/core_ui.dart' show FormValidationMixin;
import 'package:school_shared/school_shared.dart'
    show
        SchoolDetails,
        SchoolDetailsValidator,
        CreateUseCase,
        UpdateUseCase,
        SchoolStatus,
        schoolNameByField,
        schoolEmailByField,
        schoolAddressByField,
        schoolPhoneByField,
        schoolCieByField;

/// ViewModel para formulário de criação/edição de escolas.
///
/// Utiliza [FormValidationMixin] para gerenciamento completo de estado de
/// formulários, incluindo validação, erros, dirty state e TextControllers.
///
/// **Funcionalidades:**
/// - Criação de nova escola
/// - Edição de escola existente
/// - Validação usando [SchoolDetailsValidator.schema]
/// - Gerenciamento automático de estado de formulário
///
/// **Exemplo de uso:**
/// ```dart
/// final viewModel = SchoolFormViewModel(
///   createUseCase: createUseCase,
///   updateUseCase: updateUseCase,
///   initialData: existingSchool, // null para criação
/// );
///
/// // No widget
/// TextField(
///   controller: viewModel.registerField(schoolNameByField),
///   decoration: InputDecoration(
///     errorText: viewModel.getFieldError(schoolNameByField),
///   ),
/// )
/// ```
class SchoolFormViewModel extends ChangeNotifier with FormValidationMixin {
  final CreateUseCase _createUseCase;
  final UpdateUseCase _updateUseCase;
  final SchoolDetails? _initialData;

  /// Indica se é modo de edição (true) ou criação (false).
  bool get isEditMode => _initialData != null;

  SchoolFormViewModel({
    required CreateUseCase createUseCase,
    required UpdateUseCase updateUseCase,
    SchoolDetails? initialData,
  }) : _createUseCase = createUseCase,
       _updateUseCase = updateUseCase,
       _initialData = initialData {
    _initializeFields();
  }

  /// Inicializa os campos do formulário.
  ///
  /// Se [_initialData] não é null (modo edição), preenche com valores existentes.
  void _initializeFields() {
    final data = _initialData;
    if (data != null) {
      // Modo edição - preenche com dados existentes
      registerField(
        schoolNameByField,
        initialValue: data.name,
      );
      registerField(
        schoolEmailByField,
        initialValue: data.email,
      );
      registerField(
        schoolAddressByField,
        initialValue: data.address,
      );
      registerField(
        schoolPhoneByField,
        initialValue: data.phone,
      );
      registerField(
        schoolCieByField,
        initialValue: data.code,
      );
    } else {
      // Modo criação - campos vazios
      registerField(schoolNameByField);
      registerField(schoolEmailByField);
      registerField(schoolAddressByField);
      registerField(schoolPhoneByField);
      registerField(schoolCieByField);
    }
  }

  /// Coleta dados atuais do formulário.
  Map<String, dynamic> _getFormData() {
    return {
      schoolNameByField: getFieldValue(schoolNameByField),
      schoolEmailByField: getFieldValue(schoolEmailByField),
      schoolAddressByField: getFieldValue(schoolAddressByField),
      schoolPhoneByField: getFieldValue(schoolPhoneByField),
      schoolCieByField: getFieldValue(schoolCieByField),
    };
  }

  /// Cria [SchoolDetails] a partir dos dados do formulário.
  ///
  /// Usa dados do formulário para campos validados e valores padrão/existentes
  /// para campos não cobertos pelo validador.
  SchoolDetails _createSchoolDetailsFromFormData(Map<String, dynamic> data) {
    final existingData = _initialData;
    if (existingData != null) {
      // Modo edição - preserva campos não editáveis
      return existingData.copyWith(
        name: data[schoolNameByField] as String,
        email: data[schoolEmailByField] as String,
        address: data[schoolAddressByField] as String,
        phone: data[schoolPhoneByField] as String,
        code: data[schoolCieByField] as String,
      );
    } else {
      // Modo criação - valores padrão para campos não validados
      return SchoolDetails(
        id: '', // Será gerado pelo backend
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: data[schoolNameByField] as String,
        email: data[schoolEmailByField] as String,
        address: data[schoolAddressByField] as String,
        phone: data[schoolPhoneByField] as String,
        code: data[schoolCieByField] as String,
        // Valores padrão para campos não cobertos pelo validador
        locationCity: 'Não especificado',
        locationDistrict: 'Não especificado',
        director: 'Não especificado',
        status: SchoolStatus.active,
      );
    }
  }

  /// Submete o formulário para criação ou atualização.
  ///
  /// Valida os dados usando [SchoolDetailsValidator.schema] antes de
  /// executar a operação correspondente (criar ou atualizar).
  ///
  /// Retorna [Result] com [SchoolDetails] em caso de sucesso ou erro.
  ///
  /// **Exemplo:**
  /// ```dart
  /// final result = await viewModel.submit();
  /// if (result case Success(data: final school)) {
  ///   // Sucesso - navegar de volta
  ///   Navigator.of(context).pop(school);
  /// } else if (result case Failure(error: final error)) {
  ///   // Erro - mostrar mensagem
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text(error.message)),
  ///   );
  /// }
  /// ```
  Future<Result<SchoolDetails>> submit() async {
    final formData = _getFormData();

    return submitForm<SchoolDetails>(
      data: formData,
      schema: SchoolDetailsValidator.schema,
      onValid: (validatedData) async {
        final schoolDetails = _createSchoolDetailsFromFormData(validatedData);

        if (isEditMode) {
          return _updateUseCase.execute(schoolDetails);
        } else {
          return _createUseCase.execute(schoolDetails);
        }
      },
    );
  }

  /// Reseta o formulário para valores iniciais.
  ///
  /// Se em modo edição, volta aos valores de [_initialData].
  /// Se em modo criação, limpa todos os campos.
  void reset() {
    final data = _initialData;
    if (data != null) {
      resetForm({
        schoolNameByField: data.name,
        schoolEmailByField: data.email,
        schoolAddressByField: data.address,
        schoolPhoneByField: data.phone,
        schoolCieByField: data.code,
      });
    } else {
      resetForm();
    }
  }

  @override
  void dispose() {
    disposeFormResources();
    super.dispose();
  }
}
