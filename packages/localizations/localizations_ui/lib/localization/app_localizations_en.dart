// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EMS System';

  @override
  String get welcomeMessage => 'Welcome!';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get users => 'Users';

  @override
  String get user => 'User';

  @override
  String get appMake => 'EduMigSoft';

  @override
  String get home => 'Home';

  @override
  String get confirmDeletion => 'Confirmar exclusão?';

  @override
  String get confirmsRestoration => 'Confirma Restauração?';

  @override
  String get areYouSureYouWantToDeleteThisItem =>
      'Are you sure you want to delete this item?';

  @override
  String get areYouSureYouWantToRestoreThisItem =>
      'Are you sure you want to restore this item?';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Deleted';

  @override
  String get restore => 'Restore';

  @override
  String get restored => 'Restored';

  @override
  String get cancel => 'Cancel';

  @override
  String get itemDeleted => 'Item deleted!';

  @override
  String get edit => 'Edit';

  @override
  String get registeredPleaseLoginAgain => 'Registered! Please login again.';

  @override
  String get serverCommunicationError => 'Server Communication Error';

  @override
  String get register => 'Register';

  @override
  String get name => 'Name';

  @override
  String get enterAName => 'Enter a Name';

  @override
  String get email => 'Email';

  @override
  String get emailToPoint => 'Email:';

  @override
  String get enterAnEmail => 'Enter an Email';

  @override
  String get password => 'Password';

  @override
  String get enterAPassword => 'Enter a Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get login => 'Login';

  @override
  String get checkYourEmailToLogin => 'Check your email to login.';

  @override
  String get createUser => 'Create User';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get rule => 'Access';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get errorWhileLogin => 'Error while logging in';

  @override
  String get checkDataWithErrors => 'Check data with errors';

  @override
  String get createProfile => 'Create profile';

  @override
  String get profile => 'Profile';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get youNeedToChangeYourPassword => 'You need to change your password.';

  @override
  String get enterYourNewPassword => 'Enter your new password.';

  @override
  String get repeatTheNewPassword => 'Repeat the new password.';

  @override
  String get recordSaved => 'Record saved!';

  @override
  String get forgetPassword => 'Forget Password';

  @override
  String get donTHaveAnAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get welcome => 'Welcome';

  @override
  String get noCoinciden => 'Do not match';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordConfirmationIsMandatory =>
      'Password confirmation is mandatory';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get save => 'Save';

  @override
  String get userRoles => 'User roles';

  @override
  String get roles => 'Roles';

  @override
  String get selectAtLeastOneRoles => 'Select at least one role.';

  @override
  String get logInToYourAccount => 'Log in to your account';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get recoveryPassword => 'Recover password';

  @override
  String get registerNow => 'Register now!';

  @override
  String copyright(Object year) {
    return '© $year EduMigSoft. All Rights Reserved. Designed, Anderson S. Andrade*';
  }

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Dashboard';

  @override
  String loginError(String reason) {
    return 'Login failed: $reason';
  }

  @override
  String serverErrorLog(String error) {
    return 'SERVER ERROR: $error';
  }

  @override
  String emailSubjectWelcome(String userName) {
    return 'Welcome to the system, $userName!';
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
      other: '$countString items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Last updated: $dateString';
  }

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get auth => 'Authentication';

  @override
  String get authRememberMeLabel => 'Remember me on this device';

  @override
  String get authRememberMeSessionActive => 'Session active for 7 days';

  @override
  String get authRememberMeSessionExpires => 'Session expires in 15 minutes';

  @override
  String get authSessionExpiringTitle => 'Your session is expiring';

  @override
  String get authSessionExpiringMessage =>
      'Your session will expire soon. Do you want to renew now or logout?';

  @override
  String get authRenewSession => 'Renew Now';

  @override
  String get authLogout => 'Logout';

  @override
  String get authSessionRenewed => 'Session renewed successfully';

  @override
  String get authSessionRenewalError =>
      'Error renewing session. Please login again.';
}
