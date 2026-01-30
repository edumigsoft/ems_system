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
        GetDeletedSchoolsUseCase,
        CreateUseCase,
        UpdateUseCase,
        DeleteUseCase,
        RestoreSchoolUseCase;

class SchoolViewModel extends BaseCRUDViewModel<SchoolDetails>
    with FormValidationMixin {
  final GetAllUseCase _getAllUseCase;
  final GetDeletedSchoolsUseCase _getDeletedUseCase;
  final CreateUseCase _createUseCase;
  final UpdateUseCase _updateUseCase;
  final DeleteUseCase _deleteUseCase;
  final RestoreSchoolUseCase _restoreUseCase;

  /// Indica se deve mostrar escolas deletadas ao invés das ativas.
  bool _showDeleted = false;
  bool get showDeleted => _showDeleted;

  SchoolViewModel({
    required GetAllUseCase getAllUseCase,
    required GetDeletedSchoolsUseCase getDeletedUseCase,
    required CreateUseCase createUseCase,
    required UpdateUseCase updateUseCase,
    required DeleteUseCase deleteUseCase,
    required RestoreSchoolUseCase restoreUseCase,
  }) : _getAllUseCase = getAllUseCase,
       _getDeletedUseCase = getDeletedUseCase,
       _createUseCase = createUseCase,
       _updateUseCase = updateUseCase,
       _deleteUseCase = deleteUseCase,
       _restoreUseCase = restoreUseCase;

  @override
  late final Command0<List<SchoolDetails>> fetchAllCommand = Command0(
    _fetchAll,
  );

  /// Comando para refresh (pull-to-refresh).
  late final Command0<Unit> refreshCommand = Command0(_refresh);

  /// Comando para alternar entre mostrar escolas ativas ou deletadas.
  late final Command0<Unit> toggleShowDeletedCommand = Command0(
    _toggleShowDeleted,
  );

  /// Wrapper para extrair items do PaginatedResult.
  /// Busca escolas ativas ou deletadas conforme estado de [showDeleted].
  Future<Result<List<SchoolDetails>>> _fetchAll() async {
    final result = _showDeleted
        ? await _getDeletedUseCase.execute()
        : await _getAllUseCase.execute();
    return result.map((paginatedResult) => paginatedResult.items);
  }

  /// Alterna entre visualização de escolas ativas e deletadas.
  Future<Result<Unit>> _toggleShowDeleted() async {
    _showDeleted = !_showDeleted;
    await fetchAllCommand.execute();
    notifyListeners();
    return successOfUnit();
  }

  /// Atualiza a lista de escolas (usado por pull-to-refresh).
  Future<Result<Unit>> _refresh() async {
    await fetchAllCommand.execute();
    return successOfUnit();
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

    final result = await _restoreUseCase.execute(details!.id);

    if (result case Failure(error: final error)) {
      logger.severe('Error occurred while restoring school: $error');
      return Failure(error);
    }

    // Atualizar detalhes localmente
    details = details!.copyWith(isDeleted: false);
    await fetchAllCommand.execute();
    notifyListeners();
    return successOfUnit();
  }
}
