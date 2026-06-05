import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  }) =>
      _repository.login(
        documentNumber: documentNumber,
        birthDate: birthDate,
        rememberMe: rememberMe,
      );
}
