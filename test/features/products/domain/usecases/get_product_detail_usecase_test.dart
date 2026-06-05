import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/repositories/products_repository.dart';
import 'package:mr_app/features/products/domain/usecases/get_product_detail_usecase.dart';

class _FakeProductsRepository implements ProductsRepository {
  _FakeProductsRepository({
    required this.detailResult,
    this.contactResult,
  });

  final Object detailResult;
  final ContactInfo? contactResult;

  @override
  Future<List<Product>> getProducts(String docSearch) async =>
      throw UnimplementedError();

  @override
  Future<Product> getProductDetail(int idRen) async {
    if (detailResult is Exception) throw detailResult as Exception;
    return detailResult as Product;
  }

  @override
  Future<ContactInfo?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async =>
      contactResult;
}

void main() {
  const tProduct = Product(
    idRen: 42,
    ramo: 'Vida',
    tipoSeguro: 'Individual',
    aseguradora: 'Seguros SA',
    asegurado: 'Juan Pérez',
    placa: '',
  );

  const tContactInfo = ContactInfo(phone: '22001234', whatsapp: '78001234');

  group('GetProductDetailUseCase', () {
    test('retorna (Product, ContactInfo) cuando ambos servicios responden OK',
        () async {
      final sut = GetProductDetailUseCase(
        _FakeProductsRepository(
          detailResult: tProduct,
          contactResult: tContactInfo,
        ),
      );

      final result = await sut(
        idRen: 42,
        aseguradora: 'Seguros SA',
        ramo: 'Vida',
        tipoSeguro: 'Individual',
      );

      expect(result.$1, equals(tProduct));
      expect(result.$2, equals(tContactInfo));
    });

    test('retorna (Product, null) cuando no hay info de contacto', () async {
      final sut = GetProductDetailUseCase(
        _FakeProductsRepository(
          detailResult: tProduct,
          contactResult: null,
        ),
      );

      final result = await sut(
        idRen: 42,
        aseguradora: 'Seguros SA',
        ramo: 'Vida',
        tipoSeguro: 'Individual',
      );

      expect(result.$1, equals(tProduct));
      expect(result.$2, isNull);
    });

    test('propaga NetworkException cuando falla la obtención del detalle',
        () async {
      final sut = GetProductDetailUseCase(
        _FakeProductsRepository(
          detailResult: const NetworkException(),
          contactResult: null,
        ),
      );

      await expectLater(
        () => sut(
          idRen: 42,
          aseguradora: 'Seguros SA',
          ramo: 'Vida',
          tipoSeguro: 'Individual',
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('ContactInfo.hasPhone es false cuando phone está vacío', () {
      const info = ContactInfo(phone: '', whatsapp: '78001234');
      expect(info.hasPhone, isFalse);
      expect(info.hasWhatsApp, isTrue);
    });

    test('ContactInfo.hasPhone es true cuando phone tiene valor', () {
      const info = ContactInfo(phone: '22001234', whatsapp: null);
      expect(info.hasPhone, isTrue);
      expect(info.hasWhatsApp, isFalse);
    });
  });
}
