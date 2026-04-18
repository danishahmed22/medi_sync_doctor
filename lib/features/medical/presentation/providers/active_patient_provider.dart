import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/features/clinic_flow/presentation/providers/clinic_flow_provider.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/visit_entity.dart';
import 'package:medisync_doctor/features/medical/presentation/providers/medical_provider.dart';

/// Provider that automatically resolves the Patient details for the current active token.
final activePatientDetailProvider = FutureProvider.autoDispose<PatientEntity?>((ref) async {
  final currentToken = ref.watch(currentPatientProvider);
  
  if (currentToken == null) return null;

  // 1. Try to fetch existing patient by ID (Direct ID Lookup)
  if (currentToken.patientId != null && currentToken.patientId!.isNotEmpty) {
    final patient = await ref.read(medicalRepositoryProvider).getPatientById(currentToken.patientId!);
    if (patient != null) return patient;
  }

  // 2. If not found or no ID (Walk-in), return a temporary entity for the UI to use
  return PatientEntity(
    patientId: 'NEW_PATIENT',
    name: currentToken.patientName,
    phone: '', 
    age: 0,
    gender: 'Not Specified',
    createdAt: currentToken.createdAt,
  );
});

/// Watches the history of the currently active patient.
final activePatientHistoryProvider = StreamProvider.autoDispose<List<VisitEntity>>((ref) {
  final currentToken = ref.watch(currentPatientProvider);
  if (currentToken == null || currentToken.patientId == null) return Stream.value([]);
  return ref.read(medicalRepositoryProvider).watchPatientVisits(currentToken.patientId!);
});
