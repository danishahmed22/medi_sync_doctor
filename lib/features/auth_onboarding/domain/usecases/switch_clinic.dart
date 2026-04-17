import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';

/// Switches the user's active clinic context.
///
/// Persists [clinicId] in SharedPreferences so the selection survives app
/// restarts. The UI watches [InviteRepository.getCurrentClinic] to react.
class SwitchClinic {
  const SwitchClinic(this._inviteRepo);
  final InviteRepository _inviteRepo;

  Future<void> call(String clinicId) =>
      _inviteRepo.setCurrentClinic(clinicId);

  Future<String?> getCurrent() => _inviteRepo.getCurrentClinic();
}
