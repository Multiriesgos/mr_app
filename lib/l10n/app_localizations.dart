import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('en')
  ];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Multimate'**
  String get appName;

  /// Título de la pantalla de login
  ///
  /// In es, this message translates to:
  /// **'INGRESE AQUÍ'**
  String get loginTitle;

  /// Label campo número de documento
  ///
  /// In es, this message translates to:
  /// **'No. Documento'**
  String get loginDocumentLabel;

  /// Hint del campo documento
  ///
  /// In es, this message translates to:
  /// **'Digite número documento'**
  String get loginDocumentHint;

  /// Label del campo fecha de nacimiento
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get loginBirthdateLabel;

  /// Hint del campo fecha
  ///
  /// In es, this message translates to:
  /// **'dd/mm/yyyy'**
  String get loginBirthdateHint;

  /// Texto del checkbox recordar
  ///
  /// In es, this message translates to:
  /// **'Recordar cliente'**
  String get loginRememberMe;

  /// Botón de cotización externa
  ///
  /// In es, this message translates to:
  /// **'COTIZA'**
  String get loginCotizaButton;

  /// Botón de ingreso/login
  ///
  /// In es, this message translates to:
  /// **'INGRESAR'**
  String get loginIngressButton;

  /// Validación campo documento vacío
  ///
  /// In es, this message translates to:
  /// **'Ingrese número documento'**
  String get loginValidationDocument;

  /// Validación campo fecha vacío
  ///
  /// In es, this message translates to:
  /// **'Digite fecha de nacimiento'**
  String get loginValidationBirthdate;

  /// Validación formato fecha
  ///
  /// In es, this message translates to:
  /// **'Digite fecha en formato DD/MM/YYYY'**
  String get loginValidationBirthdateFormat;

  /// Error de credenciales
  ///
  /// In es, this message translates to:
  /// **'Credenciales no válidas.'**
  String get loginErrorInvalidCredentials;

  /// Error datos servidor
  ///
  /// In es, this message translates to:
  /// **'Error: Datos incompletos del servidor. Intente de nuevo.'**
  String get loginErrorIncompleteData;

  /// Saludo de bienvenida en home
  ///
  /// In es, this message translates to:
  /// **'Bienvenido(a)'**
  String get homeWelcome;

  /// Módulo Mis Productos
  ///
  /// In es, this message translates to:
  /// **'Mis Productos'**
  String get homeMyProducts;

  /// Módulo Beneficios
  ///
  /// In es, this message translates to:
  /// **'Beneficios'**
  String get homeBenefits;

  /// Botón llamar al call center
  ///
  /// In es, this message translates to:
  /// **'Llamar a MULTIRIESGOS'**
  String get homeCallCenter;

  /// Opción cerrar sesión en drawer
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get homeLogout;

  /// Título de snackbar de error
  ///
  /// In es, this message translates to:
  /// **'Oops Error!'**
  String get errorOops;

  /// Botón reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get generalRetry;

  /// Botón cerrar
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get generalClose;
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
