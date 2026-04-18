import 'package:equatable/equatable.dart';

class ClinicStatsEntity extends Equatable {
  const ClinicStatsEntity({
    required this.clinicId,
    required this.avgConsultationTimeInMinutes,
    required this.lastUpdated,
  });

  final String clinicId;
  final double avgConsultationTimeInMinutes;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [clinicId, avgConsultationTimeInMinutes, lastUpdated];
}
