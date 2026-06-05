import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/theme/app_theme.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
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
  // Completer nunca completado → no genera timer → no falla el test.
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
            ? () => _LoadingAuthNotifier()
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

    testWidgets('muestra los botones COTIZA e INGRESAR', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('COTIZA'), findsOneWidget);
      expect(find.text('INGRESAR'), findsOneWidget);
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

    testWidgets('muestra el texto INGRESE AQUÍ', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('INGRESE AQUÍ'), findsOneWidget);
    });
  });

  group('LoginScreen — validación del formulario', () {
    testWidgets('muestra errores al intentar ingresar con campos vacíos',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Hacer scroll hasta INGRESAR para asegurar que está en pantalla.
      await tester.ensureVisible(find.text('INGRESAR'));
      await tester.tap(find.text('INGRESAR'));
      await tester.pump();

      expect(find.text('Ingrese número documento'), findsOneWidget);
      expect(find.text('Digite fecha de nacimiento'), findsOneWidget);
    });

    testWidgets('acepta texto en campo Documento', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final docField = find.widgetWithIcon(TextFormField, Icons.person);
      await tester.enterText(docField, '12345678');
      await tester.pump();

      expect(find.text('12345678'), findsOneWidget);
    });
  });

  group('LoginScreen — modo oscuro', () {
    testWidgets('renderiza sin errores en modo oscuro', (tester) async {
      await tester.pumpWidget(_buildScreen(dark: true));
      await tester.pump();

      expect(find.text('INGRESE AQUÍ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LoginScreen — estado cargando', () {
    testWidgets('muestra LinearProgressIndicator mientras carga', (tester) async {
      await tester.pumpWidget(_buildScreen(loading: true));
      // Primer pump inicia el notifier; necesita un tick para procesar.
      await tester.pump();
      await tester.pump();

      // La pantalla muestra un indicador de progreso lineal en carga.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('deshabilita botón INGRESAR mientras authProvider carga',
        (tester) async {
      await tester.pumpWidget(_buildScreen(loading: true));
      await tester.pump();
      await tester.pump();

      // Busca el ElevatedButton que contiene "INGRESAR"
      final ingresar = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('INGRESAR'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(ingresar.onPressed, isNull);
    });
  });
}
