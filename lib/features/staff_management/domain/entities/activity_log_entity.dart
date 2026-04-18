import 'package:equatable/equatable.dart';

class ActivityLogEntity extends Equatable {
  const ActivityLogEntity({
    required this.logId,
    required this.clinicId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.actionType,
    required this.entityType,
    required this.entityId,
    required this.metadata,
    required this.createdAt,
  });

  final String logId;
  final String clinicId;
  final String userId;
  final String userName;
  final String userRole;
  final String actionType; // e.g., 'CREATE_TOKEN', 'START_CONSULTATION'
  final String entityType; // e.g., 'TOKEN', 'VISIT'
  final String entityId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  String get humanReadableMessage {
    switch (actionType) {
      case 'CREATE_TOKEN':
        return '$userName ($userRole) created token #${metadata['tokenNumber']}';
      case 'START_CONSULTATION':
        return '$userName ($userRole) started consultation for ${metadata['patientName']}';
      case 'COMPLETE_CONSULTATION':
        return '$userName ($userRole) completed consultation';
      case 'SKIP_TOKEN':
        return '$userName ($userRole) skipped token #${metadata['tokenNumber']}';
      case 'UPDATE_STOCK':
        return '$userName ($userRole) updated stock for ${metadata['itemName']}';
      default:
        return '$userName ($userRole) performed $actionType on $entityType';
    }
  }

  ActivityLogEntity copyWith({
    String? logId,
    String? clinicId,
    String? userId,
    String? userName,
    String? userRole,
    String? actionType,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ActivityLogEntity(
      logId: logId ?? this.logId,
      clinicId: clinicId ?? this.clinicId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      actionType: actionType ?? this.actionType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        logId,
        clinicId,
        userId,
        userName,
        userRole,
        actionType,
        entityType,
        entityId,
        metadata,
        createdAt,
      ];
}
