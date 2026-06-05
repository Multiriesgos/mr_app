import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/domain/repositories/auth_repository.dart';

import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<User> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  }) async {
    final model = await _remote.login(
      documentNumber: documentNumber,
      birthDate: birthDate,
    );
    await _local.saveUser(model, rememberMe: rememberMe);
    return model.toEntity();
  }

  @override
  Future<User?> getSavedUser() async {
    final model = await _local.getSavedUser();
    return model?.toEntity();
  }

  @override
  Future<String?> getSavedDocumentNumber() =>
      _local.getSavedDocumentNumber();

  @override
  Future<bool> getSavedRememberMe() => _local.getSavedRememberMe();

  @override
  Future<void> logout() => _local.clearAll();
}
