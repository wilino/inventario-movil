import '../repositories/auth_repository.dart';

/// Caso de uso: Cerrar sesión
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    await repository.signOut();
  }
}
