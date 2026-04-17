import 'package:equatable/equatable.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';

/// Staff invite domain entity.
class InviteEntity extends Equatable {
  const InviteEntity({
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

  /// Target role for the invited staff member.
  final UserRole role;

  final String email;
  final String? phone;
  final InviteStatus status;
  final DateTime createdAt;

  bool get isPending => status == InviteStatus.pending;
  bool get isAccepted => status == InviteStatus.accepted;
  bool get isRejected => status == InviteStatus.rejected;

  InviteEntity copyWith({
    String? inviteId,
    String? clinicId,
    String? clinicName,
    UserRole? role,
    String? email,
    String? phone,
    InviteStatus? status,
    DateTime? createdAt,
  }) {
    return InviteEntity(
      inviteId: inviteId ?? this.inviteId,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        inviteId,
        clinicId,
        clinicName,
        role,
        email,
        phone,
        status,
        createdAt,
      ];
}
