import 'package:core_shared/core_shared.dart' show LogService, LogLevel;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'main.dart' as app;

void main() async {
  // Inicializa os bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o serviço de log com o nível mínimo para DEVELOPMENT
  // Em web, desabilita escrita em arquivo (não é suportado)
  await LogService.init(
    LogLevel.verbose, // Mostra tudo: verbose, debug, info, warning, error
    writeToFile: !kIsWeb, // Desabilita log em arquivo em web
  );

  // Opcional: Log para confirmar o ambiente
  final logger = LogService.getLogger('Environment');
  logger.info(
    'Running in DEVELOPMENT environment with verbose logging (web: $kIsWeb).',
  );

  app.main();
}
