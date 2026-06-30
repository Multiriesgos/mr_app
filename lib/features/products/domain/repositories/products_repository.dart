import 'package:mr_app/features/products/domain/entities/product.dart';

abstract interface class ProductsRepository {
  Future<List<Product>> getProducts(String docSearch);
  Future<Product> getProductDetail(int idRen);
  Future<ContactInfo?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  });
  Future<ContactInfo?> getDefaultContactInfo();
}
