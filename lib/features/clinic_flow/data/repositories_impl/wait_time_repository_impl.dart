import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/clinic_flow/data/models/consultation_log_model.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/consultation_log_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/repositories/wait_time_repository.dart';

class WaitTimeRepositoryImpl implements WaitTimeRepository {
  WaitTimeRepositoryImpl(this._db);
  final FirebaseFirestore _db;

  CollectionReference get _logsCol => _db.collection(FirestoreCollections.consultationLogs);
  CollectionReference get _statsCol => _db.collection(FirestoreCollections.clinicFlowStats);

  @override
  Future<void> logConsultation({
    required String clinicId,
    required double durationInMinutes,
    required String consultationType,
  }) async {
    final logRef = _logsCol.doc();
    final model = ConsultationLogModel(
      logId: logRef.id,
      clinicId: clinicId,
      durationInMinutes: durationInMinutes,
      consultationType: consultationType,
      createdAt: DateTime.now(),
    );
    await logRef.set(model.toFirestore());
  }

  @override
  Future<List<ConsultationLogEntity>> getRecentLogs(String clinicId, {int limit = 10}) async {
    final snap = await _logsCol
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map((doc) => ConsultationLogModel.fromFirestore(doc).toEntity()).toList();
  }

  @override
  Future<Map<String, double>> getTimeSlotAverages(String clinicId) async {
    final snap = await _statsCol.doc(clinicId).get();
    if (!snap.exists) return {};
    
    final data = snap.data() as Map<String, dynamic>;
    final slots = data['timeSlots'] as Map<String, dynamic>? ?? {};
    return slots.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  @override
  Future<void> trackNoShow(String clinicId, {bool isSkipped = true}) async {
    final ref = _db.collection('no_show_stats').doc(clinicId);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (!snap.exists) {
        transaction.set(ref, {
          'totalTokens': 1,
          'skippedTokens': isSkipped ? 1 : 0,
        });
      } else {
        final data = snap.data()!;
        transaction.update(ref, {
          'totalTokens': (data['totalTokens'] as int) + 1,
          'skippedTokens': (data['skippedTokens'] as int) + (isSkipped ? 1 : 0),
        });
      }
    });
  }

  @override
  Future<double> getNoShowRate(String clinicId) async {
    final snap = await _db.collection('no_show_stats').doc(clinicId).get();
    if (!snap.exists) return 0.1; // Default 10% no-show rate
    
    final data = snap.data()!;
    final total = data['totalTokens'] as int? ?? 1;
    final skipped = data['skippedTokens'] as int? ?? 0;
    if (total == 0) return 0.1;
    return skipped / total;
  }
}
