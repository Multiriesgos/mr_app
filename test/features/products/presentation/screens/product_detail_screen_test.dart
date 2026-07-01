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
import 'package:mr_app/features/products/presentation/screens/product_detail_screen.dart';

// ── Notifiers falsos ───────────────────────────────────────────────────────────

class _FakeDetailNotifier extends ProductDetailNotifier {
  _FakeDetailNotifier(this._product, [this._contact]) : super(_kIdRen);
  final Product      _product;
  final ContactInfo? _contact;

  @override
  Future<(Product, ContactInfo?)> build() async => (_product, _contact);
}

class _ErrorDetailNotifier extends ProductDetailNotifier {
  _ErrorDetailNotifier() : super(_kIdRen);

  @override
  Future<(Product, ContactInfo?)> build() async =>
      throw const NetworkException();
}

class _LoadingDetailNotifier extends ProductDetailNotifier {
  _LoadingDetailNotifier() : super(_kIdRen);
  final _blocker = Completer<(Product, ContactInfo?)>();

  @override
  Future<(Product, ContactInfo?)> build() => _blocker.future;
}

// ── Datos de prueba ────────────────────────────────────────────────────────────

const _kIdRen = 42;

final _tProductBasic = Product(
  idRen: _kIdRen,
  ramo: 'DAÑOS',
  tipoSeguro: 'AUTOMOTORES',
  aseguradora: 'ACSA',
  asegurado: 'JUAN PÉREZ',
  placa: 'P123456',
  fechaRenovacion: DateTime.now().add(const Duration(days: 60)),
);

final _tProductWithAdjunto = Product(
  idRen: _kIdRen,
  ramo: 'VIDA',
  tipoSeguro: 'Individual',
  aseguradora: 'SEGUROS SA',
  asegurado: 'MARÍA LÓPEZ',
  placa: '',
  adjunto: 'POL-2024-001',
  fechaRenovacion: DateTime.now().add(const Duration(days: 60)),
);

final _tProductExpiring = Product(
  idRen: _kIdRen,
  ramo: 'INCENDIO',
  tipoSeguro: 'Comercial',
  aseguradora: 'SISA',
  asegurado: 'EMPRESA SA',
  placa: '',
  fechaRenovacion: DateTime.now().add(const Duration(days: 10)),
);

const _tContact = ContactInfo(phone: '21234567', whatsapp: '79876543');

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _buildScreen(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/product/$_kIdRen',
    routes: [
      GoRoute(
        path: '/product/:id',
        builder: (_, __) => const ProductDetailScreen(idRen: _kIdRen),
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
  group('ProductDetailScreen — estado cargando', () {
    testWidgets('muestra skeleton mientras carga', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2((_) => _LoadingDetailNotifier()),
        ]),
      );
      await tester.pump();

      expect(find.byType(SkeletonProductDetail), findsOneWidget);
    });
  });

  group('ProductDetailScreen — error de red', () {
    // ShimmerBox usa AnimationController.repeat() → no pumpAndSettle

    testWidgets('muestra icono de error cuando falla la conexión', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2((_) => _ErrorDetailNotifier()),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('muestra botón Volver en estado de error', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2((_) => _ErrorDetailNotifier()),
        ]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Volver'), findsOneWidget);
    });
  });

  group('ProductDetailScreen — datos básicos', () {
    testWidgets('muestra ramo y aseguradora en el hero', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductBasic),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('DAÑOS'), findsOneWidget);
      expect(find.text('ACSA'), findsOneWidget);
    });

    testWidgets('muestra tipo de seguro y asegurado en la tarjeta de info',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductBasic),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('AUTOMOTORES'), findsOneWidget);
      expect(find.text('JUAN PÉREZ'), findsOneWidget);
    });

    testWidgets('oculta fila N.° de póliza cuando adjunto es nulo', (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductBasic), // adjunto: null
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('N.° de póliza'), findsNothing);
    });

    testWidgets(
        'muestra N.° de póliza con ícono de copia cuando adjunto está presente',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductWithAdjunto),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('N.° de póliza'), findsOneWidget);
      expect(find.text('POL-2024-001'), findsOneWidget);
      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
    });
  });

  group('ProductDetailScreen — CTA renovación', () {
    testWidgets('muestra alerta de renovación para póliza por vencer (≤30 días)',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductExpiring),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Próxima a vencer'), findsOneWidget);
    });

    testWidgets('no muestra CTA para póliza con renovación lejana (>30 días)',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductBasic), // 60 días
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Próxima a vencer'), findsNothing);
      expect(find.text('Póliza vencida'), findsNothing);
    });
  });

  group('ProductDetailScreen — contacto de cabina', () {
    testWidgets('muestra botones Llamar y WhatsApp con info de contacto',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductBasic, _tContact),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Llamar'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
    });

    testWidgets('oculta sección de contacto cuando no hay info de cabina',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen([
          productDetailProvider.overrideWith2(
            (_) => _FakeDetailNotifier(_tProductBasic), // contact: null
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contacto de cabina'), findsNothing);
      expect(find.text('Llamar'), findsNothing);
    });
  });
}
