import 'package:core_shared/core_shared.dart'
    show DependencyInjector, LogService;

Future<void> initData(DependencyInjector di) async {
  final logger = LogService.getLogger('initData');
  logger.info('Dados iniciais configurados (via módulos).');
}
