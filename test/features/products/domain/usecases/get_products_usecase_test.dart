import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/repositories/products_repository.dart';
import 'package:mr_app/features/products/domain/usecases/get_products_usecase.dart';

class _FakeProductsRepository implements ProductsRepository {
  _FakeProductsRepository({required this.productsResult});

  final Object productsResult;

  @override
  Future<List<Product>> getProducts(String docSearch) async {
    if (productsResult is Exception) throw productsResult as Exception;
    return productsResult as List<Product>;
  }

  @override
  Future<Product> getProductDetail(int idRen) async =>
      throw UnimplementedError();

  @override
  Future<ContactInfo?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async =>
      throw UnimplementedError();
}

void main() {
  const tDocSearch = 'ABC123';

  final tProducts = [
    const Product(
      idRen: 1,
      ramo: 'Vida',
      tipoSeguro: 'Individual',
      aseguradora: 'Seguros SA',
      asegurado: 'Juan Pérez',
      placa: '',
    ),
    const Product(
      idRen: 2,
      ramo: 'Auto',
      tipoSeguro: 'Todo Riesgo',
      aseguradora: 'ASSA',
      asegurado: 'Juan Pérez',
      placa: 'P-123456',
    ),
  ];

  group('GetProductsUseCase', () {
    test('retorna lista de productos cuando el repositorio responde OK',
        () async {
      final sut = GetProductsUseCase(
        _FakeProductsRepository(productsResult: tProducts),
      );

      final result = await sut(tDocSearch);

      expect(result, equals(tProducts));
      expect(result.length, 2);
    });

    test('retorna lista vacía cuando no hay productos', () async {
      final sut = GetProductsUseCase(
        _FakeProductsRepository(productsResult: <Product>[]),
      );

      final result = await sut(tDocSearch);

      expect(result, isEmpty);
    });

    test('propaga NetworkException cuando falla la red', () async {
      final sut = GetProductsUseCase(
        _FakeProductsRepository(productsResult: const NetworkException()),
      );

      await expectLater(
        () => sut(tDocSearch),
        throwsA(isA<NetworkException>()),
      );
    });

    test('propaga ServerException cuando el servidor devuelve error', () async {
      final sut = GetProductsUseCase(
        _FakeProductsRepository(
          productsResult: const ServerException('Error 500'),
        ),
      );

      await expectLater(
        () => sut(tDocSearch),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
