import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:mr_app/core/network/mr_http_client.dart';
import 'package:mr_app/core/storage/secure_storage.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/products/data/datasources/products_local_datasource.dart';
import 'package:mr_app/features/products/data/datasources/products_remote_datasource.dart';
import 'package:mr_app/features/products/data/repositories/products_repository_impl.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/repositories/products_repository.dart';
import 'package:mr_app/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:mr_app/features/products/domain/usecases/get_products_usecase.dart';

// ---------- DI ----------

final _productsRemoteDataSourceProvider =
    Provider<ProductsRemoteDataSource>((ref) {
  return ProductsRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final _productsLocalDataSourceProvider =
    Provider<ProductsLocalDataSource>((ref) {
  return ProductsLocalDataSourceImpl(ref.watch(secureStorageProvider));
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    ref.watch(_productsRemoteDataSourceProvider),
    ref.watch(_productsLocalDataSourceProvider),
  );
});

// ---------- Products list ----------

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  DateTime? lastUpdated;
  bool fromCache = false;

  @override
  Future<List<Product>> build() async {
    final authState = ref.watch(authProvider).value;
    if (authState is! AuthAuthenticated) return [];

    final (result, cached) = await GetProductsUseCase(
      ref.read(productsRepositoryProvider),
    )(authState.user.docSearch);
    fromCache = cached;
    lastUpdated = DateTime.now();
    return result;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    var cached = false;
    state = await AsyncValue.guard(() async {
      final (products, isCached) = await GetProductsUseCase(
        ref.read(productsRepositoryProvider),
      )(
        (ref.read(authProvider).requireValue as AuthAuthenticated).user.docSearch,
      );
      cached = isCached;
      return products;
    });
    // No usar state.hasValue: AsyncValue conserva el valor previo aunque el
    // estado actual sea de error, así que hasValue sigue en true tras un
    // reload fallido con datos previos.
    if (!state.hasError) {
      lastUpdated = DateTime.now();
      fromCache = cached;
    }
  }

  Future<void> clearCacheAndReload() async {
    final authState = ref.read(authProvider).value;
    if (authState is! AuthAuthenticated) return;
    await ref.read(productsRepositoryProvider).clearCache(authState.user.docSearch);
    await reload();
  }
}

// ---------- Home contact (genérico MULTIRIESGOS/CABINA/CONTACTOS) ----------

final homeContactProvider = FutureProvider<ContactInfo?>((ref) async {
  return ref.read(productsRepositoryProvider).getDefaultContactInfo();
});

// ---------- Product detail ----------

final AsyncNotifierProviderFamily<ProductDetailNotifier, (Product, ContactInfo?), int>
    productDetailProvider = AsyncNotifierProvider.family<ProductDetailNotifier,
        (Product, ContactInfo?), int>(
  ProductDetailNotifier.new,
);

class ProductDetailNotifier extends AsyncNotifier<(Product, ContactInfo?)> {
  ProductDetailNotifier(this.arg);
  final int arg;

  @override
  Future<(Product, ContactInfo?)> build() async {
    // Intentar obtener el producto del caché de la lista primero
    final listState = ref.read(productsProvider);
    final cached = listState.value?.where((p) => p.idRen == arg).firstOrNull;

    if (cached != null) {
      // Carga la info de contacto en paralelo sin bloquear la UI con el producto ya cacheado
      final contactInfo = await GetProductDetailUseCase(
        ref.read(productsRepositoryProvider),
      ).call(
        idRen: arg,
        aseguradora: cached.aseguradora,
        ramo: cached.ramo,
        tipoSeguro: cached.tipoSeguro,
      ).then((r) => r.$2);
      return (cached, contactInfo);
    }

    return GetProductDetailUseCase(ref.read(productsRepositoryProvider)).call(
      idRen: arg,
      aseguradora: '',
      ramo: '',
      tipoSeguro: '',
    );
  }
}
