import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_theme.dart';
import 'package:mr_app/core/widgets/skeleton_product_list.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:mr_app/features/products/presentation/screens/products_screen.dart';

// ── Notifiers falsos ──────────────────────────────────────────────────────────

class _FakeProductsNotifier extends ProductsNotifier {
  _FakeProductsNotifier(this._products);
  final List<Product> _products;

  @override
  Future<List<Product>> build() async => _products;
}

class _ErrorProductsNotifier extends ProductsNotifier {
  @override
  Future<List<Product>> build() async => throw const NetworkException();
}

class _LoadingProductsNotifier extends ProductsNotifier {
  final _blocker = Completer<List<Product>>();

  @override
  Future<List<Product>> build() => _blocker.future;
}

// ── Datos de prueba ───────────────────────────────────────────────────────────

final _tProducts = [
  Product(
    idRen: 1,
    ramo: 'DAÑOS',
    tipoSeguro: 'AUTOMOTORES',
    aseguradora: 'ACSA',
    asegurado: 'JUAN PÉREZ',
    placa: 'P123456',
    fechaRenovacion: DateTime.now().add(const Duration(days: 60)),
  ),
  Product(
    idRen: 2,
    ramo: 'VIDA',
    tipoSeguro: 'Individual',
    aseguradora: 'SEGUROS SA',
    asegurado: 'JUAN PÉREZ',
    placa: '',
    fechaRenovacion: DateTime.now().add(const Duration(days: 15)),
  ),
];

// ── Helper ─────────────────────────────────────────────────────────────────

Widget _buildScreen(List<Override> overrides) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/home/products/:id',
        builder: (_, __) => const Scaffold(body: SizedBox()),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    retry: (_, __) => null,
    child: MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ProductsScreen — estado cargando', () {
    testWidgets('muestra skeleton mientras carga', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(_LoadingProductsNotifier.new),
        ]),
      );
      await tester.pump();

      expect(find.byType(SkeletonProductList), findsOneWidget);
    });
  });

  group('ProductsScreen — lista de pólizas', () {
    testWidgets('muestra el ramo de cada póliza', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(() => _FakeProductsNotifier(_tProducts)),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('DAÑOS'), findsWidgets);
      expect(find.text('VIDA'), findsOneWidget);
    });

    testWidgets('muestra el título con conteo de pólizas', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(() => _FakeProductsNotifier(_tProducts)),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mis pólizas (2)'), findsOneWidget);
    });

    testWidgets('póliza próxima a vencer muestra chip Renovar',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(() => _FakeProductsNotifier(_tProducts)),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Renovar'), findsOneWidget);
    });

    testWidgets('muestra FAB Cotizar', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(() => _FakeProductsNotifier(_tProducts)),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cotizar'), findsOneWidget);
    });
  });

  group('ProductsScreen — lista vacía', () {
    testWidgets('muestra estado vacío cuando no hay pólizas', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(() => _FakeProductsNotifier(const [])),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sin pólizas activas'), findsOneWidget);
    });
  });

  group('ProductsScreen — error de red', () {
    // Nota: usamos pump(Duration) en lugar de pumpAndSettle porque
    // ShimmerBox usa AnimationController.repeat() (animación infinita)
    // que impide que pumpAndSettle se estabilice.

    testWidgets('muestra icono de error cuando falla la conexión',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(_ErrorProductsNotifier.new),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('muestra botón Reintentar en estado de error', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(_ErrorProductsNotifier.new),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Reintentar'), findsWidgets);
    });
  });

  group('ProductsScreen — búsqueda', () {
    testWidgets('campo de búsqueda está presente', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(() => _FakeProductsNotifier(_tProducts)),
        ]),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(
          TextField,
          'Buscar por ramo, placa, aseguradora…',
        ),
        findsOneWidget,
      );
    });

    testWidgets('filtrar por texto muestra solo las pólizas coincidentes',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productsProvider.overrideWith(() => _FakeProductsNotifier(_tProducts)),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'VIDA');
      await tester.pumpAndSettle();

      // La póliza VIDA (tipoSeguro 'Individual') está visible.
      expect(find.text('Individual'), findsOneWidget);
      // La póliza DAÑOS (tipoSeguro 'AUTOMOTORES') está oculta.
      expect(find.text('AUTOMOTORES'), findsNothing);
    });
  });
}
