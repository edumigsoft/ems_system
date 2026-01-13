import 'package:core_shared/core_shared.dart';

/// Contrato para serviço de envio de emails.
///
/// Abstrai o provedor de email usado (Mailgun, SendGrid, SMTP, etc.)
abstract class EmailService {
  /// Envia um email simples.
  Future<Result<void>> send({
    required String to,
    required String subject,
    required String body,
    bool isHtml = false,
  });

  /// Envia email de verificação de conta.
  Future<Result<void>> sendVerificationEmail({
    required String to,
    required String userName,
    required String verificationLink,
  });

  /// Envia email de reset de senha.
  Future<Result<void>> sendPasswordResetEmail({
    required String to,
    required String userName,
    required String resetLink,
    required Duration expiresIn,
  });

  /// Envia email de boas-vindas após registro.
  Future<Result<void>> sendWelcomeEmail({
    required String to,
    required String userName,
  });

  /// Verifica se o serviço está configurado e operacional.
  Future<Result<bool>> healthCheck();
}
