import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mr_app/features/auth/data/models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user, {required bool rememberMe, String? birthDate});
  Future<UserModel?> getSavedUser();
  Future<String?> getSavedDocumentNumber();
  Future<String?> getSavedBirthDate();
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
  static const _kBirthDate = 'KEY_BIRTH_DATE';

  @override
  Future<void> saveUser(UserModel user, {required bool rememberMe, String? birthDate}) async {
    final writes = [
      _storage.write(key: _kUsername, value: user.documentNumber),
      _storage.write(key: _kEmail, value: user.email),
      _storage.write(key: _kName, value: user.name),
      _storage.write(key: _kSearch, value: user.docSearch),
      _storage.write(key: _kRemind, value: rememberMe.toString()),
    ];
    if (rememberMe && birthDate != null) {
      writes.add(_storage.write(key: _kBirthDate, value: birthDate));
    }
    await Future.wait(writes);
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
  Future<String?> getSavedBirthDate() async {
    final rememberMe = await getSavedRememberMe();
    if (!rememberMe) return null;
    return _storage.read(key: _kBirthDate);
  }

  @override
  Future<bool> getSavedRememberMe() async {
    final value = await _storage.read(key: _kRemind);
    return value?.toLowerCase() == 'true';
  }

  @override
  Future<void> clearAll() async {
    final rememberMe = await getSavedRememberMe();
    final keysToDelete = [_kEmail, _kName, _kSearch];
    if (!rememberMe) keysToDelete.addAll([_kUsername, _kRemind, _kBirthDate]);
    await Future.wait(keysToDelete.map((k) => _storage.delete(key: k)));
  }
}
