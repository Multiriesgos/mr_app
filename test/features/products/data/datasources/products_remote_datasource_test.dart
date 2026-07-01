import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/products/data/datasources/products_remote_datasource.dart';

http.Response _jsonResponse(Object body, {int statusCode = 200}) =>
    http.Response(jsonEncode(body), statusCode);

Map<String, dynamic> _productJson(int idRen) => {
      'id_ren': idRen,
      'ramo': 'DAÑOS',
      'tipo_seguro': 'AUTOMOTORES',
      'aseguradora': 'ACSA',
      'asegurado': 'JUAN PÉREZ',
      'placa': 'P123456',
    };

void main() {
  group('getProducts', () {
    test('devuelve la lista de pólizas cuando el servidor responde 200',
        () async {
      final client = MockClient(
        (request) async => _jsonResponse([_productJson(1), _productJson(2)]),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final products = await dataSource.getProducts('123456');

      expect(products, hasLength(2));
      expect(products[0].idRen, 1);
    });

    test('la request incluye nodoc como query param', () async {
      http.Request? captured;
      final client = MockClient((request) async {
        captured = request;
        return _jsonResponse([]);
      });
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      await dataSource.getProducts('123456');

      expect(captured!.url.path, '/api/ren');
      expect(captured!.url.queryParameters['nodoc'], '123456');
    });

    test('lanza ServerException cuando el status no es 200', () async {
      final client = MockClient(
        (request) async => _jsonResponse([], statusCode: 500),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.getProducts('123456'),
        throwsA(isA<ServerException>()),
      );
    });

    test('lanza NetworkException cuando el cliente HTTP falla', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('sin conexión'),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.getProducts('123456'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getProductDetail', () {
    test('devuelve el modelo cuando el servidor responde 200', () async {
      final client = MockClient(
        (request) async => _jsonResponse(_productJson(42)),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final product = await dataSource.getProductDetail(42);

      expect(product.idRen, 42);
    });

    test('la request es POST a /api/ren/<idRen>', () async {
      http.Request? captured;
      final client = MockClient((request) async {
        captured = request;
        return _jsonResponse(_productJson(42));
      });
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      await dataSource.getProductDetail(42);

      expect(captured!.method, 'POST');
      expect(captured!.url.path, '/api/ren/42');
    });

    test('lanza ServerException cuando el status no es 200', () async {
      final client = MockClient(
        (request) async => _jsonResponse(_productJson(42), statusCode: 404),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.getProductDetail(42),
        throwsA(isA<ServerException>()),
      );
    });

    test('lanza NetworkException cuando el cliente HTTP falla', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('sin conexión'),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      await expectLater(
        () => dataSource.getProductDetail(42),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getContactInfo', () {
    test('devuelve el contacto del cab específico cuando responde con datos',
        () async {
      final client = MockClient(
        (request) async => _jsonResponse([
          {'cabina': '21234567', 'whatsapp': '79876543'},
        ]),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final contact = await dataSource.getContactInfo(
        aseguradora: 'ACSA',
        ramo: 'AUTOMOTORES',
        tipoSeguro: 'TERCEROS',
      );

      expect(contact?.phone, '21234567');
    });

    test(
        'cuando el cab específico no tiene datos, cae al cab genérico MULTIRIESGOS/CABINA/CONTACTOS',
        () async {
      final requests = <Uri>[];
      final client = MockClient((request) async {
        requests.add(request.url);
        final aseg = request.url.queryParameters['aseg'];
        if (aseg == 'MULTIRIESGOS') {
          return _jsonResponse([
            {'cabina': '20000000'},
          ]);
        }
        return _jsonResponse([]); // cab específico: sin datos
      });
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final contact = await dataSource.getContactInfo(
        aseguradora: 'ACSA',
        ramo: 'AUTOMOTORES',
        tipoSeguro: 'TERCEROS',
      );

      expect(contact?.phone, '20000000');
      expect(requests, hasLength(2));
      expect(requests[0].queryParameters['aseg'], 'ACSA');
      expect(requests[1].queryParameters['aseg'], 'MULTIRIESGOS');
    });

    test(
        'cuando ya se piden los params genéricos y no hay datos, no reintenta en bucle',
        () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return _jsonResponse([]);
      });
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final contact = await dataSource.getContactInfo(
        aseguradora: 'MULTIRIESGOS',
        ramo: 'CABINA',
        tipoSeguro: 'CONTACTOS',
      );

      expect(contact, isNull);
      expect(callCount, 1);
    });

    test('devuelve null cuando ni el cab específico ni el genérico tienen datos',
        () async {
      final client = MockClient((request) async => _jsonResponse([]));
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final contact = await dataSource.getContactInfo(
        aseguradora: 'ACSA',
        ramo: 'AUTOMOTORES',
        tipoSeguro: 'TERCEROS',
      );

      expect(contact, isNull);
    });

    test('devuelve null (sin lanzar) cuando el cliente HTTP falla', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('sin conexión'),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final contact = await dataSource.getContactInfo(
        aseguradora: 'ACSA',
        ramo: 'AUTOMOTORES',
        tipoSeguro: 'TERCEROS',
      );

      expect(contact, isNull);
    });

    test('devuelve null cuando el status no es 200', () async {
      final client = MockClient(
        (request) async => _jsonResponse([], statusCode: 500),
      );
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final contact = await dataSource.getContactInfo(
        aseguradora: 'ACSA',
        ramo: 'AUTOMOTORES',
        tipoSeguro: 'TERCEROS',
      );

      expect(contact, isNull);
    });
  });

  group('getDefaultContactInfo', () {
    test('consulta directamente el cab genérico MULTIRIESGOS/CABINA/CONTACTOS',
        () async {
      http.Request? captured;
      final client = MockClient((request) async {
        captured = request;
        return _jsonResponse([
          {'cabina': '20000000'},
        ]);
      });
      final dataSource = ProductsRemoteDataSourceImpl(client: client);

      final contact = await dataSource.getDefaultContactInfo();

      expect(contact?.phone, '20000000');
      expect(captured!.url.queryParameters['aseg'], 'MULTIRIESGOS');
      expect(captured!.url.queryParameters['ramo'], 'CABINA');
      expect(captured!.url.queryParameters['tipaseg'], 'CONTACTOS');
    });
  });
}
