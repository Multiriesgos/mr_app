import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user, {required bool rememberMe});
  Future<UserModel?> getSavedUser();
  Future<String?> getSavedDocumentNumber();
  Future<bool> getSavedRememberMe();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _kUsername = 'KEY_USERNAME';
  static const _kEmail = 'KEY_EMAIL';
  static const _kName = 'KEY_NAME';
  static const _kSearch = 'KEY_SEARCH';
  static const _kRemind = 'KEY_REMIND';

  @override
  Future<void> saveUser(UserModel user, {required bool rememberMe}) async {
    await Future.wait([
      _storage.write(key: _kUsername, value: user.documentNumber),
      _storage.write(key: _kEmail, value: user.email),
      _storage.write(key: _kName, value: user.name),
      _storage.write(key: _kSearch, value: user.docSearch),
      _storage.write(key: _kRemind, value: rememberMe.toString()),
    ]);
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final rememberMe = await getSavedRememberMe();
    if (!rememberMe) return null;

    final documentNumber = await _storage.read(key: _kUsername);
    if (documentNumber == null || documentNumber.isEmpty) return null;

    final email = await _storage.read(key: _kEmail);
    final name = await _storage.read(key: _kName) ?? '';
    final docSearch = await _storage.read(key: _kSearch) ?? '';

    return UserModel(
      documentNumber: documentNumber,
      name: name,
      email: email,
      docSearch: docSearch,
    );
  }

  @override
  Future<String?> getSavedDocumentNumber() async {
    final rememberMe = await getSavedRememberMe();
    if (!rememberMe) return null;
    return _storage.read(key: _kUsername);
  }

  @override
  Future<bool> getSavedRememberMe() async {
    final value = await _storage.read(key: _kRemind);
    return value?.toLowerCase() == 'true';
  }

  @override
  Future<void> clearAll() => _storage.deleteAll();
}
