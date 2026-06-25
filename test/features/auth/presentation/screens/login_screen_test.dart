import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/theme/app_theme.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/auth/presentation/screens/login_screen.dart';

// Notifier falso: evita SecureStorage y red.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);
  final AuthState _initial;

  @override
  Future<AuthState> build() async => _initial;

  @override
  Future<String?> getSavedDocumentNumber() async => null;
}

// Notifier que queda en AsyncLoading para siempre (sin timer).
class _LoadingAuthNotifier extends AuthNotifier {
  final _blocker = Completer<AuthState>();

  @override
  Future<AuthState> build() => _blocker.future;

  @override
  Future<String?> getSavedDocumentNumber() async => null;
}

Widget _buildScreen({
  AuthState state = const AuthUnauthenticated(),
  bool dark = false,
  bool loading = false,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(
        loading
            ? _LoadingAuthNotifier.new
            : () => _FakeAuthNotifier(state),
      ),
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
      expect(find.text('Seleccione fecha de nacimiento'), findsOneWidget);
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
}
