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
  String get users => 'Usuarios';

  @override
  String get user => 'Usuario';

  @override
  String get appMake => 'EduMigSoft';

  @override
  String get home => 'Home';

  @override
  String get confirmDeletion => 'Confirmar exclusión?';

  @override
  String get confirmsRestoration => 'Confirma Restauração?';

  @override
  String get areYouSureYouWantToDeleteThisItem =>
      'Tem certeza de que deseja excluir este item?';

  @override
  String get areYouSureYouWantToRestoreThisItem =>
      'Tem certeza de que deseja restaurar este item?';

  @override
  String get delete => 'Excluir';

  @override
  String get deleted => 'Excluído';

  @override
  String get restore => 'Restaurar';

  @override
  String get restored => 'Restaurado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get itemDeleted => 'Item excluído!';

  @override
  String get edit => 'Editar';

  @override
  String get registeredPleaseLoginAgain =>
      'Registrado! Faça o Login novamente.';

  @override
  String get serverCommunicationError => 'Erro de Comunicação com o Servidor';

  @override
  String get register => 'Registrar-se';

  @override
  String get name => 'Nome';

  @override
  String get enterAName => 'Entre com um Nome';

  @override
  String get email => 'Email';

  @override
  String get emailToPoint => 'Email:';

  @override
  String get enterAnEmail => 'Entre com um Email';

  @override
  String get password => 'Senha';

  @override
  String get enterAPassword => 'Entre com uma Senha';

  @override
  String get confirmPassword => 'Confirme a Senha';

  @override
  String get login => 'Conecte-se';

  @override
  String get checkYourEmailToLogin =>
      'Verifique seu email, para fazer o login.';

  @override
  String get createUser => 'Criar Usuário';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get rule => 'Acceso';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get errorWhileLogin => 'Error al iniciar sesión';

  @override
  String get checkDataWithErrors => 'Verifique los datos con errores';

  @override
  String get createProfile => 'Crear perfil';

  @override
  String get profile => 'Perfil';

  @override
  String get saveProfile => 'Guardar Perfil';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get youNeedToChangeYourPassword => 'Necesitas cambiar tu contraseña.';

  @override
  String get enterYourNewPassword => 'Introduce tu nueva contraseña.';

  @override
  String get repeatTheNewPassword => 'Repita la nueva contraseña.';

  @override
  String get recordSaved => 'Registro guardado!';

  @override
  String get forgetPassword => 'Olvidé mi contraseña';

  @override
  String get donTHaveAnAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyHaveAnAccount => '¿Ya tienes una cuenta?';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get noCoinciden => 'No coinciden';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordConfirmationIsMandatory =>
      'La confirmación de contraseña es obligatoria';

  @override
  String get close => 'Cerrar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get save => 'Guardar';

  @override
  String get userRoles => 'Roles de usuario';

  @override
  String get roles => 'Roles';

  @override
  String get selectAtLeastOneRoles => 'Seleccione al menos un rol.';

  @override
  String get logInToYourAccount => 'Entre en tu cuenta';

  @override
  String get enterYourEmail => 'Introduce tu email';

  @override
  String get enterYourPassword => 'Introduce tu contraseña';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get recoveryPassword => 'Recuperar contraseña';

  @override
  String get registerNow => 'Registrate ahora!';

  @override
  String copyright(Object year) {
    return '© $year EduMigSoft. All Rights Reserved. Designed, Anderson S. Andrade*';
  }

  @override
  String get settings => 'Configuraciones';

  @override
  String get dashboard => 'Panel';

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

  @override
  String get auth => 'Autenticación';
}
