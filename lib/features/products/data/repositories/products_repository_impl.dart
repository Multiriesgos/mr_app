import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/repositories/products_repository.dart';

import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<List<Product>> getProducts(String docSearch) async {
    final models = await _remote.getProducts(docSearch);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Product> getProductDetail(int idRen) async {
    final model = await _remote.getProductDetail(idRen);
    return model.toEntity();
  }

  @override
  Future<ContactInfo?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async {
    final model = await _remote.getContactInfo(
      aseguradora: aseguradora,
      ramo: ramo,
      tipoSeguro: tipoSeguro,
    );
    return model?.toEntity();
  }
}
