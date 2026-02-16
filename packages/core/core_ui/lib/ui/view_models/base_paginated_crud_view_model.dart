import 'package:core_shared/core_shared.dart'
    show Result, Unit, Failure, successOfUnit, Success, PaginatedResult;
import '../../core_ui.dart' show Command0, Command1, BaseCRUDViewModel;

/// ViewModel base para CRUD com paginação.
///
/// Estende [BaseCRUDViewModel] adicionando funcionalidades de paginação,
/// busca e filtros. Ideal para features que exibem listas paginadas de entidades.
///
/// ## Uso
/// ```dart
/// class SchoolViewModel extends BasePaginatedCRUDViewModel<SchoolDetails> {
///   final GetAllUseCase _getAllUseCase;
///   final CreateUseCase _createUseCase;
///   final UpdateUseCase _updateUseCase;
///   final DeleteUseCase _deleteUseCase;
///
///   SchoolViewModel({
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
///     await refreshCommand.execute();
///   }
///
///   @override
///   Future<Result<PaginatedResult<SchoolDetails>>> fetchPage(
///     int page,
///     int limit, {
///     String? search,
///     Map<String, dynamic>? filters,
///   }) async {
///     final offset = (page - 1) * limit;
///     return _getAllUseCase.execute(
///       limit: limit,
///       offset: offset,
///       search: search,
///     );
///   }
///
///   @override
///   SchoolDetails createEmpty() => SchoolDetails.empty();
///
///   @override
///   String getId(SchoolDetails entity) => entity.id;
///
///   @override
///   Future<Result<SchoolDetails>> createEntity(SchoolDetails entity) async {
///     return _createUseCase.execute(entity);
///   }
///
///   @override
///   Future<Result<SchoolDetails>> updateEntity(SchoolDetails entity) async {
///     return _updateUseCase.execute(entity);
///   }
///
///   @override
///   Future<Result<Unit>> delete() async {
///     if (details == null) {
///       return Failure(Exception('Não há detalhes para excluir.'));
///     }
///     final result = await _deleteUseCase.execute(details!.id);
///     if (result is Success) {
///       await refreshCommand.execute();
///     }
///     return result;
///   }
///
///   @override
///   Future<Result<Unit>> restore() async {
///     if (details == null) {
///       return Failure(Exception('Não há detalhes para restaurar.'));
///     }
///     final restored = details!.copyWith(isDeleted: false);
///     final result = await _updateUseCase.execute(restored);
///     if (result is Success) {
///       details = result.value;
///       await refreshCommand.execute();
///     }
///     return result.isSuccess ? successOfUnit() : Failure(result.error);
///   }
/// }
/// ```
abstract class BasePaginatedCRUDViewModel<T> extends BaseCRUDViewModel<T> {
  /// Lista de itens da página atual
  List<T> _items = [];

  /// Obtém a lista de itens da página atual
  List<T> get items => _items;

  /// Página atual (baseada em 1)
  int _currentPage = 1;

  /// Obtém a página atual
  int get currentPage => _currentPage;

  /// Número de itens por página
  int _pageSize = 50;

  /// Obtém o tamanho da página
  int get pageSize => _pageSize;

  /// Define o tamanho da página
  set pageSize(int value) {
    if (_pageSize == value) return;
    _pageSize = value;
    notifyListeners();
  }

  /// Total de itens (antes da paginação)
  int _totalItems = 0;

  /// Obtém o total de itens
  int get totalItems => _totalItems;

  /// Total de páginas
  int _totalPages = 0;

  /// Obtém o total de páginas
  int get totalPages => _totalPages;

  /// Query de busca atual
  String? _searchQuery;

  /// Obtém a query de busca
  String? get searchQuery => _searchQuery;

  /// Filtros ativos
  Map<String, dynamic> _filters = {};

  /// Obtém os filtros ativos
  Map<String, dynamic> get filters => Map.unmodifiable(_filters);

  /// Verifica se há filtros ativos
  bool get hasActiveFilters =>
      (_searchQuery != null && _searchQuery!.isNotEmpty) || _filters.isNotEmpty;

  /// Verifica se há mais páginas
  bool get hasNextPage => _currentPage < _totalPages;

  /// Verifica se há página anterior
  bool get hasPreviousPage => _currentPage > 1;

  /// Verifica se está na primeira página
  bool get isFirstPage => _currentPage == 1;

  /// Verifica se está na última página
  bool get isLastPage => _currentPage >= _totalPages;

  /// Comando para carregar próxima página
  late final Command0<Unit> loadNextPageCommand = Command0(_loadNextPage);

  /// Comando para carregar página anterior
  late final Command0<Unit> loadPreviousPageCommand = Command0(
    _loadPreviousPage,
  );

  /// Comando para ir para uma página específica
  late final Command1<Unit, int> goToPageCommand = Command1(_goToPage);

  /// Comando para buscar por query
  late final Command1<Unit, String?> searchCommand = Command1(_search);

  /// Comando para aplicar filtros
  late final Command1<Unit, Map<String, dynamic>> applyFiltersCommand =
      Command1(_applyFilters);

  /// Comando para limpar filtros
  late final Command0<Unit> clearFiltersCommand = Command0(_clearFilters);

  /// Comando para atualizar (refresh) a lista
  late final Command0<Unit> refreshCommand = Command0(_refresh);

  @override
  Future<void> init() async {
    await super.init();
    _items = [];
    _currentPage = 1;
    _totalItems = 0;
    _totalPages = 0;
    _searchQuery = null;
    _filters = {};
    notifyListeners();
  }

