import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/auth_repository.dart';

/// Signs out the current Firebase Auth user.
class Logout {
  const Logout(this._authRepo);
  final AuthRepository _authRepo;

  Future<void> call() => _authRepo.logout();
}
