import 'dart:async';

import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/products/data/datasources/products_local_datasource.dart';
import 'package:mr_app/features/products/data/datasources/products_remote_datasource.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote, this._local);

  final ProductsRemoteDataSource _remote;
  final ProductsLocalDataSource  _local;

  @override
  Future<List<Product>> getProducts(String docSearch) async {
    try {
      final models = await _remote.getProducts(docSearch);
      unawaited(_local.cacheProducts(models, docSearch));
      return models.map((m) => m.toEntity()).toList();
    } on NetworkException {
      final cached = await _local.getCachedProducts(docSearch);
      if (cached != null) return cached.map((m) => m.toEntity()).toList();
      rethrow;
    }
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

  @override
  Future<ContactInfo?> getDefaultContactInfo() async {
    final model = await _remote.getDefaultContactInfo();
    return model?.toEntity();
  }
}
