import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registrar nuevo usuario
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User> call(String email, String password, String fullName) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      throw Exception('Todos los campos son requeridos');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Email inválido');
    }

    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    if (fullName.length < 3) {
      throw Exception('El nombre debe tener al menos 3 caracteres');
    }

    return await repository.signUp(email, password, fullName);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
