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
  String get school => 'Escuela';

  @override
  String get schools => 'Escuelas';

  @override
  String get editSchool => 'Editar Escuela';

  @override
  String get createSchool => 'Crear Escuela';

  @override
  String get cie => 'CIE';

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
  String loginError(Object reason) {
    return 'Error de inicio de sesión: $reason';
  }

  @override
  String serverErrorLog(Object error) {
    return 'ERROR DEL SERVIDOR: $error';
  }

  @override
  String emailSubjectWelcome(Object userName) {
    return '¡Bienvenido al sistema, $userName!';
  }

  @override
  String itemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Sin elementos',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(Object date) {
    return 'Última actualización: $date';
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

  @override
  String get authRememberMeLabel => 'Recordarme en este dispositivo';

  @override
  String get authRememberMeSessionActive => 'Sesión activa por 7 días';

  @override
  String get authRememberMeSessionExpires => 'La sesión expira en 15 minutos';

  @override
  String get authSessionExpiringTitle => 'Tu sesión está expirando';

  @override
  String get authSessionExpiringMessage =>
      'Tu sesión expirará pronto. ¿Deseas renovar ahora o cerrar sesión?';

  @override
  String get authRenewSession => 'Renovar Ahora';

  @override
  String get authLogout => 'Cerrar Sesión';

  @override
  String get authSessionRenewed => 'Sesión renovada con éxito';

  @override
  String get authSessionRenewalError =>
      'Error al renovar sesión. Inicie sesión nuevamente.';

  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get manageUsers => 'Administrar Usuarios';

  @override
  String get systemManagement => 'Gestión del Sistema';

  @override
  String get savedSuccessfully => 'Guardado exitosamente';

  @override
  String get theNameCannotBeEmpty => 'El nombre no puede estar vacío!';

  @override
  String get cannotBeEmpty => 'No puede estar vacío!';

  @override
  String get address => 'Dirección';

  @override
  String get phone => 'Teléfono';

  @override
  String get status => 'Estado';

  @override
  String get schoolCreateSuccess => '¡Escuela creada con éxito!';

  @override
  String get schoolUpdateSuccess => '¡Escuela actualizada con éxito!';

  @override
  String get schoolDeleteSuccess => '¡Escuela eliminada!';

  @override
  String get schoolRestoreSuccess => '¡Escuela restaurada con éxito!';

  @override
  String get schoolDeleteConfirm => '¿Realmente desea eliminar la escuela?';

  @override
  String get schoolRestoreConfirm => '¿Desea restaurar la escuela?';

  @override
  String get actions => 'Actions';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data found';

  @override
  String get saveSuccess => 'Saved successfully';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get restoreSuccess => 'Restored successfully';

  @override
  String get deleteConfirm => 'Do you really want to delete this item?';

  @override
  String get manager => 'Manager';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get zipCode => 'ZIP Code';

  @override
  String get district => 'District';

  @override
  String get complement => 'Complement';

  @override
  String get number => 'Number';

  @override
  String get saveError => 'Error saving';

  @override
  String get deleteError => 'Error deleting';

  @override
  String get restoreError => 'Error restoring';

  @override
  String get searchSchoolsHint => 'Search schools by name, code or city...';

  @override
  String get updateList => 'Update list';

  @override
  String get addSchool => 'Add School';

  @override
  String get schoolColumn => 'School';

  @override
  String get locationColumn => 'Location';

  @override
  String get contactColumn => 'Contact';

  @override
  String get showActiveSchools => 'Show active schools';

  @override
  String get showDeletedSchools => 'Show deleted schools';

  @override
  String get activeSchoolsLabel => 'Active';

  @override
  String get deletedSchoolsLabel => 'Deleted';

  @override
  String get schoolDeletedTooltip => 'This school was deleted';

  @override
  String get noDetailsToEdit => 'There are no details to edit.';

  @override
  String get noDetailsToSave => 'There are no details to save.';

  @override
  String get noDetailsToRestore => 'There are no details to restore.';

  @override
  String get retry => 'Try again';
}
