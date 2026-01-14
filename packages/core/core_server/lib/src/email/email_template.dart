/// Represents the content of an email.
class EmailContent {
  final String subject;
  final String body;
  final bool isHtml;

  const EmailContent({
    required this.subject,
    required this.body,
    this.isHtml = false,
  });
}

/// Factory for standard email templates.
class EmailTemplate {
  final String appName;
  final String fromName;

  const EmailTemplate({
    this.appName = 'EMS System',
    this.fromName = 'EMS System',
  });

  EmailContent verification({
    required String userName,
    required String link,
  }) {
    return EmailContent(
      subject: 'Verifique seu email - $appName',
      body:
          '''
Olá $userName,

Por favor, clique no link abaixo para verificar seu email:

$link

Este link expira em 24 horas.

Atenciosamente,
$fromName
''',
    );
  }

  EmailContent passwordReset({
    required String userName,
    required String link,
    required int expirationMinutes,
  }) {
    return EmailContent(
      subject: 'Reset de Senha - $appName',
      body:
          '''
Olá $userName,

Você solicitou um reset de senha. Clique no link abaixo:

$link

Este link expira em $expirationMinutes minutos.

Se você não solicitou este reset, ignore este email.

Atenciosamente,
$fromName
''',
    );
  }

  EmailContent welcome({required String userName}) {
    return EmailContent(
      subject: 'Bem-vindo ao $appName!',
      body:
          '''
Olá $userName,

Seja bem-vindo ao $appName!

Sua conta foi criada com sucesso.

Atenciosamente,
$fromName
''',
    );
  }
}
