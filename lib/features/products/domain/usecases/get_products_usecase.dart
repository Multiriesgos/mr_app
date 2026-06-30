import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/repositories/products_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<(List<Product>, bool fromCache)> call(String docSearch) =>
      _repository.getProducts(docSearch);
}
