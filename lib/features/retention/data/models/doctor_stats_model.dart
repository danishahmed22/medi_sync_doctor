import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/retention/domain/entities/doctor_stats_entity.dart';

class DoctorStatsModel {
  const DoctorStatsModel({
    required this.doctorId,
    required this.date,
    required this.totalPatientsToday,
    required this.avgConsultationTimeToday,
    required this.skippedCountToday,
    required this.estimatedRevenueToday,
    required this.timeSavedInMinutesToday,
  });

  final String doctorId;
  final String date;
  final int totalPatientsToday;
  final double avgConsultationTimeToday;
  final int skippedCountToday;
  final double estimatedRevenueToday;
  final double timeSavedInMinutesToday;

  factory DoctorStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorStatsModel(
      doctorId: data['doctorId'] as String? ?? '',
      date: doc.id,
      totalPatientsToday: data['totalPatientsToday'] as int? ?? 0,
      avgConsultationTimeToday: (data['avgConsultationTimeToday'] as num?)?.toDouble() ?? 0.0,
      skippedCountToday: data['skippedCountToday'] as int? ?? 0,
      estimatedRevenueToday: (data['estimatedRevenueToday'] as num?)?.toDouble() ?? 0.0,
      timeSavedInMinutesToday: (data['timeSavedInMinutesToday'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'totalPatientsToday': totalPatientsToday,
      'avgConsultationTimeToday': avgConsultationTimeToday,
      'skippedCountToday': skippedCountToday,
      'estimatedRevenueToday': estimatedRevenueToday,
      'timeSavedInMinutesToday': timeSavedInMinutesToday,
    };
  }

  DoctorStatsEntity toEntity() => DoctorStatsEntity(
        doctorId: doctorId,
        date: date,
        totalPatientsToday: totalPatientsToday,
        avgConsultationTimeToday: avgConsultationTimeToday,
        skippedCountToday: skippedCountToday,
        estimatedRevenueToday: estimatedRevenueToday,
        timeSavedInMinutesToday: timeSavedInMinutesToday,
      );
}