  /// Sobrescreve fetchAllCommand para usar paginação
  @override
  late final Command0<List<T>> fetchAllCommand = Command0(_fetchAll);

  Future<Result<List<T>>> _fetchAll() async {
    final result = await fetchPage(
      _currentPage,
      _pageSize,
      search: _searchQuery,
      filters: _filters,
    );

    return result.when(
      success: (paginatedResult) {
        _items = paginatedResult.items;
        _totalItems = paginatedResult.total;
        _totalPages = paginatedResult.totalPages;
        _currentPage = paginatedResult.page;
        notifyListeners();
        return Success(_items);
      },
      failure: (error) {
        logger.severe('Erro ao buscar itens paginados: $error');
        return Failure(error);
      },
    );
  }

  /// Busca uma página de itens.
  ///
  /// Deve ser implementado pelas subclasses para buscar dados do backend.
  ///
  /// ## Parâmetros
  /// - [page]: Número da página (baseado em 1)
  /// - [limit]: Número de itens por página
  /// - [search]: Query de busca (opcional)
  /// - [filters]: Filtros adicionais (opcional)
  ///
  /// ## Retorno
  /// Result contendo PaginatedResult&lt;T&gt; com os itens e metadados de paginação.
  Future<Result<PaginatedResult<T>>> fetchPage(
    int page,
    int limit, {
    String? search,
    Map<String, dynamic>? filters,
  });

  /// Carrega a próxima página
  Future<Result<Unit>> _loadNextPage() async {
    if (!hasNextPage) {
      return Failure(Exception('Não há próxima página'));
    }

    _currentPage++;
    await fetchAllCommand.execute();

    // Command armazena result internamente
    final result = fetchAllCommand.result;
    if (result == null) {
      return Failure(Exception('Erro desconhecido'));
    }

    return result.when(
      success: (_) => successOfUnit(),
      failure: (error) => Failure(error),
    );
  }

  /// Carrega a página anterior
  Future<Result<Unit>> _loadPreviousPage() async {
    if (!hasPreviousPage) {
      return Failure(Exception('Não há página anterior'));
    }

    _currentPage--;
    await fetchAllCommand.execute();

    // Command armazena result internamente
    final result = fetchAllCommand.result;
    if (result == null) {
      return Failure(Exception('Erro desconhecido'));
    }

    return result.when(
      success: (_) => successOfUnit(),
      failure: (error) => Failure(error),
    );
  }

  /// Vai para uma página específica
  Future<Result<Unit>> _goToPage(int page) async {
    if (page < 1 || page > _totalPages) {
      return Failure(Exception('Página inválida: $page'));
    }

    _currentPage = page;
    await fetchAllCommand.execute();

    // Command armazena result internamente
    final result = fetchAllCommand.result;
    if (result == null) {
      return Failure(Exception('Erro desconhecido'));
    }

    return result.when(
      success: (_) => successOfUnit(),
      failure: (error) => Failure(error),
    );
  }

  /// Busca por query
  Future<Result<Unit>> _search(String? query) async {
    _searchQuery = query;
    _currentPage = 1; // Reset para primeira página
    await fetchAllCommand.execute();

    // Command armazena result internamente
    final result = fetchAllCommand.result;
    if (result == null) {
      return Failure(Exception('Erro desconhecido'));
    }

    return result.when(
      success: (_) => successOfUnit(),
      failure: (error) => Failure(error),
    );
  }

  /// Aplica filtros
  Future<Result<Unit>> _applyFilters(Map<String, dynamic> newFilters) async {
    _filters = Map.from(newFilters);
    _currentPage = 1; // Reset para primeira página
    await fetchAllCommand.execute();

    // Command armazena result internamente
    final result = fetchAllCommand.result;
    if (result == null) {
      return Failure(Exception('Erro desconhecido'));
    }

    return result.when(
      success: (_) => successOfUnit(),
      failure: (error) => Failure(error),
    );
  }

  /// Define um filtro específico
  Future<void> setFilter(String key, dynamic value) async {
    _filters[key] = value;
    await applyFiltersCommand.execute(_filters);
  }

  /// Remove um filtro específico
  Future<void> removeFilter(String key) async {
    _filters.remove(key);
    await applyFiltersCommand.execute(_filters);
  }

  /// Limpa todos os filtros e busca
  Future<Result<Unit>> _clearFilters() async {
    _searchQuery = null;
    _filters = {};
    _currentPage = 1;
    await fetchAllCommand.execute();

    // Command armazena result internamente
    final result = fetchAllCommand.result;
    if (result == null) {
      return Failure(Exception('Erro desconhecido'));
    }

    return result.when(
      success: (_) => successOfUnit(),
      failure: (error) => Failure(error),
    );
  }

  /// Atualiza a lista (volta para página 1)
  Future<Result<Unit>> _refresh() async {
    _currentPage = 1;
    await fetchAllCommand.execute();

    // Command armazena result internamente
    final result = fetchAllCommand.result;
    if (result == null) {
      return Failure(Exception('Erro desconhecido'));
    }

    return result.when(
      success: (_) => successOfUnit(),
      failure: (error) => Failure(error),
    );
  }

  /// Informações de paginação formatadas
  String get paginationInfo {
    if (_totalItems == 0) return 'Nenhum item encontrado';

    final firstItem = (_currentPage - 1) * _pageSize + 1;
    final lastItem = (_currentPage * _pageSize).clamp(0, _totalItems);

    return 'Mostrando $firstItem-$lastItem de $_totalItems itens';
  }
}
