// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Minha Aplicação';

  @override
  String get welcomeMessage => 'Bem-vindo!';

  @override
  String get errorGeneric => 'Ocorreu um erro. Por favor, tente novamente.';

  @override
  String get users => 'Usuários';

  @override
  String get user => 'Usuário';

  @override
  String loginError(String reason) {
    return 'Falha no login: $reason';
  }

  @override
  String serverErrorLog(String error) {
    return 'ERRO DO SERVIDOR: $error';
  }

  @override
  String emailSubjectWelcome(String userName) {
    return 'Bem-vindo ao sistema, $userName!';
  }

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Última atualização: $dateString';
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
}
