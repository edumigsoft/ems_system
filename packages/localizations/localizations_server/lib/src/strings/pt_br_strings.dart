import 'package:localizations_shared/localizations_shared.dart';

class PtBrStrings implements I18nStrings {
  const PtBrStrings();

  @override
  String get appName => 'Minha Aplicação';

  @override
  String get welcomeMessage => 'Bem-vindo!';

  @override
  String get errorGeneric => 'Ocorreu um erro. Por favor, tente novamente.';

  @override
  String loginError(String reason) => 'Falha no login: $reason';

  @override
  String serverErrorLog(String error) => 'ERRO DO SERVIDOR: $error';

  @override
  String emailSubjectWelcome(String userName) =>
      'Bem-vindo ao sistema, $userName!';

  @override
  String itemCount(int count) {
    if (count == 0) return 'Nenhum item';
    if (count == 1) return '1 item';
    return '$count itens';
  }

  @override
  String lastUpdated(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return 'Última atualização: $day/$month/$year';
  }

  @override
  String get buttonSave => 'Salvar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonConfirm => 'Confirmar';

  @override
  String get buttonDelete => 'Excluir';

  @override
  String get validationEmailInvalid =>
      'Por favor, insira um endereço de e-mail válido';

  @override
  String get validationPasswordTooShort =>
      'A senha deve ter pelo menos 8 caracteres';

  @override
  String get validationRequired => 'Este campo é obrigatório';

  @override
  String get school => 'Escola';

  @override
  String get schools => 'Escolas';

  @override
  String get editSchool => 'Editar Escola';

  @override
  String get createSchool => 'Criar Escola';

  @override
  String get cie => 'CIE';
}
