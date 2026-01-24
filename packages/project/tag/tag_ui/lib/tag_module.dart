import 'package:core_shared/core_shared.dart' show DependencyInjector, Loggable;
import 'package:core_ui/core_ui.dart'
    show AppModule, AppNavigationItem, AppNavigationSection;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tag_client/tag_client.dart'
    show TagApiService, TagRepositoryImpl;
import 'package:tag_shared/tag_shared.dart'
    show
        TagRepository,
        CreateTagUseCase,
        GetAllTagsUseCase,
        GetTagByIdUseCase,
        UpdateTagUseCase,
        DeleteTagUseCase;

import 'ui/pages/tag_list_page.dart';
import 'ui/view_models/tag_view_model.dart';

/// Tag feature module.
///
/// Provides tag management functionality including CRUD operations
/// and UI for listing and managing tags.
class TagModule extends AppModule with Loggable {
  final DependencyInjector di;

  TagModule({required this.di});

  static const String routeName = '/tags';

  @override
  void registerDependencies(DependencyInjector di) {
    logger.info('registerDependencies');

    // Register API Service (Retrofit)
    di.registerLazySingleton<TagApiService>(
      () => TagApiService(di.get<Dio>()),
    );

    // Register Repository
    di.registerLazySingleton<TagRepository>(
      () => TagRepositoryImpl(di.get<TagApiService>()),
    );

    // Register Use Cases
    di.registerLazySingleton<CreateTagUseCase>(
      () => CreateTagUseCase(di.get<TagRepository>()),
    );

    di.registerLazySingleton<GetAllTagsUseCase>(
      () => GetAllTagsUseCase(di.get<TagRepository>()),
    );

    di.registerLazySingleton<GetTagByIdUseCase>(
      () => GetTagByIdUseCase(di.get<TagRepository>()),
    );

    di.registerLazySingleton<UpdateTagUseCase>(
      () => UpdateTagUseCase(di.get<TagRepository>()),
    );

    di.registerLazySingleton<DeleteTagUseCase>(
      () => DeleteTagUseCase(di.get<TagRepository>()),
    );

    // Register ViewModel
    di.registerLazySingleton<TagViewModel>(
      () => TagViewModel(
        di.get<GetAllTagsUseCase>(),
        di.get<CreateTagUseCase>(),
        di.get<UpdateTagUseCase>(),
        di.get<DeleteTagUseCase>(),
      ),
    );

    // Register Pages
    di.registerFactory<TagListPage>(
      () => TagListPage(viewModel: di.get<TagViewModel>()),
    );
  }

  @override
  Map<String, Widget> get routes => {
        routeName: di.get<TagListPage>(),
      };

  @override
  List<AppNavigationItem> get navigationItems => [
        AppNavigationItem(
          labelBuilder: (context) => 'Tags',
          icon: Icons.label,
          route: routeName,
          section: AppNavigationSection.system,
        ),
      ];
}
