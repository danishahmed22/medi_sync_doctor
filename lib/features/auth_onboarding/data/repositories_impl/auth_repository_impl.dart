import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/datasources/auth_remote_datasource.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);
  final AuthRemoteDatasource _datasource;

  @override
  Stream<User?> get authStateChanges => _datasource.authStateChanges;

  @override
  User? get currentUser => _datasource.currentUser;

  @override
  Future<({User firebaseUser, bool isNewUser})> signInWithGoogle() =>
      _datasource.signInWithGoogle();

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      _datasource.signUpWithEmail(email: email, password: password);

  @override
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) =>
      _datasource.loginWithEmail(email: email, password: password);

  @override
  Future<void> logout() => _datasource.logout();
}
