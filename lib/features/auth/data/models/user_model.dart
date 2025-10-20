import '../../domain/entities/user.dart';

/// Modelo de datos para Usuario
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.avatarUrl,
    super.role,
    required super.createdAt,
    super.lastSeen,
  });

  /// Crear desde JSON de Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  /// Crear desde User de Supabase Auth
  factory UserModel.fromSupabaseUser(
    dynamic supabaseUser,
    Map<String, dynamic>? profile,
  ) {
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      role: profile?['role'] as String?,
      createdAt: DateTime.parse(supabaseUser.createdAt),
      lastSeen: profile?['last_seen'] != null
          ? DateTime.parse(profile!['last_seen'] as String)
          : null,
    );
  }
}
