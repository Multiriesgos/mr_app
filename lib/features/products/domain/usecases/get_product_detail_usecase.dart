import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductDetailUseCase {
  const GetProductDetailUseCase(this._repository);

  final ProductsRepository _repository;

  Future<(Product, ContactInfo?)> call({
    required int idRen,
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async {
    final results = await Future.wait([
      _repository.getProductDetail(idRen),
      _repository.getContactInfo(
        aseguradora: aseguradora,
        ramo: ramo,
        tipoSeguro: tipoSeguro,
      ),
    ]);
    return (results[0] as Product, results[1] as ContactInfo?);
  }
}
