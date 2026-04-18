import 'package:medisync_doctor/features/clinic_flow/domain/entities/appointment_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/clinic_stats_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';

abstract class ClinicFlowRepository {
  // ── Tokens ───────────────────────────────────────────────────────────────
  
  Stream<List<TokenEntity>> watchQueue(String clinicId);
  
  Future<TokenEntity> generateToken({
    required String clinicId,
    required String patientName,
    String? patientId,
    bool isAppointment = false,
    DateTime? scheduledTime,
  });

  Future<void> startConsultation(String tokenId);
  
  Future<void> completeConsultation(String tokenId, String clinicId);
  
  Future<void> skipToken(String tokenId);

  Future<void> prioritizeToken(String tokenId, int priority);

  /// Reorders the queue by updating priorities of affected tokens.
  Future<void> reorderQueue(List<TokenEntity> reorderedList);

  // ── Appointments ──────────────────────────────────────────────────────────
  
  Stream<List<AppointmentEntity>> watchAppointments(String clinicId);
  
  Future<AppointmentEntity> createAppointment({
    required String clinicId,
    required String patientName,
    required DateTime scheduledTime,
    String? patientId,
  });

  Future<void> convertAppointmentToToken(AppointmentEntity appointment);

  // ── Stats & Prediction ─────────────────────────────────────────────────────
  
  Stream<ClinicStatsEntity?> watchClinicStats(String clinicId);
}
