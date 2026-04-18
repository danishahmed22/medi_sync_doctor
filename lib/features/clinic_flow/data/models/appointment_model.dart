import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/appointment_entity.dart';

class AppointmentModel {
  const AppointmentModel({
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
  final String status;
  final DateTime createdAt;

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      appointmentId: doc.id,
      clinicId: data['clinicId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      patientId: data['patientId'] as String?,
      scheduledTime: (data['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? AppointmentStatus.booked.firestoreValue,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId,
      'patientName': patientName,
      if (patientId != null) 'patientId': patientId,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppointmentEntity toEntity() {
    return AppointmentEntity(
      appointmentId: appointmentId,
      clinicId: clinicId,
      patientName: patientName,
      patientId: patientId,
      scheduledTime: scheduledTime,
      status: AppointmentStatus.fromString(status),
      createdAt: createdAt,
    );
  }
}
