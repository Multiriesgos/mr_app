import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/repositories/products_repository.dart';
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
}

class _FakeProductsRepository implements ProductsRepository {
  List<Product> productsResult = const [];
  bool fromCacheResult = false;
  Exception? throwOnGetProducts;

  int getProductsCalls = 0;
  int clearCacheCalls = 0;
  String? lastClearedDocSearch;

  @override
  Future<(List<Product>, bool fromCache)> getProducts(String docSearch) async {
    getProductsCalls++;
    if (throwOnGetProducts != null) throw throwOnGetProducts!;
    return (productsResult, fromCacheResult);
  }

  @override
  Future<Product> getProductDetail(int idRen) async =>
      throw UnimplementedError();

  @override
  Future<ContactInfo?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async => null;

  @override
  Future<ContactInfo?> getDefaultContactInfo() async => null;

  @override
  Future<void> clearCache(String docSearch) async {
    clearCacheCalls++;
    lastClearedDocSearch = docSearch;
  }
}

Product _product(int idRen) => Product(
      idRen: idRen,
      ramo: 'DAÑOS',
      tipoSeguro: 'AUTOMOTORES',
      aseguradora: 'ACSA',
      asegurado: 'JUAN PÉREZ',
      placa: 'P123456',
    );

void main() {
  late _FakeProductsRepository repo;

  Future<ProviderContainer> buildContainer({
    AuthState authState = const AuthAuthenticated(_tUser),
  }) async {
    repo = _FakeProductsRepository();
    final container = ProviderContainer.test(
      retry: (_, __) => null,
      overrides: [
        authProvider.overrideWith(() => _FakeAuthNotifier(authState)),
        productsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    // authProvider debe resolverse antes de leer productsProvider.future: si
    // ambos AsyncNotifierProviders se inicializan en la misma pasada (algo
    // que en la app real no ocurre porque el router ya observa authProvider
    // al arrancar), .future de productsProvider nunca se resuelve.
    await container.read(authProvider.future);
    return container;
  }

  group('build', () {
    test('devuelve lista vacía sin llamar al repositorio si no está autenticado',
        () async {
      final container = await buildContainer(authState: const AuthUnauthenticated());

      final products = await container.read(productsProvider.future);

      expect(products, isEmpty);
      expect(repo.getProductsCalls, 0);
    });

    test('devuelve las pólizas del repositorio cuando está autenticado',
        () async {
      final container = await buildContainer();
      repo
        ..productsResult = [_product(1), _product(2)]
        ..fromCacheResult = false;

      final products = await container.read(productsProvider.future);

      expect(products, hasLength(2));
      expect(repo.getProductsCalls, 1);
      expect(container.read(productsProvider.notifier).fromCache, isFalse);
      expect(container.read(productsProvider.notifier).lastUpdated, isNotNull);
    });

    test('marca fromCache=true cuando el repositorio devuelve datos de caché',
        () async {
      final container = await buildContainer();
      repo
        ..productsResult = [_product(1)]
        ..fromCacheResult = true;

      await container.read(productsProvider.future);

      expect(container.read(productsProvider.notifier).fromCache, isTrue);
    });
  });

  group('reload', () {
    test('actualiza el estado y fromCache/lastUpdated en éxito', () async {
      final container = await buildContainer();
      repo.productsResult = [_product(1)];
      await container.read(productsProvider.future);

      repo
        ..productsResult = [_product(1), _product(2), _product(3)]
        ..fromCacheResult = false;
      final beforeReload = container.read(productsProvider.notifier).lastUpdated;
      await container.read(productsProvider.notifier).reload();

      final state = container.read(productsProvider);
      expect(state.value, hasLength(3));
      expect(container.read(productsProvider.notifier).fromCache, isFalse);
      expect(
        container.read(productsProvider.notifier).lastUpdated,
        isNot(beforeReload),
      );
    });

    test('deja el estado en error y no actualiza lastUpdated/fromCache si falla',
        () async {
      final container = await buildContainer();
      repo.productsResult = [_product(1)];
      await container.read(productsProvider.future);
      final lastUpdatedBefore =
          container.read(productsProvider.notifier).lastUpdated;
      final fromCacheBefore = container.read(productsProvider.notifier).fromCache;

      repo.throwOnGetProducts = const NetworkException();
      await container.read(productsProvider.notifier).reload();

      final state = container.read(productsProvider);
      expect(state.hasError, isTrue);
      expect(
        container.read(productsProvider.notifier).lastUpdated,
        lastUpdatedBefore,
      );
      expect(
        container.read(productsProvider.notifier).fromCache,
        fromCacheBefore,
      );
    });
  });

  group('clearCacheAndReload', () {
    test('limpia el caché y recarga cuando está autenticado', () async {
      final container = await buildContainer();
      repo.productsResult = [_product(1)];
      await container.read(productsProvider.future);

      repo.productsResult = [_product(1), _product(2)];
      await container.read(productsProvider.notifier).clearCacheAndReload();

      expect(repo.clearCacheCalls, 1);
      expect(repo.lastClearedDocSearch, _tUser.docSearch);
      expect(container.read(productsProvider).value, hasLength(2));
    });

    test('no hace nada si no está autenticado', () async {
      final container = await buildContainer(authState: const AuthUnauthenticated());
      await container.read(productsProvider.future);

      await container.read(productsProvider.notifier).clearCacheAndReload();

      expect(repo.clearCacheCalls, 0);
      expect(repo.getProductsCalls, 0);
    });
  });
}
