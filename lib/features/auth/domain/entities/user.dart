import 'package:equatable/equatable.dart';

/// Entidad de dominio para el Usuario
class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? role;
  final DateTime createdAt;
  final DateTime? lastSeen;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
    required this.createdAt,
    this.lastSeen,
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        role,
        createdAt,
        lastSeen,
      ];
}
