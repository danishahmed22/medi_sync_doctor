import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/prescription_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/visit_entity.dart';

abstract class MedicalRepository {
  // ── Patients ─────────────────────────────────────────────────────────────
  
  Future<PatientEntity?> getPatientByPhone(String phone);

  Future<PatientEntity?> getPatientById(String patientId); // ADDED: Direct ID lookup

  Future<PatientEntity> createPatient(PatientEntity patient);
  
  Future<List<PatientEntity>> searchPatients(String query);

  // ── Consultations ────────────────────────────────────────────────────────
  
  /// Atomically saves a visit and its corresponding prescription.
  Future<void> saveConsultation({
    required VisitEntity visit,
    required List<MedicineInfo> medicines,
    String? tokenId,
  });

  // ── History ──────────────────────────────────────────────────────────────
  
  Stream<List<VisitEntity>> watchPatientVisits(String patientId);
  
  Future<PrescriptionEntity?> getPrescriptionByVisit(String visitId);
}
