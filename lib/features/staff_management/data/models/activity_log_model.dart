import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/staff_management/domain/entities/activity_log_entity.dart';

class ActivityLogModel {
  const ActivityLogModel({
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
  final String actionType;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  factory ActivityLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLogModel(
      logId: doc.id,
      clinicId: data['clinicId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userRole: data['userRole'] as String? ?? '',
      actionType: data['actionType'] as String? ?? '',
      entityType: data['entityType'] as String? ?? '',
      entityId: data['entityId'] as String? ?? '',
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'actionType': actionType,
      'entityType': entityType,
      'entityId': entityId,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ActivityLogEntity toEntity() => ActivityLogEntity(
        logId: logId,
        clinicId: clinicId,
        userId: userId,
        userName: userName,
        userRole: userRole,
        actionType: actionType,
        entityType: entityType,
        entityId: entityId,
        metadata: metadata,
        createdAt: createdAt,
      );

  factory ActivityLogModel.fromEntity(ActivityLogEntity entity) => ActivityLogModel(
        logId: entity.logId,
        clinicId: entity.clinicId,
        userId: entity.userId,
        userName: entity.userName,
        userRole: entity.userRole,
        actionType: entity.actionType,
        entityType: entity.entityType,
        entityId: entity.entityId,
        metadata: entity.metadata,
        createdAt: entity.createdAt,
      );
}
