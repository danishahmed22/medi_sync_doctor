import 'package:equatable/equatable.dart';

class AccessLogEntity extends Equatable {
  const AccessLogEntity({
    required this.logId,
    required this.userId,
    required this.role,
    required this.action, // "READ" | "WRITE" | "DELETE"
    required this.entityType, // "PATIENT" | "PRESCRIPTION" | "HISTORY"
    required this.entityId,
    required this.clinicId,
    required this.createdAt,
  });

  final String logId;
  final String userId;
  final String role;
  final String action;
  final String entityType;
  final String entityId;
  final String clinicId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        logId,
        userId,
        role,
        action,
        entityType,
        entityId,
        clinicId,
        createdAt,
      ];
}
