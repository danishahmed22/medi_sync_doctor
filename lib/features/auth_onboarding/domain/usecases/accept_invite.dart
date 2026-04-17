import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';

/// Accepts a pending invite, updating Firestore atomically:
///  1. invite.status → "accepted"
///  2. medical_staff.clinicIds += clinicId
///  3. clinics.staffIds += userId
class AcceptInvite {
  const AcceptInvite(this._inviteRepo);
  final InviteRepository _inviteRepo;

  Future<void> call(String inviteId) => _inviteRepo.acceptInvite(inviteId);
}

/// Rejects a pending invite (sets status → "rejected").
class RejectInvite {
  const RejectInvite(this._inviteRepo);
  final InviteRepository _inviteRepo;

  Future<void> call(String inviteId) => _inviteRepo.rejectInvite(inviteId);
}
