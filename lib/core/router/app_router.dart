import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mr_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:mr_app/features/benefits/presentation/screens/benefit_card_screen.dart';
import 'package:mr_app/features/home/presentation/screens/home_screen.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/screens/product_detail_screen.dart';
import 'package:mr_app/features/products/presentation/screens/products_screen.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'products',
            pageBuilder: (context, state) => _slidePage(
              state: state,
              child: const ProductsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => _slidePage(
                  state: state,
                  child: ProductDetailScreen(
                    idRen: int.parse(state.pathParameters['id']!),
                    product: state.extra as Product?,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'benefits',
            pageBuilder: (context, state) => _slidePage(
              state: state,
              child: const BenefitCardScreen(),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (authAsync.isLoading || !authAsync.hasValue) {
        return loc == '/' ? null : '/';
      }

      final auth = authAsync.requireValue;

      return switch (auth) {
        AuthLoading() => loc == '/' ? null : '/',
        AuthAuthenticated() =>
          (loc == '/' || loc == '/login') ? '/home' : null,
        AuthUnauthenticated() => loc == '/login' ? null : '/login',
      };
    },
  );
});

CustomTransitionPage<void> _slidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation),
      child: child,
    ),
  );
}
