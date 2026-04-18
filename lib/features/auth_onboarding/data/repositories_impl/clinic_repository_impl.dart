import 'package:medisync_doctor/features/auth_onboarding/data/datasources/firestore_datasource.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/models/clinic_model.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/clinic_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/clinic_repository.dart';

/// Concrete implementation of [ClinicRepository].
class ClinicRepositoryImpl implements ClinicRepository {
  const ClinicRepositoryImpl(this._datasource);
  final FirestoreDatasource _datasource;

  @override
  Future<ClinicEntity> createClinic({
    required String doctorId,
    required String clinicName,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final model = ClinicModel(
      clinicId: '', 
      clinicName: clinicName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      doctorId: doctorId,
      staffIds: const [],
      rating: 0.0,
      ratingCount: 0,
      createdAt: DateTime.now(),
    );
    final created = await _datasource.createClinic(model);
    return created.toEntity();
  }

  @override
  Stream<List<ClinicEntity>> watchDoctorClinics(String doctorId) {
    return _datasource
        .watchClinicsByDoctor(doctorId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<ClinicEntity>> watchStaffClinics(List<String> clinicIds) {
    return _datasource
        .watchClinicsByIds(clinicIds)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<ClinicEntity?> getClinicById(String clinicId) async {
    final model = await _datasource.getClinicById(clinicId);
    return model?.toEntity();
  }

  @override
  Stream<ClinicEntity?> watchClinicById(String clinicId) {
    return _datasource
        .watchClinic(clinicId)
        .map((model) => model?.toEntity());
  }
}
