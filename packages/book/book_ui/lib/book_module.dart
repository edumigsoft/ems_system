import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart' show AppModule, AppNavigationItem;
import 'package:core_shared/core_shared.dart' show Loggable, DependencyInjector;
import 'package:book_shared/book_shared.dart';
import 'package:book_client/book_client.dart';
import 'ui/view_models/book_view_model.dart';
import 'ui/pages/book_list_page.dart';

/// Module para feature book.
class BookModule extends AppModule with Loggable {
  final DependencyInjector di;

  BookModule({required this.di});

  @override
  void registerDependencies(DependencyInjector di) {
    // Services
    di.registerLazySingleton<BookService>(
      () => BookService(di.get()),
    );

    // Repositories
    di.registerLazySingleton<BookRepository>(
      () => BookRepositoryClient(di.get()),
    );

    // Use Cases
    di.registerLazySingleton<BookGetAllUseCase>(
      () => BookGetAllUseCase(di.get()),
    );
    di.registerLazySingleton<BookGetByIdUseCase>(
      () => BookGetByIdUseCase(di.get()),
    );
    di.registerLazySingleton<BookCreateUseCase>(
      () => BookCreateUseCase(di.get()),
    );
    di.registerLazySingleton<BookUpdateUseCase>(
      () => BookUpdateUseCase(di.get()),
    );
    di.registerLazySingleton<BookDeleteUseCase>(
      () => BookDeleteUseCase(di.get()),
    );

    // ViewModels
    di.registerLazySingleton<BookViewModel>(
      () => BookViewModel(
        getBooksUseCase: di.get(),
        getBookByIdUseCase: di.get(),
        // createBookUseCase: di.get(),
        // updateBookUseCase: di.get(),
        deleteBookUseCase: di.get(),
      ),
    );
     

    // Pages
    di.registerLazySingleton<BookListPage>(
      () => BookListPage(
        viewModel: di.get(),
      ),
    );
  }

  @override
  Map<String, Widget> get routes => {
        '/book_list': di.get<BookListPage>(),
      };

  @override
  List<AppNavigationItem> get navigationItems => [
        AppNavigationItem(
          labelBuilder: (context) => 'Books', // Use AppLocalizations
          icon: Icons.list,
          route: '/book_list',
        ),
      ];
}
