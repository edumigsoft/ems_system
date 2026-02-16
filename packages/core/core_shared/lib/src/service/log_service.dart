import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

// --- Serviço de Auditoria (Exemplo Padrão) ---
class AuditService {
  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    stdout.writeln('--- AUDIT LOG ---');
    stdout.writeln('Message: $message');
    stdout.writeln('Error: $error');
    if (stackTrace != null) {
      stdout.writeln('Stack: $stackTrace');
    }
    stdout.writeln('-----------------');
    // Exemplo de envio para uma API de auditoria (pseudocódigo)
    // await http.post(Uri.parse('https://api.auditoria.com/logs'), body: {...});
  }
}
// --- Fim do Serviço de Auditoria ---

enum LogLevel {
  verbose(Level.ALL),
  debug(Level.FINE),
  info(Level.INFO),
  warning(Level.WARNING),
  error(Level.SEVERE)
  ;

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
  static File? _logFile;
  static void Function(String message, dynamic error, StackTrace? stackTrace)?
  _auditHandler;

  /// Inicializa o serviço de log.
  ///
  /// Deve ser chamado antes de qualquer operação de log na aplicação (geralmente no main).
  ///
  /// [minLevel] - O nível mínimo de severidade para registrar logs.
  /// [auditHandler] - Função opcional para lidar com logs críticos (ex: enviar para Sentry/Crashlytics).
  /// [writeToFile] - Se verdadeiro, persiste os logs em arquivo local no dispositivo.
  static Future<void> init(
    LogLevel minLevel, {
    void Function(String message, dynamic error, StackTrace? stackTrace)?
    auditHandler,
    bool writeToFile = false, // Nova opção para log em arquivo
  }) async {
    if (_initialized) {
      stdout.writeln(
        "LogService já foi inicializado. Ignorando nova inicialização.",
      );
      return;
    }
    _minLevel = minLevel;
    _auditHandler = auditHandler ?? AuditService.logError;

    if (writeToFile) {
      await _initializeLogFile();
    }

    _setupLogger();
    _initialized = true;
  }

  static Future<void> _initializeLogFile() async {
    try {
      //   final directory = await getApplicationDocumentsDirectory();
      //   _logFile = File('${directory.path}/app_logs.txt');
      //   // Opcional: Limpar o arquivo antigo ou manter histórico
      //   await _logFile!.writeAsString(
      //     '--- Log Start ---\n',
      //     mode: FileMode.write,
      //   );
      //   print("Arquivo de log inicializado em: ${_logFile!.path}");

      // 1. Obtemos o caminho base do sistema operacional
      final directory = _getSystemDocumentsDirectory();

      // É boa prática criar uma subpasta para seu app
      final appLogFolder = Directory(
        p.join(directory.path, 'MeuAppDart', 'logs'),
      );

      // Garante que a pasta existe
      if (!await appLogFolder.exists()) {
        await appLogFolder.create(recursive: true);
      }

      // 2. Definição do arquivo
      _logFile = File(p.join(appLogFolder.path, 'app_logs.txt'));

      // 3. Lógica de escrita
      await _logFile!.writeAsString(
        '--- Log Start: ${DateTime.now()} ---\n',
        mode: FileMode.write, // Use FileMode.append para histórico
      );

      stdout.writeln("Arquivo de log inicializado em: ${_logFile!.path}");
    } catch (e) {
      stdout.writeln('Falha ao inicializar o arquivo de log: $e');
    }
  }

  static void _setupLogger() {
    Logger.root.level = _minLevel?.level ?? Level.INFO;
    Logger.root.onRecord.listen((record) {
      final String formattedLog = _formatLogRecord(record);

      stdout.writeln(formattedLog); // Imprime no console

      // Escreve no arquivo se estiver configurado
      if (_logFile != null) {
        _writeToFile(formattedLog);
      }

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

  /// Helper estático privado para descobrir o diretório
  static Directory _getSystemDocumentsDirectory() {
    final Map<String, String> envVars = Platform.environment;
    String homePath;

    if (Platform.isMacOS || Platform.isLinux) {
      homePath = envVars['HOME'] ?? Directory.current.path;
    } else if (Platform.isWindows) {
      homePath = envVars['USERPROFILE'] ?? Directory.current.path;
    } else {
      homePath = Directory.current.path;
    }

    return Directory(p.join(homePath, 'Documents'));
  }

  static void _writeToFile(String message) async {
    if (_logFile != null) {
      try {
        await _logFile!.writeAsString('$message\n', mode: FileMode.append);
      } catch (e) {
        stdout.writeln('Falha ao escrever log no arquivo: $e');
      }
    }
  }

  static Logger getLogger(String name) {
    if (!_initialized) {
      stdout.writeln(
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
