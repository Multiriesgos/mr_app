import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/products/data/datasources/products_local_datasource.dart';
import 'package:mr_app/features/products/data/datasources/products_remote_datasource.dart';
import 'package:mr_app/features/products/data/models/product_model.dart';
import 'package:mr_app/features/products/data/repositories/products_repository_impl.dart';

class _FakeRemoteDataSource implements ProductsRemoteDataSource {
  List<ProductModel>? productsResult;
  Exception? throwOnGetProducts;

  ProductModel? productDetailResult;
  Exception? throwOnGetProductDetail;

  ContactInfoModel? contactInfoResult;

  int getProductsCalls = 0;

  @override
  Future<List<ProductModel>> getProducts(String docSearch) async {
    getProductsCalls++;
    if (throwOnGetProducts != null) throw throwOnGetProducts!;
    return productsResult ?? [];
  }

  @override
  Future<ProductModel> getProductDetail(int idRen) async {
    if (throwOnGetProductDetail != null) throw throwOnGetProductDetail!;
    return productDetailResult!;
  }

  @override
  Future<ContactInfoModel?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async => contactInfoResult;

  @override
  Future<ContactInfoModel?> getDefaultContactInfo() async => contactInfoResult;
}

class _FakeLocalDataSource implements ProductsLocalDataSource {
  List<ProductModel>? cachedProducts;
  List<ProductModel>? lastCached;
  String? lastCachedDocSearch;
  String? lastClearedDocSearch;

  @override
  Future<List<ProductModel>?> getCachedProducts(String docSearch) async =>
      cachedProducts;

  @override
  Future<void> cacheProducts(List<ProductModel> models, String docSearch) async {
    lastCached = models;
    lastCachedDocSearch = docSearch;
  }

  @override
  Future<void> clearCache(String docSearch) async {
    lastClearedDocSearch = docSearch;
  }
}

ProductModel _model(int idRen, {String ramo = 'DAÑOS'}) => ProductModel(
      idRen: idRen,
      ramo: ramo,
      tipoSeguro: 'AUTOMOTORES',
      aseguradora: 'ACSA',
      asegurado: 'JUAN PÉREZ',
      placa: 'P123456',
    );

void main() {
  late _FakeRemoteDataSource remote;
  late _FakeLocalDataSource local;
  late ProductsRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemoteDataSource();
    local = _FakeLocalDataSource();
    repository = ProductsRepositoryImpl(remote, local);
  });

  group('getProducts', () {
    test('devuelve las pólizas del remoto con fromCache=false', () async {
      remote.productsResult = [_model(1), _model(2)];

      final (products, fromCache) = await repository.getProducts('123456');

      expect(products, hasLength(2));
      expect(fromCache, isFalse);
    });

    test('cachea los modelos obtenidos del remoto', () async {
      remote.productsResult = [_model(1)];

      await repository.getProducts('123456');
      // cacheProducts se llama con unawaited(); dejamos correr el microtask queue.
      await Future<void>.delayed(Duration.zero);

      expect(local.lastCachedDocSearch, '123456');
      expect(local.lastCached, hasLength(1));
    });

    test('cuando falla la red y hay caché, devuelve el caché con fromCache=true',
        () async {
      remote.throwOnGetProducts = const NetworkException();
      local.cachedProducts = [_model(1), _model(2), _model(3)];

      final (products, fromCache) = await repository.getProducts('123456');

      expect(products, hasLength(3));
      expect(fromCache, isTrue);
    });

    test('cuando falla la red y no hay caché, relanza NetworkException',
        () async {
      remote.throwOnGetProducts = const NetworkException();
      local.cachedProducts = null;

      await expectLater(
        () => repository.getProducts('123456'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('un ServerException no cae al fallback de caché', () async {
      remote.throwOnGetProducts = const ServerException();
      local.cachedProducts = [_model(1)];

      await expectLater(
        () => repository.getProducts('123456'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getProductDetail', () {
    test('devuelve la entidad mapeada del remoto', () async {
      remote.productDetailResult = _model(42, ramo: 'INCENDIO');

      final product = await repository.getProductDetail(42);

      expect(product.idRen, 42);
      expect(product.ramo, 'INCENDIO');
    });

    test('propaga la excepción del remoto sin fallback a caché', () async {
      remote.throwOnGetProductDetail = const NetworkException();

      await expectLater(
        () => repository.getProductDetail(42),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getContactInfo / getDefaultContactInfo', () {
    test('getContactInfo devuelve la entidad mapeada cuando el remoto responde',
        () async {
      remote.contactInfoResult =
          const ContactInfoModel(phone: '21234567', whatsapp: '79876543');

      final contact = await repository.getContactInfo(
        aseguradora: 'ACSA',
        ramo: 'AUTOMOTORES',
        tipoSeguro: 'TERCEROS',
      );

      expect(contact?.phone, '21234567');
      expect(contact?.whatsapp, '79876543');
    });

    test('getContactInfo devuelve null cuando el remoto no tiene datos', () async {
      remote.contactInfoResult = null;

      final contact = await repository.getContactInfo(
        aseguradora: 'ACSA',
        ramo: 'AUTOMOTORES',
        tipoSeguro: 'TERCEROS',
      );

      expect(contact, isNull);
    });

    test('getDefaultContactInfo devuelve la entidad mapeada del remoto', () async {
      remote.contactInfoResult = const ContactInfoModel(phone: '21234567');

      final contact = await repository.getDefaultContactInfo();

      expect(contact?.phone, '21234567');
    });
  });

  group('clearCache', () {
    test('delega en el datasource local', () async {
      await repository.clearCache('123456');

      expect(local.lastClearedDocSearch, '123456');
    });
  });
}
