import 'package:medisync_doctor/features/retention/domain/entities/doctor_stats_entity.dart';
import 'package:medisync_doctor/features/retention/domain/entities/prescription_template_entity.dart';

abstract class RetentionRepository {
  // ── Daily Stats ──────────────────────────────────────────────────────────
  
  Stream<DoctorStatsEntity?> watchDailyStats(String doctorId, String date);
  
  Future<void> updateStatsOnConsultation({
    required String doctorId,
    required double consultationDurationMinutes,
    bool isSkipped = false,
  });

  // ── Weekly Summary ───────────────────────────────────────────────────────
  
  Future<List<DoctorStatsEntity>> getWeeklyStats(String doctorId, DateTime startOfWeek);
  
  Future<void> generateWeeklyReportPdf(String doctorId, List<DoctorStatsEntity> weeklyData);

  // ── Prescription Templates ───────────────────────────────────────────────
  
  Future<List<PrescriptionTemplateEntity>> getTemplates(String doctorId);
  
  Future<void> saveTemplate(PrescriptionTemplateEntity template);
  
  Future<void> deleteTemplate(String templateId);
}
