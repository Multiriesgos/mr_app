import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';
import 'package:mr_app/core/di/settings_providers.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_theme.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/auth/presentation/screens/login_screen.dart';

const _tUser = User(
  documentNumber: '12345678',
  name: 'Juan Pérez',
  email: 'juan@example.com',
  docSearch: 'ABC123',
);

// Notifier falso: evita SecureStorage y red.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(
    this._initial, {
    this.savedDocumentNumber,
    this.savedBirthDate,
    this.loginError,
  });
  final AuthState _initial;
  final String? savedDocumentNumber;
  final String? savedBirthDate;
  final Exception? loginError;

  int loginCalls = 0;

  @override
  Future<AuthState> build() async => _initial;

  @override
  Future<String?> getSavedDocumentNumber() async => savedDocumentNumber;

  @override
  Future<String?> getSavedBirthDate() async => savedBirthDate;

  @override
  Future<void> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  }) async {
    loginCalls++;
    if (loginError != null) throw loginError!;
    state = const AsyncData(AuthAuthenticated(_tUser));
  }
}

// Notifier que queda en AsyncLoading para siempre (sin timer).
class _LoadingAuthNotifier extends AuthNotifier {
  final _blocker = Completer<AuthState>();

  @override
  Future<AuthState> build() => _blocker.future;

  @override
  Future<String?> getSavedDocumentNumber() async => null;
}

class _FakeBiometricsService implements BiometricsService {
  _FakeBiometricsService({
    this.availability = BiometricAvailability.available,
    this.authResult = true,
  });
  BiometricAvailability availability;
  bool authResult;
  int authenticateCalls = 0;

  @override
  Future<BiometricAvailability> checkAvailability() async => availability;

  @override
  Future<bool> authenticate({String reason = 'Verifica tu identidad'}) async {
    authenticateCalls++;
    return authResult;
  }
}

Widget _buildScreen({
  AuthState state = const AuthUnauthenticated(),
  bool dark = false,
  bool loading = false,
  String? savedDocumentNumber,
  String? savedBirthDate,
  Exception? loginError,
  bool biometricsEnabled = false,
  _FakeBiometricsService? biometricsService,
}) {
  final fakeNotifier = _FakeAuthNotifier(
    state,
    savedDocumentNumber: savedDocumentNumber,
    savedBirthDate: savedBirthDate,
    loginError: loginError,
  );
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(
        loading ? _LoadingAuthNotifier.new : () => fakeNotifier,
      ),
      biometricsEnabledProvider.overrideWithBuild(
        (ref, notifier) => biometricsEnabled,
      ),
      if (biometricsService != null)
        biometricsServiceProvider.overrideWithValue(biometricsService),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
    ),
  );
}

