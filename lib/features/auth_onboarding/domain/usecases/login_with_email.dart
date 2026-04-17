import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/auth_repository.dart';

class LoginWithEmailParams {
  const LoginWithEmailParams({required this.email, required this.password});
  final String email;
  final String password;
}

/// Signs in an existing user with email + password.
class LoginWithEmail {
  const LoginWithEmail(this._authRepo);
  final AuthRepository _authRepo;

  Future<dynamic> call(LoginWithEmailParams params) async {
    return _authRepo.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
