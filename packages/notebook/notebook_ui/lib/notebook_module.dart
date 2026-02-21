import 'package:core_shared/core_shared.dart' show DependencyInjector, Loggable;
import 'package:core_ui/core_ui.dart'
    show AppModule, AppNavigationItem, AppNavigationSection, DashboardRegistry;

import 'package:flutter/material.dart';

import 'package:notebook_client/notebook_client.dart'
    show NotebookApiService, DocumentReferenceApiService;

import 'package:tag_client/tag_client.dart' show TagApiService;

import 'package:dio/dio.dart';

import 'pages/notebook_list_page.dart';

import 'view_models/notebook_list_view_model.dart';
import 'view_models/notebook_detail_view_model.dart';
import 'view_models/notebook_create_view_model.dart';

import 'dashboard/notebook_reminders_entry.dart';
import 'dashboard/notebook_quick_notes_entry.dart';

class NotebookModule extends AppModule with Loggable {
  final DependencyInjector di;

  NotebookModule({required this.di});

  static const String routeName = '/notebooks';

  @override
  void registerDependencies(DependencyInjector di) {
    logger.info('registerDependencies');

    // Registra serviços API
    di.registerLazySingleton<NotebookApiService>(
      () => NotebookApiService(di.get<Dio>()),
    );

    di.registerLazySingleton<DocumentReferenceApiService>(
      () => DocumentReferenceApiService(di.get<Dio>()),
    );

    // Registra ViewModels
    di.registerLazySingleton<NotebookListViewModel>(
      () => NotebookListViewModel(
        notebookService: di.get<NotebookApiService>(),
        tagService: di.get<TagApiService>(),
      ),
    );

    di.registerFactory<NotebookDetailViewModel>(
      () => NotebookDetailViewModel(
        notebookService: di.get<NotebookApiService>(),
        documentService: di.get<DocumentReferenceApiService>(),
        tagService: di.get<TagApiService>(),
        dio: di.get<Dio>(),
      ),
    );

    di.registerFactory<NotebookCreateViewModel>(
      () => NotebookCreateViewModel(
        notebookService: di.get<NotebookApiService>(),
      ),
    );

    // Registra Pages
    di.registerLazySingleton<NotebookListPage>(
      () => NotebookListPage(
        viewModel: di.get<NotebookListViewModel>(),
      ),
    );

    // NotebookDetailPage e NotebookFormPage são criadas via factory
    // pois precisam de argumentos dinâmicos (notebookId)

    // Registra widgets no DashboardRegistry (se disponível)
    try {
      final registry = di.get<DashboardRegistry>();
      registry.register(
        NotebookRemindersEntry(service: di.get<NotebookApiService>()),
      );
      registry.register(
        NotebookQuickNotesEntry(service: di.get<NotebookApiService>()),
      );
    } catch (_) {
      // DashboardRegistry não registrado — sem integração com dashboard
    }
  }

  @override
  Map<String, Widget> get routes => {
    routeName: di.get<NotebookListPage>(),
    // Outras rotas são tratadas dinamicamente via onGenerateRoute
  };

  @override
  List<AppNavigationItem> get navigationItems => [
    AppNavigationItem(
      labelBuilder: (context) => 'Cadernos',
      icon: Icons.book,
      section: AppNavigationSection.environment,
      route: routeName,
    ),
  ];
}
