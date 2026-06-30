import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mr_app/core/logging/app_logger.dart';
import 'package:mr_app/features/products/data/models/product_model.dart';

abstract interface class ProductsLocalDataSource {
  Future<List<ProductModel>?> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> models);
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  static const _kKey = 'mr_products_cache_v1';

  const ProductsLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<List<ProductModel>?> getCachedProducts() async {
    try {
      final raw = await _storage.read(key: _kKey);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e, st) {
      appLogger.error('products_cache: error leyendo caché', e, st);
      return null;
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> models) async {
    try {
      final json = jsonEncode(models.map((m) => m.toJson()).toList());
      await _storage.write(key: _kKey, value: json);
      appLogger.info('products_cache: ${models.length} pólizas guardadas');
    } on Exception catch (e, st) {
      appLogger.error('products_cache: error escribiendo caché', e, st);
    }
  }
}
