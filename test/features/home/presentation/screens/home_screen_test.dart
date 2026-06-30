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
        () => _FakeAuthNotifier(const AuthAuthenticated(_tUser)),
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
    testWidgets('muestra saludo dinámico en el AppBar', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      final greetings = ['Buenos días', 'Buenas tardes', 'Buenas noches'];
      final found = greetings.any((g) => find.text(g).evaluate().isNotEmpty);
      expect(found, isTrue, reason: 'Debe mostrar un saludo según la hora');
    });

    testWidgets('muestra el nombre del usuario en el AppBar',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('Juan Pérez'), findsOneWidget);
    });

    testWidgets('muestra sección ACCESO RÁPIDO', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('ACCESO RÁPIDO'), findsOneWidget);
    });

    testWidgets('muestra botón de logout en AppBar', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.byIcon(Icons.logout_outlined), findsOneWidget);
    });

    testWidgets('muestra tarjeta de soporte con ícono en el cuerpo',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.byIcon(Icons.support_agent_outlined), findsOneWidget);
    });

    testWidgets('muestra botón WhatsApp en soporte', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('muestra acciones rápidas de pólizas y carnet', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('Mis pólizas'), findsOneWidget);
      expect(find.text('Mi carnet'), findsOneWidget);
    });
  });

  group('HomeTab — modo oscuro', () {
    testWidgets('renderiza sin errores en modo oscuro', (tester) async {
      await tester.pumpWidget(_buildHomeTab(dark: true));
      await tester.pump();

      final greetings = ['Buenos días', 'Buenas tardes', 'Buenas noches'];
      final found = greetings.any((g) => find.text(g).evaluate().isNotEmpty);
      expect(found, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('contiene los mismos elementos en dark y light', (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();
      expect(find.text('ACCESO RÁPIDO'), findsOneWidget);

      await tester.pumpWidget(_buildHomeTab(dark: true));
      await tester.pump();
      expect(find.text('ACCESO RÁPIDO'), findsOneWidget);
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

    testWidgets('botón de WhatsApp tiene Semantics con label descriptivo',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      final semantics = tester.getSemantics(
        find.bySemanticsLabel('Escribir por WhatsApp al centro de atención'),
      );
      expect(semantics.label, 'Escribir por WhatsApp al centro de atención');
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
