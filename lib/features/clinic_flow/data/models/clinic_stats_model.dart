import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/clinic_stats_entity.dart';

class ClinicStatsModel {
  const ClinicStatsModel({
    required this.clinicId,
    required this.avgConsultationTimeInMinutes,
    required this.lastUpdated,
  });

  final String clinicId;
  final double avgConsultationTimeInMinutes;
  final DateTime lastUpdated;

  factory ClinicStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClinicStatsModel(
      clinicId: doc.id,
      avgConsultationTimeInMinutes: (data['avgConsultationTime'] as num?)?.toDouble() ?? 10.0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'avgConsultationTime': avgConsultationTimeInMinutes,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  ClinicStatsEntity toEntity() {
    return ClinicStatsEntity(
      clinicId: clinicId,
      avgConsultationTimeInMinutes: avgConsultationTimeInMinutes,
      lastUpdated: lastUpdated,
    );
  }
}