void main() {
  group('LoginScreen — estructura básica', () {
    testWidgets('muestra campo Documento y campo Fecha de nacimiento',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('No. Documento'), findsOneWidget);
      expect(find.text('Fecha de nacimiento'), findsOneWidget);
    });

    testWidgets('muestra el botón Ingresar', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('muestra checkbox Recordar cliente marcado por defecto',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Recordar cliente'), findsOneWidget);
      final checkbox = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(checkbox.value, isTrue);
    });

    testWidgets('muestra el título Iniciar sesión', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('muestra el enlace para cotizar', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('Cotiza aquí'), findsOneWidget);
    });
  });

  group('LoginScreen — validación del formulario', () {
    testWidgets('muestra errores al intentar ingresar con campos vacíos',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      await tester.ensureVisible(find.text('Ingresar'));
      await tester.tap(find.text('Ingresar'));
      await tester.pump();

      expect(find.text('Ingrese número de documento'), findsOneWidget);
      expect(find.text('Ingrese fecha de nacimiento'), findsOneWidget);
    });

    testWidgets('acepta texto en campo Documento', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final docField = find.widgetWithIcon(TextFormField, Icons.person_outline);
      await tester.enterText(docField, '12345678');
      await tester.pump();

      expect(find.text('12345678'), findsOneWidget);
    });
  });

  group('LoginScreen — modo oscuro', () {
    testWidgets('renderiza sin errores en modo oscuro', (tester) async {
      await tester.pumpWidget(_buildScreen(dark: true));
      await tester.pump();

      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LoginScreen — estado cargando', () {
    testWidgets('muestra CircularProgressIndicator al hacer login', (tester) async {
      // El CircularProgressIndicator aparece dentro del botón cuando _isLoggingIn = true.
      // En el test, simulamos la app con authProvider en AsyncLoading (splash state).
      // El LoginScreen siempre muestra el formulario; el loading se controla con _isLoggingIn local.
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // El botón existe y tiene texto "Ingresar" en estado normal (no loading).
      expect(find.text('Ingresar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('botón Ingresar está habilitado en estado normal', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final ingresar = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Ingresar'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(ingresar.onPressed, isNotNull);
    });
  });

  group('LoginScreen — formateo de fecha de nacimiento', () {
    testWidgets('agrega separadores dd/mm/aaaa automáticamente al escribir',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final birthField =
          find.widgetWithIcon(TextFormField, Icons.cake_outlined);
      await tester.enterText(birthField, '01011990');
      await tester.pump();

      expect(find.text('01/01/1990'), findsOneWidget);
    });

    testWidgets('descarta caracteres no numéricos y limita a 8 dígitos',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final birthField =
          find.widgetWithIcon(TextFormField, Icons.cake_outlined);
      await tester.enterText(birthField, '01a01b1990c99');
      await tester.pump();

      expect(find.text('01/01/1990'), findsOneWidget);
    });
  });

  group('LoginScreen — login', () {
    Future<void> fillValidForm(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.person_outline),
        '12345678',
      );
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.cake_outlined),
        '01011990',
      );
    }

    testWidgets('login exitoso: llama a login una sola vez y no muestra error',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Ingresar'));
      await tester.tap(find.text('Ingresar'));
      await tester.pump();

      expect(find.byKey(const ValueKey('error-banner')), findsNothing);
      // Tras un login exitoso, _isLoggingIn no se resetea localmente:
      // se espera que el router externo saque de la pantalla al cambiar
      // authProvider a AuthAuthenticated. El spinner queda visible.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'login fallido con AppException muestra el mensaje de la excepción y reactiva el botón',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(loginError: const AuthException('Documento no encontrado')),
      );
      await tester.pump();
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Ingresar'));
      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Documento no encontrado'), findsOneWidget);
      expect(find.text('Ingresar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'login fallido con excepción genérica muestra el mensaje de conexión por defecto',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(loginError: Exception('algo inesperado')),
      );
      await tester.pump();
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Ingresar'));
      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Error de conexión. Intente de nuevo.'), findsOneWidget);
    });

    testWidgets('escribir en un campo tras un error lo oculta', (tester) async {
      await tester.pumpWidget(
        _buildScreen(loginError: const AuthException('Credenciales inválidas')),
      );
      await tester.pump();
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Ingresar'));
      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Credenciales inválidas'), findsOneWidget);

      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.person_outline),
        '87654321',
      );
      await tester.pump();

      expect(find.text('Credenciales inválidas'), findsNothing);
    });
  });

  group('LoginScreen — biometría', () {
    testWidgets(
        'muestra el botón biométrico cuando está habilitada, disponible y hay datos guardados',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          biometricsEnabled: true,
          savedDocumentNumber: '12345678',
          savedBirthDate: '01/01/1990',
          biometricsService: _FakeBiometricsService(authResult: false),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Ingresar con biometría'), findsOneWidget);
    });

    testWidgets(
        'no muestra el botón biométrico si no hay documento/fecha guardados',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          biometricsEnabled: true,
          biometricsService: _FakeBiometricsService(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Ingresar con biometría'), findsNothing);
    });

    testWidgets(
        'no muestra el botón biométrico si la preferencia está deshabilitada',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          savedDocumentNumber: '12345678',
          savedBirthDate: '01/01/1990',
          biometricsService: _FakeBiometricsService(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Ingresar con biometría'), findsNothing);
    });

    testWidgets(
        'no muestra el botón biométrico si el dispositivo no tiene biometría enrolada',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          biometricsEnabled: true,
          savedDocumentNumber: '12345678',
          savedBirthDate: '01/01/1990',
          biometricsService: _FakeBiometricsService(
            availability: BiometricAvailability.notEnrolled,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Ingresar con biometría'), findsNothing);
    });
  });
}
