import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<List<Product>> call(String docSearch) =>
      _repository.getProducts(docSearch);
}
