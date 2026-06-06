import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/logging/app_logger.dart';
import 'package:mr_app/features/auth/data/models/user_model.dart';
import 'package:mr_app/utils/constants.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({
    required String documentNumber,
    required String birthDate,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _kBaseHost = 'secure.multiriesgos.com';
  static const _kTimeout = Duration(seconds: 30);

  @override
  Future<UserModel> login({
    required String documentNumber,
    required String birthDate,
  }) async {
    // No loguear documentNumber ni birthDate (PII)
    appLogger.info('auth: iniciando login');
    final uri = Uri.https(_kBaseHost, '/api/user/name/$documentNumber');

    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'MRApiKey': Constants.kMrApiKey,
            },
            body: '{}',
          )
          .timeout(_kTimeout);
    } on Exception catch (e, st) {
      appLogger.error('auth: error de red', e, st);
      throw const NetworkException();
    }

    if (response.statusCode != 200) {
      appLogger.warning('auth: HTTP ${response.statusCode}');
      throw const ServerException('Error del servidor. Intente de nuevo.');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw const ServerException('Respuesta inválida del servidor.');
    }

    final serverPass = json['userapp_pass'] as String?;
    final userappUser = json['userapp_user'] as String?;
    final userappEmail = json['userapp_correo'] as String?; // puede ser null
    final userappNombre = json['userapp_nombre'] as String?;
    final userappDocSearch = json['userapp_docsearch'] as String?;

    if (serverPass == null ||
        userappUser == null ||
        userappNombre == null ||
        userappDocSearch == null) {
      throw const ServerException('Datos incompletos del servidor.');
    }

    // La validación de credenciales es client-side: el servidor devuelve la
    // fecha de nacimiento y comparamos con lo que ingresó el usuario.
    if (serverPass != birthDate) {
      appLogger.warning('auth: credenciales inválidas');
      throw const AuthException();
    }

    appLogger.info('auth: login exitoso');
    return UserModel(
      documentNumber: userappUser,
      name: userappNombre,
      email: userappEmail,
      docSearch: userappDocSearch,
    );
  }
}
