import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_shared/core_shared.dart';
import 'package:book_shared/book_shared.dart';
// import '../validators/book_validators.dart';

/// ViewModel para gerenciar estado de Book.
///
/// Segue padrão MVVM:
/// - Extends ChangeNotifier para reatividade
/// - Usa FormValidationMixin para validação
/// - Usa Loggable para logging
class BookViewModel extends ChangeNotifier 
    with Loggable, FormValidationMixin {
  final BookGetAllUseCase _getBooksUseCase;
  final BookGetByIdUseCase _getBookByIdUseCase;
  // final BookCreateUseCase _createBookUseCase;
  // final BookUpdateUseCase _updateBookUseCase;
  final BookDeleteUseCase _deleteBookUseCase;

  BookViewModel({
    required BookGetAllUseCase getBooksUseCase,
    required BookGetByIdUseCase getBookByIdUseCase,
    // required BookCreateUseCase createBookUseCase,
    // required BookUpdateUseCase updateBookUseCase,
    required BookDeleteUseCase deleteBookUseCase,
  })  : _getBooksUseCase = getBooksUseCase,
        _getBookByIdUseCase = getBookByIdUseCase,
        // _createBookUseCase = createBookUseCase,
        // _updateBookUseCase = updateBookUseCase,
        _deleteBookUseCase = deleteBookUseCase;

  List<BookDetails> _items = [];
  List<BookDetails> get items => _items;

  BookDetails? _selectedItem;
  BookDetails? get selectedItem => _selectedItem;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Carrega lista de books
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getBooksUseCase();

    if (result case Success(value: final data)) {
      _items = data;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega Book por ID
  Future<void> loadItemById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getBookByIdUseCase(id);

    if (result case Success(value: final data)) {
      _selectedItem = data;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria novo Book
  // Future<bool> create(Map<String, dynamic> formData) async {
  //   // Validação com Zard
  //   final validationResult = validateForm(
  //     data: formData,
  //     schema: BookValidators.create,
  //   );
  //   
  //   if (validationResult case Failure(error: final error)) {
  //      _error = error.toString();
  //      notifyListeners();
  //      return false;
  //   }
  // 
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  // 
  //   // Implemente a criação do DTO removendo o null e o throw abaixo
  //   // Exemplo:
  //   // final dto = BookCreate(
  //   //   field1: formData['field1'],
  //   //   field2: formData['field2'],
  //   // );
  //   final BookCreate? dto = null;
  //   if (dto == null) {
  //     throw UnimplementedError('Implemente a criação do BookCreate DTO');
  //   }
  //   
  //   final result = await _createBookUseCase(dto);
  //   
  //   if (result case Success()) {
  //     await loadItems();
  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } else if (result case Failure(error: final error)) {
  //     _error = error.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  /// Atualiza Book
  // Future<bool> update(String id, Map<String, dynamic> formData) async {
  //  // Validação com Zard
  //  final validationResult = validateForm(
  //    data: formData,
  //    schema: BookValidators.update,
  //  );
  //  
  //  if (validationResult case Failure(error: final error)) {
  //     _error = error.toString();
  //     notifyListeners();
  //     return false;
  //  }
  //
  //  _isLoading = true;
  //  _error = null;
  //  notifyListeners();

  //  // Implemente a criação do DTO removendo o null e o throw abaixo
  //  // Exemplo:
  //  // final dto = BookUpdate(
  //  //   id: id,
  //  //   field1: formData['field1'],
  //  //   field2: formData['field2'],
  //  // );
  //  final BookUpdate? dto = null;
  //  if (dto == null) {
  //    throw UnimplementedError('Implemente a criação do BookUpdate DTO');
  //  }
  //  
  //  final result = await _updateBookUseCase(dto);
  //  
  //  if (result case Success()) {
  //    await loadItems();
  //    _isLoading = false;
  //    notifyListeners();
  //    return true;
  //  } else if (result case Failure(error: final error)) {
  //    _error = error.toString();
  //    _isLoading = false;
  //    notifyListeners();
  //    return false;
  //  }
  //}

  /// Deleta Book
  Future<bool> delete(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _deleteBookUseCase(id);

    if (result case Success()) {
      await loadItems();
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    return false; // Fallback para garantir retorno em todos os caminhos
  }
}
