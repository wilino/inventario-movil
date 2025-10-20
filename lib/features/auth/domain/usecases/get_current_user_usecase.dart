import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Obtener usuario actual
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}
