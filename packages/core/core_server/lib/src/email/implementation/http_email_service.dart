import 'dart:io';

import 'package:core_shared/core_shared.dart';

import '../email_service.dart';
import '../email_template.dart';

/// Configuração do serviço de email.
class EmailConfig with Loggable {
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
class HttpEmailService with Loggable implements EmailService {
  final EmailConfig config;

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
      // Implementar chamada HTTP real ao provedor
      // Exemplo Mailgun:
      // final response = await http.post(
      //   Uri.parse('${config.host}/messages'),
      //   headers: {'Authorization': 'Bearer ${config.apiKey}'},
      //   body: {...},
      // );

      // Por enquanto, log stub
      logger.info('Would send email to: $to');
      logger.info('Subject: $subject');

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
    final template = EmailTemplate(fromName: config.fromName).verification(
      userName: userName,
      link: verificationLink,
    );

    return send(to: to, subject: template.subject, body: template.body);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({
    required String to,
    required String userName,
    required String resetLink,
    required Duration expiresIn,
  }) async {
    final minutes = expiresIn.inMinutes;
    final template = EmailTemplate(fromName: config.fromName).passwordReset(
      userName: userName,
      link: resetLink,
      expirationMinutes: minutes,
    );

    return send(to: to, subject: template.subject, body: template.body);
  }

  @override
  Future<Result<void>> sendWelcomeEmail({
    required String to,
    required String userName,
  }) async {
    final template = EmailTemplate(fromName: config.fromName).welcome(
      userName: userName,
    );

    return send(to: to, subject: template.subject, body: template.body);
  }

  @override
  Future<Result<bool>> healthCheck() async {
    if (!config.isValid) {
      return const Success(false);
    }

    // Implementar ping real ao serviço
    return const Success(true);
  }
}
