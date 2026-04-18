import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';

class TokenModel {
  const TokenModel({
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
  });

  final String tokenId;
  final String clinicId;
  final String patientName;
  final String? patientId;
  final int tokenNumber;
  final String status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isAppointment;
  final DateTime? scheduledTime;
  final int priority;

  factory TokenModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TokenModel(
      tokenId: doc.id,
      clinicId: data['clinicId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      patientId: data['patientId'] as String?,
      tokenNumber: data['tokenNumber'] as int? ?? 0,
      status: data['status'] as String? ?? TokenStatus.waiting.firestoreValue,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      isAppointment: data['isAppointment'] as bool? ?? false,
      scheduledTime: (data['scheduledTime'] as Timestamp?)?.toDate(),
      priority: data['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId,
      'patientName': patientName,
      if (patientId != null) 'patientId': patientId,
      'tokenNumber': tokenNumber,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'isAppointment': isAppointment,
      if (scheduledTime != null) 'scheduledTime': Timestamp.fromDate(scheduledTime!),
      'priority': priority,
    };
  }

  TokenEntity toEntity() {
    return TokenEntity(
      tokenId: tokenId,
      clinicId: clinicId,
      patientName: patientName,
      patientId: patientId,
      tokenNumber: tokenNumber,
      status: TokenStatus.fromString(status),
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      isAppointment: isAppointment,
      scheduledTime: scheduledTime,
      priority: priority,
    );
  }
}
