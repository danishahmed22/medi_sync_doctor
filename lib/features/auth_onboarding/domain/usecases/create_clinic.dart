import 'package:medisync_doctor/features/auth_onboarding/domain/entities/clinic_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/clinic_repository.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';

class CreateClinicParams {
  const CreateClinicParams({
    required this.doctorId,
    required this.clinicName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String doctorId;
  final String clinicName;
  final String address;
  final double latitude;
  final double longitude;
}

/// Creates a clinic and sets it as the doctor's active clinic.
///
/// Business rules enforced here:
///  - Only doctors can create clinics (caller should gate via RBAC).
///  - Newly created clinic is automatically set as [currentClinicId].
class CreateClinic {
  const CreateClinic(this._clinicRepo, this._inviteRepo);

  final ClinicRepository _clinicRepo;
  final InviteRepository _inviteRepo;

  Future<ClinicEntity> call(CreateClinicParams params) async {
    final clinic = await _clinicRepo.createClinic(
      doctorId: params.doctorId,
      clinicName: params.clinicName,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
    );

    // Persist the new clinic as the active one locally.
    await _inviteRepo.setCurrentClinic(clinic.clinicId);

    return clinic;
  }
}
