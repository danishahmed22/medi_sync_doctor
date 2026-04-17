import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/auth_repository.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';

class SignInWithGoogleParams {
  const SignInWithGoogleParams();
}

/// Signs the user in via Google OAuth.
///
/// Returns a [GoogleSignInResult] containing the Firebase User and whether
/// this is a new account (so the presentation layer can route accordingly).
class SignInWithGoogle {
  const SignInWithGoogle(this._authRepo, this._inviteRepo);

  final AuthRepository _authRepo;
  final InviteRepository _inviteRepo;

  Future<GoogleSignInResult> call(SignInWithGoogleParams params) async {
    final result = await _authRepo.signInWithGoogle();
    final firebaseUser = result.firebaseUser;
    final isNewUser = result.isNewUser;

    MedicalStaffEntity? staffProfile;
    if (!isNewUser) {
      // Existing user — fetch profile
      staffProfile =
          await _inviteRepo.watchStaffProfile(firebaseUser.uid).first;
    }

    return GoogleSignInResult(
      firebaseUser: firebaseUser,
      isNewUser: isNewUser,
      staffProfile: staffProfile,
    );
  }
}

class GoogleSignInResult {
  const GoogleSignInResult({
    required this.firebaseUser,
    required this.isNewUser,
    this.staffProfile,
  });

  final dynamic firebaseUser;
  final bool isNewUser;
  final MedicalStaffEntity? staffProfile;
}
