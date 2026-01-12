import 'package:core_shared/core_shared.dart'
    show Result, Unit, Failure, successOfUnit, Success, Loggable;
import '../../core_ui.dart' show Command0, Command1;
import 'package:flutter/material.dart';

/// Classe base abstrata para ViewModels que gerenciam entidades com CRUD.
///
/// Esta classe fornece funcionalidades comuns para ViewModels que precisam:
/// - Gerenciar estado de edição
/// - Controlar detalhes da entidade
/// - Executar operações CRUD básicas
///
/// ## Uso
/// ```dart
/// class UserViewModel extends BaseViewModel<UserDetails> {
///   final GetAllUseCase _getAllUseCase;
///   final CreateUseCase _createUseCase;
///   final UpdateUseCase _updateUseCase;
///   final DeleteUseCase _deleteUseCase;
///
///   UserViewModel({
///     required GetAllUseCase getAllUseCase,
///     required CreateUseCase createUseCase,
///     required UpdateUseCase updateUseCase,
///     required DeleteUseCase deleteUseCase,
///   }) : _getAllUseCase = getAllUseCase,
///        _createUseCase = createUseCase,
///        _updateUseCase = updateUseCase,
///        _deleteUseCase = deleteUseCase;
///
///   @override
///   Future<void> init() async {
///     await super.init();
///     await fetchAllCommand.execute();
///   }
///
///   @override
///   late final fetchAllCommand = Command0(_getAllUseCase.execute);
///
///   @override
///   Future<Result<Unit>> _save() async {
///     if (details == null) return Failure(Exception('No details to save'));
///
///     final result = await (editing != null
///         ? _updateUseCase.execute(details!)
///         : _createUseCase.execute(details!));
///
///     if (result case Failure(error: final error)) {
///         logger.severe('Error occurred while saving school: $error');
///         return Failure(error);
///     }
///
///     details = (result as Success<SchoolDetails>).value;
///     editing = null;
///     canSaved(false);
///     notifyListeners();
///     return successOfUnit();
///   }
/// }
/// ```
abstract class BaseViewModel<T> extends ChangeNotifier with Loggable {
  /// ID da entidade que está sendo editada, ou null se não estiver em modo de edição.
  String? editing;

  /// Detalhes da entidade atualmente selecionada ou sendo editada.
  T? details;

  /// Indica se há alterações pendentes que podem serem salvas.
  bool _canSave = false;

  /// Obtém o estado de permissão para salvar.
  bool get canSave => _canSave;

  /// Define se há alterações pendentes que podem ser salvas.
  void canSaved(bool value) {
    if (_canSave == value) return;
    _canSave = value;
    notifyListeners();
  }

  /// Comando para buscar todas as entidades.
  late final Command0<List<T>> fetchAllCommand;

  /// Comando para cancelar a edição/criação atual.
  late final Command0<Unit> cancelCommand = Command0(_cancel);

  /// Comando para visualizar detalhes de uma entidade.
  late final Command1<Unit, T> detailsCommand = Command1(_details);

  /// Comando para iniciar criação de nova entidade.
  late final Command0<Unit> addCommand = Command0(_add);

  /// Comando para iniciar edição de entidade.
  late final Command0<Unit> editCommand = Command0(_edit);

  /// Comando para salvar alterações (criar ou atualizar).
  late final Command0<Unit> saveCommand = Command0(_save);

  /// Comando para deletar entidade (soft delete).
  late final Command0<Unit> deleteCommand = Command0(delete);

  /// Comando para restaurar entidade deletada.
  late final Command0<Unit> restoreCommand = Command0(restore);

  /// Inicializa o ViewModel.
  ///
  /// Subclasses devem chamar `super.init()` e então executar comandos específicos.
  Future<void> init() async {
    logger.info('${runtimeType.toString()} Init');
    details = null;
    editing = null;
    _canSave = false;
    notifyListeners();
  }

  /// Cancela a operação atual e recarrega a lista.
  Future<Result<Unit>> _cancel() async {
    details = null;
    editing = null;
    _canSave = false;
    await fetchAllCommand.execute();
    notifyListeners();
    return successOfUnit();
  }

  /// Define os detalhes da entidade para visualização.
  Future<Result<Unit>> _details(T value) async {
    details = value;
    editing = null;
    _canSave = false;
    notifyListeners();
    return successOfUnit();
  }

  /// Inicia a criação de uma nova entidade.
  ///
  /// Subclasses devem implementar para criar uma instância vazia de T.
  Future<Result<Unit>> _add() async {
    details = createEmpty();
    editing = null;
    _canSave = false;
    notifyListeners();
    return successOfUnit();
  }

  /// Cria uma instância vazia da entidade.
  ///
  /// Deve ser implementado pelas subclasses.
  T createEmpty();

  /// Inicia a edição da entidade atual.
  Future<Result<Unit>> _edit() async {
    if (details == null) {
      return Failure(Exception('Não há detalhes para editar.'));
    }
    editing = getId(details as T);
    _canSave = false;
    notifyListeners();
    return successOfUnit();
  }

  /// Obtém o ID da entidade.
  ///
  /// Deve ser implementado pelas subclasses.
  String getId(T entity);

  /// Cria uma nova entidade no backend.
  ///
  /// Deve ser implementado pelas subclasses.
  Future<Result<T>> createEntity(T entity);

  /// Atualiza uma entidade existente no backend.
  ///
  /// Deve ser implementado pelas subclasses.
  Future<Result<T>> updateEntity(T entity);

  /// Salva as alterações (criar ou atualizar).
  ///
  /// Implementação padrão que gerencia o fluxo de salvamento:
  /// 1. Verifica se há detalhes para salvar
  /// 2. Decide entre criar ou atualizar baseado no estado de edição
  /// 3. Trata erros e atualiza o estado
  Future<Result<Unit>> _save() async {
    if (details == null) {
      return Failure(Exception('Não há detalhes para salvar.'));
    }

    final result = await (editing != null
        ? updateEntity(details as T)
        : createEntity(details as T));

    if (result case Failure(error: final error)) {
      logger.severe('Erro ao salvar ${T.toString()}: $error');
      return Failure(error);
    }

    details = (result as Success<T>).value;
    editing = null;
    canSaved(false);
    notifyListeners();
    return successOfUnit();
  }

  /// Deleta a entidade atual (soft delete).
  ///
  /// Deve ser implementado pelas subclasses.
  Future<Result<Unit>> delete();

  /// Restaura uma entidade deletada.
  ///
  /// Deve ser implementado pelas subclasses.
  Future<Result<Unit>> restore();
}
