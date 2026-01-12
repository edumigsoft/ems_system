import 'package:core_ui/core_ui.dart' show BaseNavigationViewModel;

class AppViewModel extends BaseNavigationViewModel {
  AppViewModel();

  @override
  Future<void> init() async {
    logger.info('App View Model Init');
  }

  // Future<AuthEntity?> getAuth() async {
  //   final result = await _authStorageService.getSession();

  //   // Padrão de correspondência de padrões para verificar o resultado
  //   return result.valueOrNull;
  // }
}
