import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/theme/app_theme.dart';
import 'package:mr_app/core/widgets/app_avatar.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/home/presentation/screens/home_tab.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';

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

class _FakeProductsNotifier extends ProductsNotifier {
  _FakeProductsNotifier(this._products);
  final List<Product> _products;

  @override
  Future<List<Product>> build() async => _products;
}

class _LoadingProductsNotifier extends ProductsNotifier {
  final _blocker = Completer<List<Product>>();

  @override
  Future<List<Product>> build() => _blocker.future;
}

Widget _buildHomeTab({
  bool dark = false,
  List<Product>? products,
  ValueChanged<int>? onTabChange,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(
        () => _FakeAuthNotifier(const AuthAuthenticated(_tUser)),
      ),
      if (products != null)
        productsProvider.overrideWith(() => _FakeProductsNotifier(products))
      else
        productsProvider.overrideWith(_LoadingProductsNotifier.new),
      homeContactProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: HomeTab(user: _tUser, onTabChange: onTabChange),
    ),
  );
}

Product _product({
  required int idRen,
  required String tipoSeguro,
  int? diasParaRenovar,
}) => Product(
      idRen: idRen,
      ramo: 'DAÑOS',
      tipoSeguro: tipoSeguro,
      aseguradora: 'ACSA',
      asegurado: 'JUAN PÉREZ',
      placa: 'P123456',
      fechaRenovacion: diasParaRenovar == null
          ? null
          : DateTime.now().add(Duration(days: diasParaRenovar)),
    );

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

  group('HomeTab — estado cargando', () {
    testWidgets('muestra skeletons de stats y renovaciones mientras carga',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab());
      await tester.pump();

      expect(find.text('PRÓXIMAS RENOVACIONES'), findsNothing);
      // Los skeletons no tienen texto, pero la sección de acceso rápido
      // siempre está presente independientemente del estado de carga.
      expect(find.text('ACCESO RÁPIDO'), findsOneWidget);
    });
  });

  group('HomeTab — stats row', () {
    testWidgets('cuenta correctamente vigentes, por vencer y total', (tester) async {
      final products = [
        _product(idRen: 1, tipoSeguro: 'AUTOMOTORES', diasParaRenovar: 60), // vigente
        _product(idRen: 2, tipoSeguro: 'VIDA', diasParaRenovar: 10), // por vencer
        _product(idRen: 3, tipoSeguro: 'INCENDIO'), // sin fecha -> vigente
      ];

      await tester.pumpWidget(_buildHomeTab(products: products));
      // Los contadores animan con TweenAnimationBuilder (AppMotion.slow01).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('3'), findsOneWidget); // total
      expect(find.text('Pólizas'), findsOneWidget); // singular/plural correcto
      expect(find.text('2'), findsOneWidget); // vigentes
      expect(find.text('Vigentes'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // por vencer
      expect(find.text('Por vencer'), findsOneWidget);
    });

    testWidgets('muestra "Vencidas" en vez de "Por vencer" cuando hay pólizas vencidas',
        (tester) async {
      final products = [
        _product(idRen: 1, tipoSeguro: 'AUTOMOTORES', diasParaRenovar: -5), // vencida
      ];

      await tester.pumpWidget(_buildHomeTab(products: products));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Vencidas'), findsOneWidget);
      expect(find.text('Por vencer'), findsNothing);
    });

    testWidgets('no muestra stats row cuando la lista de pólizas está vacía',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab(products: const []));
      await tester.pump();

      expect(find.text('Vigentes'), findsNothing);
    });
  });

  group('HomeTab — alertas de renovación', () {
    testWidgets('muestra solo pólizas dentro de la ventana -7..30 días',
        (tester) async {
      final products = [
        _product(idRen: 1, tipoSeguro: 'DENTRO_VENTANA', diasParaRenovar: 15),
        _product(idRen: 2, tipoSeguro: 'FUERA_VENTANA', diasParaRenovar: 60),
        _product(idRen: 3, tipoSeguro: 'VENCIDA_RECIENTE', diasParaRenovar: -5),
        _product(idRen: 4, tipoSeguro: 'VENCIDA_VIEJA', diasParaRenovar: -30),
      ];

      await tester.pumpWidget(_buildHomeTab(products: products));
      await tester.pump();

      expect(find.text('PRÓXIMAS RENOVACIONES'), findsOneWidget);
      expect(find.text('DENTRO_VENTANA'), findsOneWidget);
      expect(find.text('VENCIDA_RECIENTE'), findsOneWidget);
      expect(find.text('FUERA_VENTANA'), findsNothing);
      expect(find.text('VENCIDA_VIEJA'), findsNothing);
    });

    testWidgets('deslizar una alerta la oculta de la lista', (tester) async {
      final products = [
        _product(idRen: 1, tipoSeguro: 'PRIMERA', diasParaRenovar: 5),
        _product(idRen: 2, tipoSeguro: 'SEGUNDA', diasParaRenovar: 10),
      ];

      await tester.pumpWidget(_buildHomeTab(products: products));
      await tester.pump();

      expect(find.text('PRIMERA'), findsOneWidget);
      expect(find.text('SEGUNDA'), findsOneWidget);

      await tester.drag(find.text('PRIMERA'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('PRIMERA'), findsNothing);
      expect(find.text('SEGUNDA'), findsOneWidget);
    });
  });

  group('HomeTab — sin pólizas', () {
    testWidgets('muestra banner de "Sin pólizas activas" cuando la lista está vacía',
        (tester) async {
      await tester.pumpWidget(_buildHomeTab(products: const []));
      await tester.pump();

      expect(find.text('Sin pólizas activas'), findsOneWidget);
    });

    testWidgets('no muestra el banner cuando hay pólizas', (tester) async {
      await tester.pumpWidget(
        _buildHomeTab(products: [_product(idRen: 1, tipoSeguro: 'AUTOMOTORES')]),
      );
      await tester.pump();

      expect(find.text('Sin pólizas activas'), findsNothing);
    });
  });

  group('HomeTab — acceso rápido', () {
    testWidgets('tocar "Mis pólizas" llama a onTabChange con el índice 2',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        _buildHomeTab(products: const [], onTabChange: (i) => tappedIndex = i),
      );
      await tester.pump();

      await tester.tap(find.text('Mis pólizas'));
      await tester.pump();

      expect(tappedIndex, 2);
    });

    testWidgets('tocar el avatar del perfil llama a onTabChange con el índice 3',
        (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        _buildHomeTab(products: const [], onTabChange: (i) => tappedIndex = i),
      );
      await tester.pump();

      await tester.tap(find.byType(AppAvatar));
      await tester.pump();

      expect(tappedIndex, 3);
    });
  });
}
