import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/invite_entity.dart';

/// Firestore DTO for [InviteEntity].
class InviteModel {
  const InviteModel({
    required this.inviteId,
    required this.clinicId,
    required this.clinicName,
    required this.role,
    required this.email,
    this.phone,
    required this.status,
    required this.createdAt,
  });

  final String inviteId;
  final String clinicId;
  final String clinicName;
  final String role;
  final String email;
  final String? phone;
  final String status;
  final DateTime createdAt;

  factory InviteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteModel(
      inviteId: doc.id,
      clinicId: data['clinicId'] as String? ?? '',
      clinicName: data['clinicName'] as String? ?? '',
      role: data['role'] as String? ?? UserRole.receptionist.firestoreValue,
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String?,
      status:
          data['status'] as String? ?? InviteStatus.pending.firestoreValue,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId,
      'clinicName': clinicName,
      'role': role,
      'email': email,
      if (phone != null) 'phone': phone,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  InviteEntity toEntity() {
    return InviteEntity(
      inviteId: inviteId,
      clinicId: clinicId,
      clinicName: clinicName,
      role: UserRole.fromString(role),
      email: email,
      phone: phone,
      status: InviteStatus.fromString(status),
      createdAt: createdAt,
    );
  }
}
