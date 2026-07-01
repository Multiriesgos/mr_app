import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/features/products/data/datasources/products_local_datasource.dart';
import 'package:mr_app/features/products/data/models/product_model.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _store = {};
  Exception? throwOnRead;
  Exception? throwOnWrite;
  Exception? throwOnDelete;

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    if (throwOnWrite != null) throw throwOnWrite!;
    _store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    if (throwOnRead != null) throw throwOnRead!;
    return _store[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _store.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    if (throwOnDelete != null) throw throwOnDelete!;
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_store);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _store.clear();
  }
}

ProductModel _model(int idRen) => ProductModel(
      idRen: idRen,
      ramo: 'DAÑOS',
      tipoSeguro: 'AUTOMOTORES',
      aseguradora: 'ACSA',
      asegurado: 'JUAN PÉREZ',
      placa: 'P123456',
    );

void main() {
  late _FakeSecureStoragePlatform fakePlatform;
  late ProductsLocalDataSourceImpl dataSource;

  setUp(() {
    fakePlatform = _FakeSecureStoragePlatform();
    FlutterSecureStoragePlatform.instance = fakePlatform;
    dataSource = const ProductsLocalDataSourceImpl(FlutterSecureStorage());
  });

  group('getCachedProducts', () {
    test('devuelve null cuando no hay nada guardado para ese docSearch',
        () async {
      final result = await dataSource.getCachedProducts('123456');

      expect(result, isNull);
    });

    test('devuelve la lista guardada tras cacheProducts (round-trip)',
        () async {
      await dataSource.cacheProducts([_model(1), _model(2)], '123456');

      final result = await dataSource.getCachedProducts('123456');

      expect(result, isNotNull);
      expect(result, hasLength(2));
      expect(result!.map((m) => m.idRen), [1, 2]);
    });

    test('devuelve null (sin lanzar) cuando el valor guardado no es JSON válido',
        () async {
      fakePlatform._store['mr_products_cache_v1_123456'] = 'esto no es json';

      final result = await dataSource.getCachedProducts('123456');

      expect(result, isNull);
    });

    test('devuelve null (sin lanzar) cuando el storage lanza una excepción al leer',
        () async {
      fakePlatform.throwOnRead = Exception('storage roto');

      final result = await dataSource.getCachedProducts('123456');

      expect(result, isNull);
    });

    test('el caché de un docSearch no se mezcla con el de otro', () async {
      await dataSource.cacheProducts([_model(1)], '111111');
      await dataSource.cacheProducts([_model(2), _model(3)], '222222');

      final cache1 = await dataSource.getCachedProducts('111111');
      final cache2 = await dataSource.getCachedProducts('222222');

      expect(cache1, hasLength(1));
      expect(cache1!.first.idRen, 1);
      expect(cache2, hasLength(2));
    });
  });

  group('cacheProducts', () {
    test('no lanza cuando el storage falla al escribir', () async {
      fakePlatform.throwOnWrite = Exception('storage lleno');

      await expectLater(
        dataSource.cacheProducts([_model(1)], '123456'),
        completes,
      );
    });
  });

  group('clearCache', () {
    test('elimina el caché del docSearch indicado', () async {
      await dataSource.cacheProducts([_model(1)], '123456');

      await dataSource.clearCache('123456');

      expect(await dataSource.getCachedProducts('123456'), isNull);
    });

    test('no afecta el caché de otro docSearch', () async {
      await dataSource.cacheProducts([_model(1)], '111111');
      await dataSource.cacheProducts([_model(2)], '222222');

      await dataSource.clearCache('111111');

      expect(await dataSource.getCachedProducts('111111'), isNull);
      expect(await dataSource.getCachedProducts('222222'), hasLength(1));
    });

    test('no lanza cuando el storage falla al borrar', () async {
      fakePlatform.throwOnDelete = Exception('storage roto');

      await expectLater(dataSource.clearCache('123456'), completes);
    });
  });
}
