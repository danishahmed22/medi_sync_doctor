import 'package:equatable/equatable.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';

class ConsultationLogEntity extends Equatable {
  const ConsultationLogEntity({
    required this.logId,
    required this.clinicId,
    required this.durationInMinutes,
    required this.consultationType,
    required this.createdAt,
  });

  final String logId;
  final String clinicId;
  final double durationInMinutes;
  final ConsultationType consultationType;
  final DateTime createdAt;

  @override
  List<Object?> get props => [logId, clinicId, durationInMinutes, consultationType, createdAt];
}
