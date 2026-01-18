import 'package:ems_system_core_shared/core_shared.dart'
    show LogService, LogLevel;
import 'package:flutter/material.dart';
import 'main.dart' as app;

void main() async {
  // Inicializa os bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o serviço de log com o nível mínimo para STAGING e log em arquivo
  await LogService.init(
    LogLevel.info, // Mostra info, warning, error
    writeToFile: true, // Habilita log em arquivo em staging
  );

  // Opcional: Log para confirmar o ambiente
  final logger = LogService.getLogger('Environment');
  logger.info('Running in STAGING environment with info+ logging.');

  app.main();
}
