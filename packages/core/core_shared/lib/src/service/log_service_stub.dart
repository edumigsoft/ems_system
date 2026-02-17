import 'dart:convert';
import 'package:logging/logging.dart';

// --- Serviço de Auditoria (Exemplo Padrão) ---
class AuditService {
  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    // ignore: avoid_print
    print('--- AUDIT LOG ---');
    // ignore: avoid_print
    print('Message: $message');
    // ignore: avoid_print
    print('Error: $error');
    if (stackTrace != null) {
      // ignore: avoid_print
      print('Stack: $stackTrace');
    }
    // ignore: avoid_print
    print('-----------------');
  }
}
// --- Fim do Serviço de Auditoria ---

enum LogLevel {
  verbose(Level.ALL),
  debug(Level.FINE),
  info(Level.INFO),
  warning(Level.WARNING),
  error(Level.SEVERE);

  const LogLevel(this.level);
  final Level level;
}

/// Serviço central de logging da aplicação.
///
/// Gerencia a configuração, inicialização e formatação de logs. Suporta múltiplos níveis de log,
/// persistência em arquivo e hooks para serviços de auditoria externos.
class LogService {
  static bool _initialized = false;
  static LogLevel? _minLevel;
  static void Function(String message, dynamic error, StackTrace? stackTrace)?
      _auditHandler;

  /// Inicializa o serviço de log.
  ///
  /// Deve ser chamado antes de qualquer operação de log na aplicação (geralmente no main).
  ///
  /// [minLevel] - O nível mínimo de severidade para registrar logs.
  /// [auditHandler] - Função opcional para lidar com logs críticos (ex: enviar para Sentry/Crashlytics).
  /// [writeToFile] - Se verdadeiro, persiste os logs em arquivo local no dispositivo (ignorado em web).
  static Future<void> init(
    LogLevel minLevel, {
    void Function(String message, dynamic error, StackTrace? stackTrace)?
        auditHandler,
    bool writeToFile = false, // Ignorado em web
  }) async {
    if (_initialized) {
      // ignore: avoid_print
      print("LogService já foi inicializado. Ignorando nova inicialização.");
      return;
    }
    _minLevel = minLevel;
    _auditHandler = auditHandler ?? AuditService.logError;

    // writeToFile é ignorado nesta implementação (web/stub)
    if (writeToFile) {
      // ignore: avoid_print
      print(
        'LogService: writeToFile não é suportado na plataforma atual (web). Logs serão apenas impressos no console.',
      );
    }

    _setupLogger();
    _initialized = true;
  }

  static void _setupLogger() {
    Logger.root.level = _minLevel?.level ?? Level.INFO;
    Logger.root.onRecord.listen((record) {
      final String formattedLog = _formatLogRecord(record);

      // ignore: avoid_print
      print(formattedLog); // Imprime no console

      // Captura e envio para auditoria se for um erro SEVERE
      if (record.level == Level.SEVERE) {
        _auditHandler?.call(record.message, record.error, record.stackTrace);
      }
    });
  }

  static String _formatLogRecord(LogRecord record) {
    // Exemplo de formato: [LEVEL - HH:MM:SS - LOGGER_NAME] MESSAGE
    return "[${record.level.name} - ${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')}:${record.time.second.toString().padLeft(2, '0')} - ${record.loggerName}] ${record.message}";
  }

  static Logger getLogger(String name) {
    if (!_initialized) {
      // ignore: avoid_print
      print(
        "LogService não foi inicializado! Chame LogService.init() primeiro.",
      );
      // Inicializa com configurações padrão como segurança
      _setupLogger();
      _initialized = true;
    }
    return Logger(name);
  }

  /// Registra um log estruturado com contexto adicional.
  ///
  /// [level] - Nível do log
  /// [message] - Mensagem principal
  /// [context] - Contexto adicional (ex: {'userId': '123', 'action': 'login'})
  /// [error] - Erro associado (opcional)
  /// [stackTrace] - Stack trace (opcional)
  static void logStructured(
    LogLevel level,
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logger = getLogger('Structured');

    final structuredMessage = StringBuffer(message);
    if (context != null && context.isNotEmpty) {
      try {
        structuredMessage.write(' | Context: ${jsonEncode(context)}');
      } catch (e) {
        structuredMessage.write(' | Context: ${context.toString()}');
      }
    }

    switch (level) {
      case LogLevel.verbose:
        logger.fine(structuredMessage.toString(), error, stackTrace);
        break;
      case LogLevel.debug:
        logger.finer(structuredMessage.toString(), error, stackTrace);
        break;
      case LogLevel.info:
        logger.info(structuredMessage.toString(), error, stackTrace);
        break;
      case LogLevel.warning:
        logger.warning(structuredMessage.toString(), error, stackTrace);
        break;
      case LogLevel.error:
        logger.severe(structuredMessage.toString(), error, stackTrace);
        break;
    }
  }
}

mixin Loggable {
  // Obtém um logger com o nome da classe que usa o mixin
  Logger get logger => LogService.getLogger(runtimeType.toString());
}
