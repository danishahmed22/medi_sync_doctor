import 'package:equatable/equatable.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';

class TokenEntity extends Equatable {
  const TokenEntity({
    required this.tokenId,
    required this.clinicId,
    required this.patientName,
    this.patientId,
    required this.tokenNumber,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.isAppointment,
    this.scheduledTime,
    this.priority = 0,
    this.consultationType = ConsultationType.normal,
  });

  final String tokenId;
  final String clinicId;
  final String patientName;
  final String? patientId;
  final int tokenNumber;
  final TokenStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isAppointment;
  final DateTime? scheduledTime;
  final int priority;
  final ConsultationType consultationType;

  bool get isWaiting => status == TokenStatus.waiting;
  bool get isInProgress => status == TokenStatus.inProgress;
  bool get isCompleted => status == TokenStatus.completed;
  bool get isSkipped => status == TokenStatus.skipped;

  TokenEntity copyWith({
    String? tokenId,
    String? clinicId,
    String? patientName,
    String? patientId,
    int? tokenNumber,
    TokenStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isAppointment,
    DateTime? scheduledTime,
    int? priority,
    ConsultationType? consultationType,
  }) {
    return TokenEntity(
      tokenId: tokenId ?? this.tokenId,
      clinicId: clinicId ?? this.clinicId,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isAppointment: isAppointment ?? this.isAppointment,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      priority: priority ?? this.priority,
      consultationType: consultationType ?? this.consultationType,
    );
  }

  @override
  List<Object?> get props => [
        tokenId,
        clinicId,
        patientName,
        patientId,
        tokenNumber,
        status,
        createdAt,
        startedAt,
        completedAt,
        isAppointment,
        scheduledTime,
        priority,
        consultationType,
      ];
}
