import 'dart:io';
import 'package:logging/logging.dart';
import 'package:core_shared/core_shared.dart';
import '../email_service.dart';

/// Configuração do serviço de email.
class EmailConfig {
  /// Host do serviço SMTP ou API.
  final String host;

  /// Porta do serviço.
  final int port;

  /// API Key para autenticação.
  final String apiKey;

  /// Email remetente padrão.
  final String fromEmail;

  /// Nome do remetente padrão.
  final String fromName;

  const EmailConfig({
    required this.host,
    required this.port,
    required this.apiKey,
    required this.fromEmail,
    this.fromName = 'EMS System',
  });

  /// Cria config a partir de variáveis de ambiente.
  factory EmailConfig.fromEnv() {
    return EmailConfig(
      host: Platform.environment['EMAIL_SERVICE_HOST'] ?? 'localhost',
      port:
          int.tryParse(Platform.environment['EMAIL_SERVICE_PORT'] ?? '587') ??
          587,
      apiKey: Platform.environment['EMAIL_SERVICE_API_KEY'] ?? '',
      fromEmail:
          Platform.environment['EMAIL_SERVICE_FROM'] ?? 'noreply@example.com',
      fromName: Platform.environment['EMAIL_SERVICE_FROM_NAME'] ?? 'EMS System',
    );
  }

  /// Verifica se a configuração está completa.
  bool get isValid => apiKey.isNotEmpty && fromEmail.isNotEmpty;
}

/// Implementação do EmailService usando HTTP API.
///
/// Pode ser adaptada para diferentes provedores (Mailgun, SendGrid, etc.)
/// via headers e endpoints específicos.
class HttpEmailService implements EmailService {
  final EmailConfig config;
  final Logger _log = LogService.getLogger('HttpEmailService');

  HttpEmailService(this.config);

  @override
  Future<Result<void>> send({
    required String to,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    if (!config.isValid) {
      return Failure(Exception('Email service not configured'));
    }

    try {
      // TODO: Implementar chamada HTTP real ao provedor
      // Exemplo Mailgun:
      // final response = await http.post(
      //   Uri.parse('${config.host}/messages'),
      //   headers: {'Authorization': 'Bearer ${config.apiKey}'},
      //   body: {...},
      // );

      // Por enquanto, log stub
      _log.info('Would send email to: $to');
      _log.info('Subject: $subject');

      return successOfUnit();
    } catch (e) {
      return Failure(Exception('Failed to send email: $e'));
    }
  }

  @override
  Future<Result<void>> sendVerificationEmail({
    required String to,
    required String userName,
    required String verificationLink,
  }) async {
    const subject = 'Verifique seu email - EMS System';
    final body =
        '''
      Olá $userName,

      Por favor, clique no link abaixo para verificar seu email:

      $verificationLink

      Este link expira em 24 horas.

      Atenciosamente,
      ${config.fromName}
    ''';

    return send(to: to, subject: subject, body: body);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({
    required String to,
    required String userName,
    required String resetLink,
    required Duration expiresIn,
  }) async {
    final minutes = expiresIn.inMinutes;
    const subject = 'Reset de Senha - EMS System';
    final body =
        '''
      Olá $userName,

      Você solicitou um reset de senha. Clique no link abaixo:

      $resetLink

      Este link expira em $minutes minutos.

      Se você não solicitou este reset, ignore este email.

      Atenciosamente,
      ${config.fromName}
    ''';

    return send(to: to, subject: subject, body: body);
  }

  @override
  Future<Result<void>> sendWelcomeEmail({
    required String to,
    required String userName,
  }) async {
    const subject = 'Bem-vindo ao EMS System!';
    final body =
        '''
      Olá $userName,

      Seja bem-vindo ao EMS System!

      Sua conta foi criada com sucesso.

      Atenciosamente,
      ${config.fromName}
    ''';

    return send(to: to, subject: subject, body: body);
  }

  @override
  Future<Result<bool>> healthCheck() async {
    if (!config.isValid) {
      return const Success(false);
    }

    // TODO: Implementar ping real ao serviço
    return const Success(true);
  }
}
