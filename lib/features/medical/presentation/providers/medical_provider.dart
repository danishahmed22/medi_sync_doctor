import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/medical/data/repositories_impl/medical_repository_impl.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/prescription_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/visit_entity.dart';
import 'package:medisync_doctor/features/medical/domain/repositories/medical_repository.dart';

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) {
  return MedicalRepositoryImpl(FirebaseFirestore.instance);
});

// ── Search & Lookup ──────────────────────────────────────────────────────────

final patientSearchQueryProvider = StateProvider<String>((ref) => '');

final patientSearchResultsProvider = FutureProvider<List<PatientEntity>>((ref) {
  final query = ref.watch(patientSearchQueryProvider);
  if (query.isEmpty) return [];
  return ref.read(medicalRepositoryProvider).searchPatients(query);
});

// ── Consultation State ───────────────────────────────────────────────────────

class ConsultationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveConsultation({
    required PatientEntity patient,
    required String symptoms,
    required String diagnosis,
    required List<MedicineInfo> medicines,
    String? tokenId,
  }) async {
    final doctor = ref.read(authStateProvider).value;
    final clinic = ref.read(currentClinicProvider).value;
    
    if (doctor == null || clinic == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final visit = VisitEntity(
        visitId: '',
        patientId: patient.patientId,
        clinicId: clinic.clinicId,
        doctorId: doctor.uid,
        tokenId: tokenId,
        symptoms: symptoms,
        diagnosis: diagnosis,
        notes: '',
        createdAt: DateTime.now(),
      );

      await ref.read(medicalRepositoryProvider).saveConsultation(
        visit: visit,
        medicines: medicines,
        tokenId: tokenId,
      );
    });
  }
}

final consultationProvider = AsyncNotifierProvider<ConsultationNotifier, void>(() {
  return ConsultationNotifier();
});

// ── Patient History ─────────────────────────────────────────────────────────

final patientVisitsProvider = StreamProvider.family<List<VisitEntity>, String>((ref, patientId) {
  return ref.read(medicalRepositoryProvider).watchPatientVisits(patientId);
});
