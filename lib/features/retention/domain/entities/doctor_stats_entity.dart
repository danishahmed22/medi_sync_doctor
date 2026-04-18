import 'package:equatable/equatable.dart';

class DoctorStatsEntity extends Equatable {
  const DoctorStatsEntity({
    required this.doctorId,
    required this.date,
    required this.totalPatientsToday,
    required this.avgConsultationTimeToday,
    required this.skippedCountToday,
    required this.estimatedRevenueToday,
    required this.timeSavedInMinutesToday,
  });

  final String doctorId;
  final String date; // YYYY-MM-DD
  final int totalPatientsToday;
  final double avgConsultationTimeToday;
  final int skippedCountToday;
  final double estimatedRevenueToday;
  final double timeSavedInMinutesToday;

  @override
  List<Object?> get props => [
        doctorId,
        date,
        totalPatientsToday,
        avgConsultationTimeToday,
        skippedCountToday,
        estimatedRevenueToday,
        timeSavedInMinutesToday,
      ];
}
