// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Multimate';

  @override
  String get loginTitle => 'INGRESE AQUÍ';

  @override
  String get loginDocumentLabel => 'No. Documento';

  @override
  String get loginDocumentHint => 'Digite número documento';

  @override
  String get loginBirthdateLabel => 'Fecha de nacimiento';

  @override
  String get loginBirthdateHint => 'dd/mm/yyyy';

  @override
  String get loginRememberMe => 'Recordar cliente';

  @override
  String get loginCotizaButton => 'COTIZA';

  @override
  String get loginIngressButton => 'INGRESAR';

  @override
  String get loginValidationDocument => 'Ingrese número documento';

  @override
  String get loginValidationBirthdate => 'Digite fecha de nacimiento';

  @override
  String get loginValidationBirthdateFormat =>
      'Digite fecha en formato DD/MM/YYYY';

  @override
  String get loginErrorInvalidCredentials => 'Credenciales no válidas.';

  @override
  String get loginErrorIncompleteData =>
      'Error: Datos incompletos del servidor. Intente de nuevo.';

  @override
  String get homeWelcome => 'Bienvenido(a)';

  @override
  String get homeMyProducts => 'Mis Productos';

  @override
  String get homeBenefits => 'Beneficios';

  @override
  String get homeCallCenter => 'Llamar a MULTIRIESGOS';

  @override
  String get homeLogout => 'Cerrar sesión';

  @override
  String get errorOops => 'Oops Error!';

  @override
  String get generalRetry => 'Reintentar';

  @override
  String get generalClose => 'Cerrar';
}
