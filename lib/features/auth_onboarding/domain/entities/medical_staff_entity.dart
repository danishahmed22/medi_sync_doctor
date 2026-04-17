import 'package:equatable/equatable.dart';

/// MedicalStaff domain entity.
///
/// Plain Dart class — zero dependency on Firebase or any external package.
/// DTOs (data layer models) are mapped to this entity before use in the domain.
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
  });

  /// Firebase Auth UID — primary document key.
  final String userId;

  /// 7-digit zero-padded unique human-readable ID (e.g. "0042317").
  final String uniqueId;

  final String name;
  final String email;
  final String phone;
  final String role; // 'doctor' | 'compounder' | 'receptionist'
  final String specialistIn;

  /// List of clinic IDs this staff member belongs to.
  final List<String> clinicIds;

  /// Currently active clinic (stored locally via SharedPreferences).
  final String? currentClinicId;

  final bool isVerified;

  /// Average rating (0.0 – 5.0). Written only by the patient app.
  final double rating;

  /// Total number of ratings received.
  final int ratingCount;

  /// Uploaded verification documents.
  final List<DocumentInfo> documents;

  final DateTime createdAt;

  /// The active token number currently being served by this doctor.
  /// Used for the clinic flow counter system.
  final int currentToken;

  // ── Helpers ────────────────────────────────────────────────────────────────

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
      ];
}

/// Value object representing a single uploaded document.
class DocumentInfo extends Equatable {
  const DocumentInfo({
    required this.type,
    required this.url,
    required this.uploadedAt,
  });

  final String type;    // DocumentType.firestoreValue
  final String url;     // Firebase Storage download URL
  final DateTime uploadedAt;

  DocumentInfo copyWith({String? type, String? url, DateTime? uploadedAt}) {
    return DocumentInfo(
      type: type ?? this.type,
      url: url ?? this.url,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props => [type, url, uploadedAt];
}
