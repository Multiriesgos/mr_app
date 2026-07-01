import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/logging/app_logger.dart';
import 'package:mr_app/features/products/data/models/product_model.dart';
import 'package:mr_app/utils/constants.dart';

abstract interface class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts(String docSearch);
  Future<ProductModel> getProductDetail(int idRen);
  Future<ContactInfoModel?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  });
  Future<ContactInfoModel?> getDefaultContactInfo();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _kHost    = 'secure.multiriesgos.com';
  static const _kTimeout = Duration(seconds: 30);
  static const Map<String, String> _kHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'MRApiKey': Constants.kMrApiKey,
  };

  // Llave genérica: usada como fallback cuando el cab específico no tiene datos
  // y como contacto principal del Centro de atención en el home.
  static const _kDefaultAseg    = 'MULTIRIESGOS';
  static const _kDefaultRamo    = 'CABINA';
  static const _kDefaultTipaseg = 'CONTACTOS';

  @override
  Future<List<ProductModel>> getProducts(String docSearch) async {
    appLogger.info('products: cargando lista');
    final uri = Uri.https(_kHost, '/api/ren', {'nodoc': docSearch});
    final response = await _client
        .get(uri, headers: _kHeaders)
        .timeout(_kTimeout)
        .onError((e, st) {
      appLogger.error('products: error de red en getProducts', e, st);
      throw const NetworkException();
    });

    if (response.statusCode != 200) {
      appLogger.warning('products: HTTP ${response.statusCode} en getProducts');
      throw const ServerException();
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final models = list
        .cast<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
    appLogger.info('products: cargado ${models.length} pólizas');
    return models;
  }

  @override
  Future<ProductModel> getProductDetail(int idRen) async {
    final uri = Uri.https(_kHost, '/api/ren/$idRen');
    final response = await _client
        .post(uri, headers: _kHeaders, body: '{}')
        .timeout(_kTimeout)
        .onError((_, __) => throw const NetworkException());

    if (response.statusCode != 200) throw const ServerException();

    return ProductModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<ContactInfoModel?> getContactInfo({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async {
    final result = await _fetchCab(
      aseguradora: aseguradora,
      ramo: ramo,
      tipoSeguro: tipoSeguro,
    );
    if (result != null) return result;

    // Si el cab específico no tiene datos, usar la llave genérica como fallback,
    // pero solo si los params ya no son la llave genérica (evitar bucle).
    final isAlreadyDefault = aseguradora == _kDefaultAseg &&
        ramo == _kDefaultRamo &&
        tipoSeguro == _kDefaultTipaseg;
    if (isAlreadyDefault) return null;

    return _fetchCab(
      aseguradora: _kDefaultAseg,
      ramo: _kDefaultRamo,
      tipoSeguro: _kDefaultTipaseg,
    );
  }

  @override
  Future<ContactInfoModel?> getDefaultContactInfo() => _fetchCab(
        aseguradora: _kDefaultAseg,
        ramo: _kDefaultRamo,
        tipoSeguro: _kDefaultTipaseg,
      );

  Future<ContactInfoModel?> _fetchCab({
    required String aseguradora,
    required String ramo,
    required String tipoSeguro,
  }) async {
    final uri = Uri.https(_kHost, '/api/cab', {
      'aseg': aseguradora,
      'ramo': ramo,
      'tipaseg': tipoSeguro,
    });
    try {
      final response = await _client
          .post(uri, headers: _kHeaders)
          .timeout(_kTimeout);
      if (response.statusCode != 200) return null;
      final list = jsonDecode(response.body) as List<dynamic>;
      if (list.isEmpty) return null;
      return ContactInfoModel.fromJson(list.first as Map<String, dynamic>);
    } on Exception {
      return null;
    }
  }
}
