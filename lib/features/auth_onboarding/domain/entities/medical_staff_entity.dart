import 'package:equatable/equatable.dart';

/// MedicalStaff domain entity.
class MedicalStaffEntity extends Equatable {
  const MedicalStaffEntity({
    required this.userId,
    required this.uniqueId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.specialistIn,
    required this.clinicIds,
    this.currentClinicId,
    required this.isVerified,
    required this.rating,
    required this.ratingCount,
    required this.documents,
    required this.createdAt,
    this.currentToken = 0,
    this.totalToken = 0, // NEW: Tracks cumulative patients handled
  });

  final String userId;
  final String uniqueId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String specialistIn;
  final List<String> clinicIds;
  final String? currentClinicId;
  final bool isVerified;
  final double rating;
  final int ratingCount;
  final List<DocumentInfo> documents;
  final DateTime createdAt;
  final int currentToken;
  final int totalToken; // NEW

  bool get isDoctor => role == 'doctor';
  bool get isCompounder => role == 'compounder';
  bool get isReceptionist => role == 'receptionist';
  bool get hasClinic => clinicIds.isNotEmpty;

  MedicalStaffEntity copyWith({
    String? userId,
    String? uniqueId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? specialistIn,
    List<String>? clinicIds,
    String? currentClinicId,
    bool? isVerified,
    double? rating,
    int? ratingCount,
    List<DocumentInfo>? documents,
    DateTime? createdAt,
    int? currentToken,
    int? totalToken,
  }) {
    return MedicalStaffEntity(
      userId: userId ?? this.userId,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      specialistIn: specialistIn ?? this.specialistIn,
      clinicIds: clinicIds ?? this.clinicIds,
      currentClinicId: currentClinicId ?? this.currentClinicId,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      currentToken: currentToken ?? this.currentToken,
      totalToken: totalToken ?? this.totalToken,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        uniqueId,
        name,
        email,
        phone,
        role,
        specialistIn,
        clinicIds,
        currentClinicId,
        isVerified,
        rating,
        ratingCount,
        documents,
        createdAt,
        currentToken,
        totalToken,
      ];
}

class DocumentInfo extends Equatable {
  const DocumentInfo({
    required this.type,
    required this.url,
    required this.uploadedAt,
  });
  final String type;
  final String url;
  final DateTime uploadedAt;
  @override
  List<Object?> get props => [type, url, uploadedAt];
}
