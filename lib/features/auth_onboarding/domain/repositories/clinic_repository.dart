import 'package:medisync_doctor/features/auth_onboarding/domain/entities/clinic_entity.dart';

/// Abstract contract for all clinic data operations.
abstract interface class ClinicRepository {
  /// Creates a new clinic document and updates the doctor's clinicIds list.
  Future<ClinicEntity> createClinic({
    required String doctorId,
    required String clinicName,
    required String address,
    required double latitude,
    required double longitude,
  });

  /// Returns a real-time stream of all clinics for the given [doctorId].
  Stream<List<ClinicEntity>> watchDoctorClinics(String doctorId);

  /// Returns a real-time stream of all clinics a staff member belongs to.
  Stream<List<ClinicEntity>> watchStaffClinics(List<String> clinicIds);

  /// Fetches a single clinic by ID.
  Future<ClinicEntity?> getClinicById(String clinicId);

  /// Returns a real-time stream of a single clinic document.
  Stream<ClinicEntity?> watchClinicById(String clinicId);
}
