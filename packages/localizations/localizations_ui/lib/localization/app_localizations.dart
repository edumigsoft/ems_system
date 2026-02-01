import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// EduMigSoft System Management
  ///
  /// In en, this message translates to:
  /// **'EMS System'**
  String get appName;

  /// Welcome message shown on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeMessage;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneric;

  /// Label for Users section
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Label for a single User
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// EduMigSoft
  ///
  /// In en, this message translates to:
  /// **'EduMigSoft'**
  String get appMake;

  /// Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Confirmar exclusão
  ///
  /// In en, this message translates to:
  /// **'Confirmar exclusão?'**
  String get confirmDeletion;

  /// Confirma Restauração?
  ///
  /// In en, this message translates to:
  /// **'Confirma Restauração?'**
  String get confirmsRestoration;

  /// Are you sure you want to delete this item?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get areYouSureYouWantToDeleteThisItem;

  /// Are you sure you want to restore this item?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore this item?'**
  String get areYouSureYouWantToRestoreThisItem;

  /// Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// Restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Restored
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Item deleted!
  ///
  /// In en, this message translates to:
  /// **'Item deleted!'**
  String get itemDeleted;

  /// Edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Label for a school
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// Label for multiple schools
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get schools;

  /// Button to edit a school
  ///
  /// In en, this message translates to:
  /// **'Edit School'**
  String get editSchool;

  /// Button to create a new school
  ///
  /// In en, this message translates to:
  /// **'Create School'**
  String get createSchool;

  /// CIE (School Identification Code)
  ///
  /// In en, this message translates to:
  /// **'CIE'**
  String get cie;

  /// Registered! Please login again.
  ///
  /// In en, this message translates to:
  /// **'Registered! Please login again.'**
  String get registeredPleaseLoginAgain;

  /// Server Communication Error
  ///
  /// In en, this message translates to:
  /// **'Server Communication Error'**
  String get serverCommunicationError;

  /// Register
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Enter a Name
  ///
  /// In en, this message translates to:
  /// **'Enter a Name'**
  String get enterAName;

  /// Email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email:
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get emailToPoint;

  /// Enter an Email
  ///
  /// In en, this message translates to:
  /// **'Enter an Email'**
  String get enterAnEmail;

  /// Password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Enter a Password
  ///
  /// In en, this message translates to:
  /// **'Enter a Password'**
  String get enterAPassword;

  /// Confirm Password
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Check your email to login.
  ///
  /// In en, this message translates to:
  /// **'Check your email to login.'**
  String get checkYourEmailToLogin;

  /// Create User
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get createUser;

  /// Active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Access
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get rule;

  /// Sign In
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign Up
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Error while logging in
  ///
  /// In en, this message translates to:
  /// **'Error while logging in'**
  String get errorWhileLogin;

  /// Check data with errors
  ///
  /// In en, this message translates to:
  /// **'Check data with errors'**
  String get checkDataWithErrors;

  /// Create profile
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get createProfile;

  /// Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Save Profile
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// Change Password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// You need to change your password.
  ///
  /// In en, this message translates to:
  /// **'You need to change your password.'**
  String get youNeedToChangeYourPassword;

  /// Enter your new password.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password.'**
  String get enterYourNewPassword;

  /// Repeat the new password.
  ///
  /// In en, this message translates to:
  /// **'Repeat the new password.'**
  String get repeatTheNewPassword;

  /// Record saved!
  ///
  /// In en, this message translates to:
  /// **'Record saved!'**
  String get recordSaved;

  /// Forget Password
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forgetPassword;

  /// Don't have an account?
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get donTHaveAnAccount;

  /// Already have an account?
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// Welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Do not match
  ///
  /// In en, this message translates to:
  /// **'Do not match'**
  String get noCoinciden;

  /// Passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Password confirmation is mandatory
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is mandatory'**
  String get passwordConfirmationIsMandatory;

  /// Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// User roles
  ///
  /// In en, this message translates to:
  /// **'User roles'**
  String get userRoles;

  /// Roles
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// Select at least one role.
  ///
  /// In en, this message translates to:
  /// **'Select at least one role.'**
  String get selectAtLeastOneRoles;

  /// Log in to your account
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get logInToYourAccount;

  /// Enter your email
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Enter your password
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Remember me
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Recover password
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get recoveryPassword;

  /// Register now!
  ///
  /// In en, this message translates to:
  /// **'Register now!'**
  String get registerNow;

  /// © 2025 EduMigSoft. All Rights Reserved. Designed, Anderson S. Andrade*
  ///
  /// In en, this message translates to:
  /// **'© {year} EduMigSoft. All Rights Reserved. Designed, Anderson S. Andrade*'**
  String copyright(Object year);

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {reason}'**
  String loginError(Object reason);

  /// No description provided for @serverErrorLog.
  ///
  /// In en, this message translates to:
  /// **'SERVER ERROR: {error}'**
  String serverErrorLog(Object error);

  /// No description provided for @emailSubjectWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the system, {userName}!'**
  String emailSubjectWelcome(Object userName);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(num count);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(Object date);

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @auth.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get auth;

  /// Remember me checkbox label
  ///
  /// In en, this message translates to:
  /// **'Remember me on this device'**
  String get authRememberMeLabel;

  /// Message when remember me is active
  ///
  /// In en, this message translates to:
  /// **'Session active for 7 days'**
  String get authRememberMeSessionActive;

  /// Message when remember me is disabled
  ///
  /// In en, this message translates to:
  /// **'Session expires in 15 minutes'**
  String get authRememberMeSessionExpires;

  /// Session expiration dialog title
  ///
  /// In en, this message translates to:
  /// **'Your session is expiring'**
  String get authSessionExpiringTitle;

  /// Session expiration dialog message
  ///
  /// In en, this message translates to:
  /// **'Your session will expire soon. Do you want to renew now or logout?'**
  String get authSessionExpiringMessage;

  /// Button to renew session
  ///
  /// In en, this message translates to:
  /// **'Renew Now'**
  String get authRenewSession;

  /// Button to logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// Success message when session is renewed
  ///
  /// In en, this message translates to:
  /// **'Session renewed successfully'**
  String get authSessionRenewed;

  /// Error message when session renewal fails
  ///
  /// In en, this message translates to:
  /// **'Error renewing session. Please login again.'**
  String get authSessionRenewalError;

  /// My Profile
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Manage Users
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// System Management
  ///
  /// In en, this message translates to:
  /// **'System Management'**
  String get systemManagement;

  /// Saved successfully
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// The name cannot be empty!
  ///
  /// In en, this message translates to:
  /// **'The name cannot be empty!'**
  String get theNameCannotBeEmpty;

  /// Cannot be empty!
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty!'**
  String get cannotBeEmpty;

  /// Address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Phone
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Success message when creating school
  ///
  /// In en, this message translates to:
  /// **'School created successfully!'**
  String get schoolCreateSuccess;

  /// Success message when updating school
  ///
  /// In en, this message translates to:
  /// **'School updated successfully!'**
  String get schoolUpdateSuccess;

  /// Success message when deleting school
  ///
  /// In en, this message translates to:
  /// **'School deleted!'**
  String get schoolDeleteSuccess;

  /// Success message when restoring school
  ///
  /// In en, this message translates to:
  /// **'School restored successfully!'**
  String get schoolRestoreSuccess;

  /// Confirmation of school deletion
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the school?'**
  String get schoolDeleteConfirm;

  /// Confirmation of school restoration
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore the school?'**
  String get schoolRestoreConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
