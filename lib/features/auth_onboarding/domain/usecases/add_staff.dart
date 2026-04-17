import 'package:medisync_doctor/features/auth_onboarding/domain/entities/invite_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/core/errors/app_exceptions.dart';

class AddStaffParams {
  const AddStaffParams({
    required this.clinicId,
    required this.clinicName,
    required this.email,
    this.phone,
    required this.role,
    required this.requestingDoctorId,
  });

  final String clinicId;
  final String clinicName;
  final String email;
  final String? phone;
  final UserRole role;

  /// Firebase UID of the doctor sending the invite — validated against RBAC.
  final String requestingDoctorId;
}

/// Sends a staff invite to the specified email address.
///
/// Business rules:
///  - Only doctors can invite staff ([UserRole.doctor] enforced by caller).
///  - A doctor cannot invite another doctor.
class AddStaff {
  const AddStaff(this._inviteRepo);
  final InviteRepository _inviteRepo;

  Future<InviteEntity> call(AddStaffParams params) async {
    if (params.role == UserRole.doctor) {
      throw const ValidationException(
        'You cannot invite a user with the Doctor role via this flow.',
      );
    }

    return _inviteRepo.sendInvite(
      clinicId: params.clinicId,
      clinicName: params.clinicName,
      email: params.email,
      phone: params.phone,
      role: params.role,
    );
  }
}
