import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/staff_management/data/models/activity_log_model.dart';
import 'package:medisync_doctor/features/staff_management/domain/entities/activity_log_entity.dart';
import 'package:medisync_doctor/features/staff_management/domain/repositories/staff_management_repository.dart';

class StaffManagementRepositoryImpl implements StaffManagementRepository {
  StaffManagementRepositoryImpl(this._db);
  final FirebaseFirestore _db;

  @override
  Stream<List<ActivityLogEntity>> watchStaffActivity(String clinicId) {
    return _db
        .collection(FirestoreCollections.staffActivityLogs)
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ActivityLogModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<void> logActivity(ActivityLogEntity log) async {
    final ref = _db.collection(FirestoreCollections.staffActivityLogs).doc();
    final model = ActivityLogModel.fromEntity(log.copyWith(logId: ref.id));
    await ref.set(model.toFirestore());
  }

  @override
  Future<Map<String, int>> getStaffPerformanceStats(String clinicId) async {
    // In a real production app, this would use pre-aggregated stats 
    // or a complex aggregation query. For now, we'll fetch today's logs.
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final snap = await _db
        .collection(FirestoreCollections.staffActivityLogs)
        .where('clinicId', isEqualTo: clinicId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .get();

    int totalActions = snap.size;
    Set<String> activeUsers = {};
    int exceptions = 0;

    for (var doc in snap.docs) {
      final data = doc.data();
      activeUsers.add(data['userId'] as String);
      if (data['actionType'] == 'SKIP_TOKEN') exceptions++;
    }

    return {
      'totalActions': totalActions,
      'activeStaff': activeUsers.length,
      'exceptions': exceptions,
    };
  }
}
