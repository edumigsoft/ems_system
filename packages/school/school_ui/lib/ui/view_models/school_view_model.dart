import 'package:core_shared/core_shared.dart'
    show Result, Unit, Failure, successOfUnit;
import 'package:core_ui/core_ui.dart'
    show BaseCRUDViewModel, Command0, FormValidationMixin;
import 'package:school_shared/school_shared.dart'
    show
        SchoolDetails,
        SchoolDetailsModel,
        SchoolDetailsValidator,
        GetAllUseCase,
        CreateUseCase,
        UpdateUseCase,
        DeleteUseCase;

class SchoolViewModel extends BaseCRUDViewModel<SchoolDetails>
    with FormValidationMixin {
  final GetAllUseCase _getAllUseCase;
  final CreateUseCase _createUseCase;
  final UpdateUseCase _updateUseCase;
  final DeleteUseCase _deleteUseCase;

  SchoolViewModel({
    required GetAllUseCase getAllUseCase,
    required CreateUseCase createUseCase,
    required UpdateUseCase updateUseCase,
    required DeleteUseCase deleteUseCase,
  }) : _getAllUseCase = getAllUseCase,
       _createUseCase = createUseCase,
       _updateUseCase = updateUseCase,
       _deleteUseCase = deleteUseCase {
    fetchAllCommand = Command0(_getAllUseCase.execute);
  }

  @override
  Future<void> init() async {
    await super.init();
    await fetchAllCommand.execute();
    notifyListeners();
  }

  /// Cria uma instância vazia da escola.
  ///
  /// Este método é chamado indiretamente por [addCommand] através da classe base.
  @override
  SchoolDetails createEmpty() => SchoolDetails.empty();

  @override
  String getId(SchoolDetails entity) => entity.id;

  @override
  Future<Result<SchoolDetails>> createEntity(SchoolDetails entity) async {
    final validation = validateForm(
      data: SchoolDetailsModel.fromDomain(entity).toJson(),
      schema: SchoolDetailsValidator.schema,
    );
    if (validation case Failure(error: final error)) {
      return Failure(error);
    }
    return _createUseCase.execute(entity);
  }

  @override
  Future<Result<SchoolDetails>> updateEntity(SchoolDetails entity) async {
    final validation = validateForm(
      data: SchoolDetailsModel.fromDomain(entity).toJson(),
      schema: SchoolDetailsValidator.schema,
    );
    if (validation case Failure(error: final error)) {
      return Failure(error);
    }
    return _updateUseCase.execute(entity);
  }

  /// Deleta a escola atual (soft delete).
  ///
  /// Este método é chamado indiretamente por [deleteCommand] através da classe base.
  @override
  Future<Result<Unit>> delete() async {
    if (details == null) {
      return Failure(Exception('Não há detalhes para excluir.'));
    }

    final result = await _deleteUseCase.execute(details!.id);

    if (result case Failure(error: final error)) {
      logger.severe('Error occurred while deleting school: $error');
      return Failure(error);
    }

    details = details!.copyWith(isDeleted: true);
    await fetchAllCommand.execute();
    notifyListeners();
    return successOfUnit();
  }

  /// Restaura uma escola deletada.
  ///
  /// Este método é chamado indiretamente por [restoreCommand] através da classe base.
  @override
  Future<Result<Unit>> restore() async {
    if (details == null) {
      return Failure(Exception('Não há detalhes para restaurar.'));
    }

    final updatedDetails = details!.copyWith(isDeleted: false);
    final result = await _updateUseCase.execute(updatedDetails);

    if (result case Failure(error: final error)) {
      logger.severe('Error occurred while restoring school: $error');
      return Failure(error);
    }

    details = result.valueOrThrow;
    await fetchAllCommand.execute();
    notifyListeners();
    return successOfUnit();
  }
}
