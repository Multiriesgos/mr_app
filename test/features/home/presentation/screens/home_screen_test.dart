import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/theme/app_theme.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/home/presentation/screens/home_tab.dart';

const _tUser = User(
  documentNumber: '12345678',
  name: 'Juan Pérez',
  email: 'juan@example.com',
  docSearch: 'ABC123',
);

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);
  final AuthState _initial;

  @override
  Future<AuthState> build() async => _initial;

  @override
  Future<String?> getSavedDocumentNumber() async => null;
}

Widget _buildHomeTab({bool dark = false}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(
        () => _FakeAuthNotifier(AuthAuthenticated(_tUser)),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeTab(user: _tUser),
    ),
  );
}

void main() {
  group('HomeTab — estructura básica', () {
    testWidgets('muestra saludo "Bienvenido," en el AppBar', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('Bienvenido,'), findsOneWidget);
    });

    testWidgets('muestra el nombre del usuario en mayúsculas en el AppBar',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('JUAN PÉREZ'), findsOneWidget);
    });

    testWidgets('muestra el título principal de bienvenida', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('Bienvenido a Multimate'), findsOneWidget);
    });

    testWidgets('muestra botones de soporte y logout en AppBar', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      final inAppBar = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.support_agent_outlined),
      );
      expect(inAppBar, findsOneWidget);
      expect(find.byIcon(Icons.logout_outlined), findsOneWidget);
    });

    testWidgets('muestra el subtítulo de la app', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('Tu app de seguros y beneficios'), findsOneWidget);
    });
  });

  group('HomeTab — modo oscuro', () {
    testWidgets('renderiza sin errores en modo oscuro', (tester) async {
      await tester.pumpWidget(_buildHomeTab(dark: true));
      await tester.pump();

      expect(find.text('Bienvenido,'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('contiene los mismos elementos en dark y light', (tester) async {
      // Light
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();
      expect(find.text('Bienvenido a Multimate'), findsOneWidget);

      // Dark
      await tester.pumpWidget(_buildHomeTab(dark: true));
      await tester.pump();
      expect(find.text('Bienvenido a Multimate'), findsOneWidget);
    });
  });

  group('HomeTab — accesibilidad', () {
    testWidgets('botón de soporte tiene Semantics con label descriptivo',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      final semantics = tester.getSemantics(
        find.bySemanticsLabel('Llamar al centro de atención'),
      );
      expect(semantics.label, 'Llamar al centro de atención');
    });

    testWidgets('botón de logout tiene Semantics con label descriptivo',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      final semantics =
          tester.getSemantics(find.bySemanticsLabel('Cerrar sesión'));
      expect(semantics.label, 'Cerrar sesión');
    });
  });
}
