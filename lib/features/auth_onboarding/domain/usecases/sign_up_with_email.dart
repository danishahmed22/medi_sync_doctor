import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/auth_repository.dart';

class SignUpWithEmailParams {
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

/// Creates a new Firebase Auth account with email + password.
/// Profile creation (Firestore) is handled separately by [CreateStaffProfile].
class SignUpWithEmail {
  const SignUpWithEmail(this._authRepo);

  final AuthRepository _authRepo;

  Future<dynamic> call(SignUpWithEmailParams params) async {
    return _authRepo.signUpWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
