import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetSavedUserUseCase {
  const GetSavedUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.getSavedUser();
}
