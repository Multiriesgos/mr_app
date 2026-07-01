import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/widgets/app_logout_dialog.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';

const _tUser = User(
  documentNumber: '12345678',
  name: 'Juan Pérez',
  email: 'juan@example.com',
  docSearch: 'ABC123',
);

class _FakeAuthNotifier extends AuthNotifier {
  int logoutCalls = 0;

  @override
  Future<AuthState> build() async => const AuthAuthenticated(_tUser);

  @override
  Future<void> logout() async {
    logoutCalls++;
    state = const AsyncData(AuthUnauthenticated());
  }
}

Future<_FakeAuthNotifier> _pump(
  WidgetTester tester, {
  required TargetPlatform platform,
}) async {
  debugDefaultTargetPlatformOverride = platform;
  final notifier = _FakeAuthNotifier();

  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => Scaffold(
          body: Consumer(
            builder: (ctx, ref, _) => ElevatedButton(
              onPressed: () => showLogoutDialog(ctx, ref),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('login')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authProvider.overrideWith(() => notifier)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  return notifier;
}

/// `debugDefaultTargetPlatformOverride` debe quedar en `null` antes de que
/// el callback de `testWidgets` retorne (el chequeo de invariantes de
/// flutter_test corre justo después, antes de que se ejecuten los
/// `addTearDown`).
void _testWithPlatform(
  String description, {
  required TargetPlatform platform,
  required Future<void> Function(WidgetTester tester) body,
}) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

void main() {
  group('Android (AlertDialog)', () {
    _testWithPlatform(
      'muestra el diálogo de confirmación al abrir',
      platform: TargetPlatform.android,
      body: (tester) async {
        await _pump(tester, platform: TargetPlatform.android);
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('¿Cerrar sesión?'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Cerrar sesión'), findsOneWidget);
      },
    );

    _testWithPlatform(
      'Cancelar cierra el diálogo sin llamar a logout',
      platform: TargetPlatform.android,
      body: (tester) async {
        final notifier = await _pump(
          tester,
          platform: TargetPlatform.android,
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.text('¿Cerrar sesión?'), findsNothing);
        expect(notifier.logoutCalls, 0);
        expect(find.text('login'), findsNothing);
      },
    );

    _testWithPlatform(
      'Cerrar sesión llama a logout y navega a /login',
      platform: TargetPlatform.android,
      body: (tester) async {
        final notifier = await _pump(
          tester,
          platform: TargetPlatform.android,
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cerrar sesión'));
        await tester.pumpAndSettle();

        expect(notifier.logoutCalls, 1);
        expect(find.text('login'), findsOneWidget);
      },
    );
  });

  group('iOS (CupertinoAlertDialog)', () {
    _testWithPlatform(
      'muestra el diálogo de confirmación al abrir',
      platform: TargetPlatform.iOS,
      body: (tester) async {
        await _pump(tester, platform: TargetPlatform.iOS);
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('¿Cerrar sesión?'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Cerrar sesión'), findsOneWidget);
      },
    );

    _testWithPlatform(
      'Cerrar sesión llama a logout y navega a /login',
      platform: TargetPlatform.iOS,
      body: (tester) async {
        final notifier = await _pump(tester, platform: TargetPlatform.iOS);
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cerrar sesión'));
        await tester.pumpAndSettle();

        expect(notifier.logoutCalls, 1);
        expect(find.text('login'), findsOneWidget);
      },
    );
  });
}
