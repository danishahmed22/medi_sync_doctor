import 'package:medisync_doctor/features/staff_management/domain/entities/activity_log_entity.dart';

abstract class StaffManagementRepository {
  Stream<List<ActivityLogEntity>> watchStaffActivity(String clinicId);
  
  Future<void> logActivity(ActivityLogEntity log);
  
  Future<Map<String, int>> getStaffPerformanceStats(String clinicId);
}
