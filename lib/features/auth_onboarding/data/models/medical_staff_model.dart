import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';

/// Firestore DTO for [MedicalStaffEntity].
///
/// Handles serialisation / deserialisation from the `medical_staff` collection.
class MedicalStaffModel {
  const MedicalStaffModel({
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
  final List<DocumentInfoModel> documents;
  final DateTime createdAt;
  final int currentToken;

  // ── Factory: from Firestore document ──────────────────────────────────────

  factory MedicalStaffModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalStaffModel(
      userId: doc.id,
      uniqueId: data['uniqueId'] as String? ?? '0000000',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? UserRole.receptionist.firestoreValue,
      specialistIn: data['specialistIn'] as String? ?? '',
      clinicIds: List<String>.from(data['clinicIds'] as List? ?? []),
      currentClinicId: data['currentClinicId'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] as int? ?? 0,
      documents: _parseDocuments(data['documents']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentToken: data['currentToken'] as int? ?? 0,
    );
  }

  static List<DocumentInfoModel> _parseDocuments(dynamic raw) {
    if (raw == null) return [];
    final list = raw as List;
    return list
        .map((e) => DocumentInfoModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── To Firestore map ──────────────────────────────────────────────────────

  Map<String, dynamic> toFirestore() {
    return {
      'uniqueId': uniqueId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'specialistIn': specialistIn,
      'clinicIds': clinicIds,
      if (currentClinicId != null) 'currentClinicId': currentClinicId,
      'isVerified': isVerified,
      'rating': rating,
      'ratingCount': ratingCount,
      'documents': documents.map((d) => d.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'currentToken': currentToken,
    };
  }

  // ── Map to domain entity ──────────────────────────────────────────────────

  MedicalStaffEntity toEntity() {
    return MedicalStaffEntity(
      userId: userId,
      uniqueId: uniqueId,
      name: name,
      email: email,
      phone: phone,
      role: role,
      specialistIn: specialistIn,
      clinicIds: clinicIds,
      currentClinicId: currentClinicId,
      isVerified: isVerified,
      rating: rating,
      ratingCount: ratingCount,
      documents: documents.map((d) => d.toEntity()).toList(),
      createdAt: createdAt,
      currentToken: currentToken,
    );
  }
}

// ── DocumentInfo DTO ─────────────────────────────────────────────────────────

class DocumentInfoModel {
  const DocumentInfoModel({
    required this.type,
    required this.url,
    required this.uploadedAt,
  });

  final String type;
  final String url;
  final DateTime uploadedAt;

  factory DocumentInfoModel.fromMap(Map<String, dynamic> map) {
    return DocumentInfoModel(
      type: map['type'] as String? ?? '',
      url: map['url'] as String? ?? '',
      uploadedAt:
          (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'url': url,
        'uploadedAt': Timestamp.fromDate(uploadedAt),
      };

  DocumentInfo toEntity() => DocumentInfo(
        type: type,
        url: url,
        uploadedAt: uploadedAt,
      );

  factory DocumentInfoModel.fromEntity(DocumentInfo entity) =>
      DocumentInfoModel(
        type: entity.type,
        url: entity.url,
        uploadedAt: entity.uploadedAt,
      );
}
