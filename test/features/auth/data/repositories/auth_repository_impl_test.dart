import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mr_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mr_app/features/auth/data/models/user_model.dart';
import 'package:mr_app/features/auth/data/repositories/auth_repository_impl.dart';

class _FakeRemoteDataSource implements AuthRemoteDataSource {
  UserModel? loginResult;
  Exception? throwOnLogin;

  String? lastDocumentNumber;
  String? lastBirthDate;

  @override
  Future<UserModel> login({
    required String documentNumber,
    required String birthDate,
  }) async {
    lastDocumentNumber = documentNumber;
    lastBirthDate = birthDate;
    if (throwOnLogin != null) throw throwOnLogin!;
    return loginResult!;
  }
}

class _FakeLocalDataSource implements AuthLocalDataSource {
  UserModel? savedUser;
  String? savedDocumentNumber;
  String? savedBirthDate;
  bool savedRememberMe = false;
  bool clearAllCalled = false;

  UserModel? lastSavedUser;
  bool? lastRememberMe;
  String? lastBirthDate;

  @override
  Future<void> saveUser(
    UserModel user, {
    required bool rememberMe,
    String? birthDate,
  }) async {
    lastSavedUser = user;
    lastRememberMe = rememberMe;
    lastBirthDate = birthDate;
  }

  @override
  Future<UserModel?> getSavedUser() async => savedUser;

  @override
  Future<String?> getSavedDocumentNumber() async => savedDocumentNumber;

  @override
  Future<String?> getSavedBirthDate() async => savedBirthDate;

  @override
  Future<bool> getSavedRememberMe() async => savedRememberMe;

  @override
  Future<void> clearAll() async {
    clearAllCalled = true;
  }
}

const _tUserModel = UserModel(
  documentNumber: '0801199012345',
  name: 'JUAN PÉREZ',
  email: 'juan@example.com',
  docSearch: '0801199012345',
);

void main() {
  late _FakeRemoteDataSource remote;
  late _FakeLocalDataSource local;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemoteDataSource();
    local = _FakeLocalDataSource();
    repository = AuthRepositoryImpl(remote: remote, local: local);
  });

  group('login', () {
    test('devuelve la entidad mapeada del remoto', () async {
      remote.loginResult = _tUserModel;

      final user = await repository.login(
        documentNumber: '0801199012345',
        birthDate: '1990-01-01',
        rememberMe: true,
      );

      expect(user.documentNumber, _tUserModel.documentNumber);
      expect(user.name, _tUserModel.name);
    });

    test('guarda el usuario localmente con rememberMe y birthDate', () async {
      remote.loginResult = _tUserModel;

      await repository.login(
        documentNumber: '0801199012345',
        birthDate: '1990-01-01',
        rememberMe: true,
      );

      expect(local.lastSavedUser, _tUserModel);
      expect(local.lastRememberMe, isTrue);
      expect(local.lastBirthDate, '1990-01-01');
    });

    test('propaga la excepción del remoto sin guardar nada localmente',
        () async {
      remote.throwOnLogin = const AuthException();

      await expectLater(
        () => repository.login(
          documentNumber: '0801199012345',
          birthDate: 'fecha-incorrecta',
          rememberMe: true,
        ),
        throwsA(isA<AuthException>()),
      );
      expect(local.lastSavedUser, isNull);
    });
  });

  group('getSavedUser', () {
    test('devuelve la entidad mapeada cuando hay usuario guardado', () async {
      local.savedUser = _tUserModel;

      final user = await repository.getSavedUser();

      expect(user?.documentNumber, _tUserModel.documentNumber);
    });

    test('devuelve null cuando no hay usuario guardado', () async {
      local.savedUser = null;

      final user = await repository.getSavedUser();

      expect(user, isNull);
    });
  });

  group('getters delegados', () {
    test('getSavedDocumentNumber delega en el datasource local', () async {
      local.savedDocumentNumber = '0801199012345';

      expect(await repository.getSavedDocumentNumber(), '0801199012345');
    });

    test('getSavedBirthDate delega en el datasource local', () async {
      local.savedBirthDate = '1990-01-01';

      expect(await repository.getSavedBirthDate(), '1990-01-01');
    });

    test('getSavedRememberMe delega en el datasource local', () async {
      local.savedRememberMe = true;

      expect(await repository.getSavedRememberMe(), isTrue);
    });
  });

  group('logout', () {
    test('delega en clearAll del datasource local', () async {
      await repository.logout();

      expect(local.clearAllCalled, isTrue);
    });
  });
}
