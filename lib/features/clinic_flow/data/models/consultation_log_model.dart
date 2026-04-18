import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/consultation_log_entity.dart';

class ConsultationLogModel {
  const ConsultationLogModel({
    required this.logId,
    required this.clinicId,
    required this.durationInMinutes,
    required this.consultationType,
    required this.createdAt,
  });

  final String logId;
  final String clinicId;
  final double durationInMinutes;
  final String consultationType;
  final DateTime createdAt;

  factory ConsultationLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConsultationLogModel(
      logId: doc.id,
      clinicId: data['clinicId'] as String? ?? '',
      durationInMinutes: (data['duration'] as num?)?.toDouble() ?? 10.0,
      consultationType: data['consultationType'] as String? ?? ConsultationType.normal.firestoreValue,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId,
      'duration': durationInMinutes,
      'consultationType': consultationType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ConsultationLogEntity toEntity() => ConsultationLogEntity(
        logId: logId,
        clinicId: clinicId,
        durationInMinutes: durationInMinutes,
        consultationType: ConsultationType.fromString(consultationType),
        createdAt: createdAt,
      );
}
