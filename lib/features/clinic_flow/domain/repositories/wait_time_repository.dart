import 'package:medisync_doctor/features/clinic_flow/domain/entities/consultation_log_entity.dart';

abstract class WaitTimeRepository {
  /// Records a completed consultation duration for historical tracking.
  Future<void> logConsultation({
    required String clinicId,
    required double durationInMinutes,
    required String consultationType,
  });

  /// Fetches the last N consultation logs for a specific clinic.
  Future<List<ConsultationLogEntity>> getRecentLogs(String clinicId, {int limit = 10});

  /// Fetches average durations per time slot if available.
  Future<Map<String, double>> getTimeSlotAverages(String clinicId);
  
  /// Records a skipped token to update no-show rate.
  Future<void> trackNoShow(String clinicId, {bool isSkipped = true});

  /// Fetches the current no-show rate for the clinic.
  Future<double> getNoShowRate(String clinicId);
}
