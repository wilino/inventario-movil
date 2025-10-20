import '../entities/user.dart';

/// Interfaz del repositorio de autenticación
abstract class AuthRepository {
  /// Iniciar sesión con email y contraseña
  Future<User> signIn(String email, String password);

  /// Registrar nuevo usuario
  Future<User> signUp(String email, String password, String fullName);

  /// Cerrar sesión
  Future<void> signOut();

  /// Obtener usuario actual
  Future<User?> getCurrentUser();

  /// Verificar si hay sesión activa
  Future<bool> isSignedIn();

  /// Recuperar contraseña
  Future<void> resetPassword(String email);

  /// Actualizar perfil de usuario
  Future<User> updateProfile({String? fullName, String? avatarUrl});

  /// Stream de cambios de sesión
  Stream<User?> get authStateChanges;
}
