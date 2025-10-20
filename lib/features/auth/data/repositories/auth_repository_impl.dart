import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> signIn(String email, String password) async {
    return await remoteDataSource.signIn(email, password);
  }

  @override
  Future<User> signUp(String email, String password, String fullName) async {
    return await remoteDataSource.signUp(email, password, fullName);
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<bool> isSignedIn() async {
    return await remoteDataSource.isSignedIn();
  }

  @override
  Future<void> resetPassword(String email) async {
    await remoteDataSource.resetPassword(email);
  }

  @override
  Future<User> updateProfile({String? fullName, String? avatarUrl}) async {
    return await remoteDataSource.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;
}
