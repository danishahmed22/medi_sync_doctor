import 'package:equatable/equatable.dart';

class DailyStatsEntity extends Equatable {
  const DailyStatsEntity({
    required this.clinicId,
    required this.date,
    required this.totalPatients,
    required this.completedConsultations,
    required this.skippedTokens,
    required this.avgConsultationTime,
    required this.totalRevenue,
    required this.medicineUsageCount,
  });

  final String clinicId;
  final String date; // YYYY-MM-DD
  final int totalPatients;
  final int completedConsultations;
  final int skippedTokens;
  final double avgConsultationTime;
  final double totalRevenue;
  final int medicineUsageCount;

  @override
  List<Object?> get props => [
        clinicId,
        date,
        totalPatients,
        completedConsultations,
        skippedTokens,
        avgConsultationTime,
        totalRevenue,
        medicineUsageCount,
      ];
}
