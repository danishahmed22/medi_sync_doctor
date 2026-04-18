import 'package:equatable/equatable.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';

class AppointmentEntity extends Equatable {
  const AppointmentEntity({
    required this.appointmentId,
    required this.clinicId,
    required this.patientName,
    this.patientId,
    required this.scheduledTime,
    required this.status,
    required this.createdAt,
  });

  final String appointmentId;
  final String clinicId;
  final String patientName;
  final String? patientId;
  final DateTime scheduledTime;
  final AppointmentStatus status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        appointmentId,
        clinicId,
        patientName,
        patientId,
        scheduledTime,
        status,
        createdAt,
      ];

  AppointmentEntity copyWith({
    String? appointmentId,
    String? clinicId,
    String? patientName,
    String? patientId,
    DateTime? scheduledTime,
    AppointmentStatus? status,
    DateTime? createdAt,
  }) {
    return AppointmentEntity(
      appointmentId: appointmentId ?? this.appointmentId,
      clinicId: clinicId ?? this.clinicId,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
