// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Multimate';

  @override
  String get loginTitle => 'SIGN IN';

  @override
  String get loginDocumentLabel => 'Document No.';

  @override
  String get loginDocumentHint => 'Enter document number';

  @override
  String get loginBirthdateLabel => 'Date of birth';

  @override
  String get loginBirthdateHint => 'dd/mm/yyyy';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginCotizaButton => 'QUOTE';

  @override
  String get loginIngressButton => 'SIGN IN';

  @override
  String get loginValidationDocument => 'Enter document number';

  @override
  String get loginValidationBirthdate => 'Enter date of birth';

  @override
  String get loginValidationBirthdateFormat =>
      'Enter date in DD/MM/YYYY format';

  @override
  String get loginErrorInvalidCredentials => 'Invalid credentials.';

  @override
  String get loginErrorIncompleteData =>
      'Error: Incomplete server data. Please try again.';

  @override
  String get homeWelcome => 'Welcome';

  @override
  String get homeMyProducts => 'My Products';

  @override
  String get homeBenefits => 'Benefits';

  @override
  String get homeCallCenter => 'Call MULTIRIESGOS';

  @override
  String get homeLogout => 'Sign out';

  @override
  String get errorOops => 'Oops! Error';

  @override
  String get generalRetry => 'Retry';

  @override
  String get generalClose => 'Close';
}
