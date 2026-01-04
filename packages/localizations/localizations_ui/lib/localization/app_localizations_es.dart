// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Mi Aplicación';

  @override
  String get welcomeMessage => '¡Bienvenido!';

  @override
  String get errorGeneric => 'Ocurrió un error. Por favor, inténtalo de nuevo.';

  @override
  String loginError(String reason) {
    return 'Error de inicio de sesión: $reason';
  }

  @override
  String serverErrorLog(String error) {
    return 'ERROR DEL SERVIDOR: $error';
  }

  @override
  String emailSubjectWelcome(String userName) {
    return '¡Bienvenido al sistema, $userName!';
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
      other: '$countString elementos',
      one: '1 elemento',
      zero: 'Sin elementos',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Última actualización: $dateString';
  }

  @override
  String get buttonSave => 'Guardar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonConfirm => 'Confirmar';

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get validationEmailInvalid =>
      'Por favor, introduce una dirección de correo válida';

  @override
  String get validationPasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get validationRequired => 'Este campo es obligatorio';
}
