import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mr_app/features/auth/data/models/user_model.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _store[key];

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _store.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_store);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _store.clear();
  }
}

const _tUser = UserModel(
  documentNumber: '0801199012345',
  name: 'JUAN PÉREZ',
  email: 'juan@example.com',
  docSearch: '0801199012345',
);

void main() {
  late AuthLocalDataSourceImpl dataSource;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    dataSource = const AuthLocalDataSourceImpl(FlutterSecureStorage());
  });

  group('saveUser / getSavedUser', () {
    test('con rememberMe=true, getSavedUser devuelve los datos guardados',
        () async {
      await dataSource.saveUser(_tUser, rememberMe: true);

      final saved = await dataSource.getSavedUser();

      expect(saved?.documentNumber, _tUser.documentNumber);
      expect(saved?.name, _tUser.name);
      expect(saved?.email, _tUser.email);
      expect(saved?.docSearch, _tUser.docSearch);
    });

    test('con rememberMe=false, getSavedUser devuelve null aunque haya datos',
        () async {
      await dataSource.saveUser(_tUser, rememberMe: false);

      final saved = await dataSource.getSavedUser();

      expect(saved, isNull);
    });

    test('sin ningún usuario guardado, getSavedUser devuelve null', () async {
      final saved = await dataSource.getSavedUser();

      expect(saved, isNull);
    });
  });

  group('getSavedDocumentNumber', () {
    test('devuelve el documento cuando rememberMe=true', () async {
      await dataSource.saveUser(_tUser, rememberMe: true);

      expect(await dataSource.getSavedDocumentNumber(), _tUser.documentNumber);
    });

    test('devuelve null cuando rememberMe=false', () async {
      await dataSource.saveUser(_tUser, rememberMe: false);

      expect(await dataSource.getSavedDocumentNumber(), isNull);
    });
  });

  group('getSavedBirthDate', () {
    test('devuelve la fecha guardada cuando rememberMe=true y se pasó birthDate',
        () async {
      await dataSource.saveUser(
        _tUser,
        rememberMe: true,
        birthDate: '1990-01-01',
      );

      expect(await dataSource.getSavedBirthDate(), '1990-01-01');
    });

    test('devuelve null cuando rememberMe=true pero no se pasó birthDate',
        () async {
      await dataSource.saveUser(_tUser, rememberMe: true);

      expect(await dataSource.getSavedBirthDate(), isNull);
    });

    test('devuelve null cuando rememberMe=false aunque se haya pasado birthDate',
        () async {
      await dataSource.saveUser(
        _tUser,
        rememberMe: false,
        birthDate: '1990-01-01',
      );

      expect(await dataSource.getSavedBirthDate(), isNull);
    });
  });

  group('clearAll', () {
    test('con rememberMe=true, conserva documento/remind/birthDate pero borra el resto',
        () async {
      await dataSource.saveUser(
        _tUser,
        rememberMe: true,
        birthDate: '1990-01-01',
      );

      await dataSource.clearAll();

      expect(await dataSource.getSavedDocumentNumber(), _tUser.documentNumber);
      expect(await dataSource.getSavedBirthDate(), '1990-01-01');
      expect(await dataSource.getSavedRememberMe(), isTrue);
      // getSavedUser exige name/email/docSearch, que sí se borran -> vuelve
      // con strings vacíos en vez del valor guardado originalmente.
      final saved = await dataSource.getSavedUser();
      expect(saved?.name, '');
      expect(saved?.email, isNull);
    });

    test('con rememberMe=false, borra todo incluyendo documento/remind',
        () async {
      await dataSource.saveUser(_tUser, rememberMe: false);

      await dataSource.clearAll();

      expect(await dataSource.getSavedDocumentNumber(), isNull);
      expect(await dataSource.getSavedRememberMe(), isFalse);
    });
  });

  group('getSavedRememberMe', () {
    test('devuelve false cuando nunca se guardó nada', () async {
      expect(await dataSource.getSavedRememberMe(), isFalse);
    });
  });
}
