import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/clinic_flow/data/models/appointment_model.dart';
import 'package:medisync_doctor/features/clinic_flow/data/models/clinic_stats_model.dart';
import 'package:medisync_doctor/features/clinic_flow/data/models/token_model.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/appointment_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/clinic_stats_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/repositories/clinic_flow_repository.dart';

class ClinicFlowRepositoryImpl implements ClinicFlowRepository {
  ClinicFlowRepositoryImpl(this._db);

  final FirebaseFirestore _db;

  CollectionReference get _tokensCol => _db.collection(FirestoreCollections.tokens);
  CollectionReference get _statsCol => _db.collection(FirestoreCollections.clinicFlowStats);
  CollectionReference get _appointmentsCol => _db.collection(FirestoreCollections.appointments);
  CollectionReference get _clinicsCol => _db.collection(FirestoreCollections.clinics);

  @override
  Stream<List<TokenEntity>> watchQueue(String clinicId) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return _tokensCol
        .where('clinicId', isEqualTo: clinicId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TokenModel.fromFirestore(doc).toEntity()).toList());
  }

  @override
  Future<TokenEntity> generateToken({
    required String clinicId,
    required String patientName,
    String? patientId,
    bool isAppointment = false,
    DateTime? scheduledTime,
  }) async {
    return await _db.runTransaction((transaction) async {
      final clinicDoc = await transaction.get(_clinicsCol.doc(clinicId));
      if (!clinicDoc.exists) throw Exception('Clinic not found');

      final clinicData = clinicDoc.data() as Map<String, dynamic>;
      final lastTokenNumber = clinicData['totalTokensIssuedToday'] as int? ?? 0;
      final newTokenNumber = lastTokenNumber + 1;

      final newTokenRef = _tokensCol.doc();
      final tokenModel = TokenModel(
        tokenId: newTokenRef.id,
        clinicId: clinicId,
        patientName: patientName,
        patientId: patientId,
        tokenNumber: newTokenNumber,
        status: TokenStatus.waiting.firestoreValue,
        createdAt: DateTime.now(),
        isAppointment: isAppointment,
        scheduledTime: scheduledTime,
        priority: 0,
      );

      transaction.set(newTokenRef, tokenModel.toFirestore());
      transaction.update(_clinicsCol.doc(clinicId), {
        'totalTokensIssuedToday': newTokenNumber,
      });

      return tokenModel.toEntity();
    });
  }

  @override
  Future<void> startConsultation(String tokenId) async {
    await _tokensCol.doc(tokenId).update({
      'status': TokenStatus.inProgress.firestoreValue,
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeConsultation(String tokenId, String clinicId) async {
    final now = DateTime.now();
    final tokenDoc = await _tokensCol.doc(tokenId).get();
    final token = TokenModel.fromFirestore(tokenDoc);
    
    await _db.runTransaction((transaction) async {
      transaction.update(_tokensCol.doc(tokenId), {
        'status': TokenStatus.completed.firestoreValue,
        'completedAt': Timestamp.fromDate(now),
      });

      if (token.startedAt != null) {
        final durationInMinutes = now.difference(token.startedAt!).inSeconds / 60.0;
        final statsRef = _statsCol.doc(clinicId);
        final statsSnap = await transaction.get(statsRef);
        
        if (statsSnap.exists) {
          final currentAvg = (statsSnap.data() as Map<String, dynamic>)['avgConsultationTime'] as num? ?? 10.0;
          final newAvg = (currentAvg * 9 + durationInMinutes) / 10;
          transaction.update(statsRef, {
            'avgConsultationTime': newAvg,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(statsRef, {
            'avgConsultationTime': durationInMinutes,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  @override
  Future<void> skipToken(String tokenId) async {
    await _tokensCol.doc(tokenId).update({
      'status': TokenStatus.skipped.firestoreValue,
    });
  }

  @override
  Future<void> prioritizeToken(String tokenId, int priority) async {
    await _tokensCol.doc(tokenId).update({
      'priority': priority,
    });
  }

  @override
  Future<void> reorderQueue(List<TokenEntity> reorderedList) async {
    final batch = _db.batch();
    // We update priorities based on index to maintain order.
    // Higher index in list (visually lower) gets lower priority value.
    for (int i = 0; i < reorderedList.length; i++) {
      final token = reorderedList[i];
      final newPriority = (reorderedList.length - i) * 10;
      batch.update(_tokensCol.doc(token.tokenId), {'priority': newPriority});
    }
    await batch.commit();
  }

  @override
  Stream<List<AppointmentEntity>> watchAppointments(String clinicId) {
    return _appointmentsCol
        .where('clinicId', isEqualTo: clinicId)
        .where('status', isEqualTo: AppointmentStatus.booked.firestoreValue)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => AppointmentModel.fromFirestore(doc).toEntity()).toList());
  }

  @override
  Future<AppointmentEntity> createAppointment({
    required String clinicId,
    required String patientName,
    required DateTime scheduledTime,
    String? patientId,
  }) async {
    final ref = _appointmentsCol.doc();
    final model = AppointmentModel(
      appointmentId: ref.id,
      clinicId: clinicId,
      patientName: patientName,
      patientId: patientId,
      scheduledTime: scheduledTime,
      status: AppointmentStatus.booked.firestoreValue,
      createdAt: DateTime.now(),
    );
    await ref.set(model.toFirestore());
    return model.toEntity();
  }

  @override
  Future<void> convertAppointmentToToken(AppointmentEntity appointment) async {
    await generateToken(
      clinicId: appointment.clinicId,
      patientName: appointment.patientName,
      patientId: appointment.patientId,
      isAppointment: true,
      scheduledTime: appointment.scheduledTime,
    );

    await _appointmentsCol.doc(appointment.appointmentId).update({
      'status': AppointmentStatus.completed.firestoreValue,
    });
  }

  @override
  Stream<ClinicStatsEntity?> watchClinicStats(String clinicId) {
    return _statsCol.doc(clinicId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ClinicStatsModel.fromFirestore(snap).toEntity();
    });
  }
}
