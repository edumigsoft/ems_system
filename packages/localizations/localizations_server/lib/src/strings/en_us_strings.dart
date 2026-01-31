import 'package:localizations_shared/localizations_shared.dart';

class EnUsStrings implements I18nStrings {
  const EnUsStrings();

  @override
  String get appName => 'My Application';

  @override
  String get welcomeMessage => 'Welcome!';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String loginError(String reason) => 'Login failed: $reason';

  @override
  String serverErrorLog(String error) => 'SERVER ERROR: $error';

  @override
  String emailSubjectWelcome(String userName) =>
      'Welcome to the system, $userName!';

  @override
  String itemCount(int count) {
    if (count == 0) return 'No items';
    if (count == 1) return '1 item';
    return '$count items';
  }

  @override
  String lastUpdated(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    return 'Last updated: $month/$day/$year';
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
  String get school => 'School';

  @override
  String get schools => 'Schools';

  @override
  String get editSchool => 'Edit School';

  @override
  String get createSchool => 'Create School';

  @override
  String get cie => 'CIE';
}
