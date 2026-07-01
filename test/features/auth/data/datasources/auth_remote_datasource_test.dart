import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/auth/data/datasources/auth_remote_datasource.dart';

http.Response _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) =>
    http.Response(jsonEncode(body), statusCode);

Map<String, dynamic> _validServerJson({String pass = '1990-01-01'}) => {
      'userapp_pass': pass,
      'userapp_user': '0801199012345',
      'userapp_nombre': 'JUAN PÉREZ',
      'userapp_correo': 'juan@example.com',
      'userapp_docsearch': '0801199012345',
    };

void main() {
  group('login', () {
    test('devuelve UserModel cuando la fecha coincide con userapp_pass',
        () async {
      final client = MockClient(
        (request) async => _jsonResponse(_validServerJson()),
      );
      final dataSource = AuthRemoteDataSourceImpl(client: client);

      final model = await dataSource.login(
        documentNumber: '0801199012345',
        birthDate: '1990-01-01',
      );

      expect(model.documentNumber, '0801199012345');
      expect(model.name, 'JUAN PÉREZ');
      expect(model.email, 'juan@example.com');
      expect(model.docSearch, '0801199012345');
    });

    test('envía POST a /api/user/name/<documentNumber> con body vacío',
        () async {
      http.Request? captured;
      final client = MockClient((request) async {
        captured = request;
        return _jsonResponse(_validServerJson());
      });
      final dataSource = AuthRemoteDataSourceImpl(client: client);

      await dataSource.login(
        documentNumber: '0801199012345',
        birthDate: '1990-01-01',
      );

      expect(captured, isNotNull);
      expect(captured!.method, 'POST');
      expect(captured!.url.host, 'secure.multiriesgos.com');
      expect(captured!.url.path, '/api/user/name/0801199012345');
      expect(captured!.body, '{}');
      // La fecha de nacimiento nunca se envía al servidor: la validación
      // de credenciales es client-side, comparando contra userapp_pass.
      expect(captured!.body.contains('1990-01-01'), isFalse);
    });

    test('lanza AuthException cuando la fecha no coincide con userapp_pass',
        () async {
      final client = MockClient(
        (request) async => _jsonResponse(_validServerJson()),
      );
      final dataSource = AuthRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.login(
          documentNumber: '0801199012345',
          birthDate: '2000-12-31',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('lanza ServerException cuando el status no es 200', () async {
      final client = MockClient(
        (request) async => _jsonResponse(_validServerJson(), statusCode: 500),
      );
      final dataSource = AuthRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.login(
          documentNumber: '0801199012345',
          birthDate: '1990-01-01',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('lanza ServerException cuando el body no es JSON válido', () async {
      final client = MockClient(
        (request) async => http.Response('esto no es json', 200),
      );
      final dataSource = AuthRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.login(
          documentNumber: '0801199012345',
          birthDate: '1990-01-01',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    for (final missingField in [
      'userapp_pass',
      'userapp_user',
      'userapp_nombre',
      'userapp_docsearch',
    ]) {
      test('lanza ServerException cuando falta $missingField', () async {
        final json = _validServerJson()..remove(missingField);
        final client = MockClient((request) async => _jsonResponse(json));
        final dataSource = AuthRemoteDataSourceImpl(client: client);

        await expectLater(
          () => dataSource.login(
            documentNumber: '0801199012345',
            birthDate: '1990-01-01',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    }

    test('userapp_correo ausente no impide el login (email queda null)',
        () async {
      final json = _validServerJson()..remove('userapp_correo');
      final client = MockClient((request) async => _jsonResponse(json));
      final dataSource = AuthRemoteDataSourceImpl(client: client);

      final model = await dataSource.login(
        documentNumber: '0801199012345',
        birthDate: '1990-01-01',
      );

      expect(model.email, isNull);
    });

    test('lanza NetworkException cuando el cliente HTTP lanza una excepción',
        () async {
      final client = MockClient((request) async {
        throw http.ClientException('sin conexión');
      });
      final dataSource = AuthRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.login(
          documentNumber: '0801199012345',
          birthDate: '1990-01-01',
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
