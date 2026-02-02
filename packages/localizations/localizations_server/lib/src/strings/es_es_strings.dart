import 'package:localizations_shared/localizations_shared.dart';

class EsEsStrings implements I18nStrings {
  const EsEsStrings();

  @override
  String get appName => 'Mi Aplicación';

  @override
  String get welcomeMessage => '¡Bienvenido!';

  @override
  String get errorGeneric => 'Ocurrió un error. Por favor, inténtalo de nuevo.';

  @override
  String loginError(String reason) => 'Error de inicio de sesión: $reason';

  @override
  String serverErrorLog(String error) => 'ERROR DEL SERVIDOR: $error';

  @override
  String emailSubjectWelcome(String userName) =>
      '¡Bienvenido al sistema, $userName!';

  @override
  String itemCount(int count) {
    if (count == 0) return 'Sin elementos';
    if (count == 1) return '1 elemento';
    return '$count elementos';
  }

  @override
  String lastUpdated(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return 'Última actualización: $day/$month/$year';
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

  @override
  String get school => 'Escuela';

  @override
  String get schools => 'Escuelas';

  @override
  String get editSchool => 'Editar Escuela';

  @override
  String get createSchool => 'Crear Escuela';

  @override
  String get cie => 'CIE';
}
