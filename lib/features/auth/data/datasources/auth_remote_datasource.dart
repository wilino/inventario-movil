import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Data source remoto para autenticación con Supabase
class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource(this.client);

  /// Iniciar sesión
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      // Obtener perfil del usuario
      final profile = await _getUserProfile(response.user!.id);

      return UserModel.fromSupabaseUser(response.user, profile);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Registrar usuario
  Future<UserModel> signUp(
      String email, String password, String fullName) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw Exception('Error al registrar usuario');
      }

      // Crear perfil en la tabla user_profiles
      await client.from('user_profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': 'user',
      });

      final profile = await _getUserProfile(response.user!.id);

      return UserModel.fromSupabaseUser(response.user, profile);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final profile = await _getUserProfile(user.id);
      return UserModel.fromSupabaseUser(user, profile);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Verificar si hay sesión activa
  Future<bool> isSignedIn() async {
    return client.auth.currentUser != null;
  }

  /// Recuperar contraseña
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Error al recuperar contraseña: $e');
    }
  }

  /// Actualizar perfil
  Future<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await client.from('user_profiles').update(updates).eq('id', user.id);

      final profile = await _getUserProfile(user.id);
      return UserModel.fromSupabaseUser(user, profile);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  /// Obtener perfil de usuario desde la tabla
  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Stream de cambios de autenticación
  Stream<UserModel?> get authStateChanges {
    return client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;

      final profile = await _getUserProfile(user.id);
      return UserModel.fromSupabaseUser(user, profile);
    });
  }
}
