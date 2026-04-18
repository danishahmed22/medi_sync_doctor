import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/medical/domain/entities/visit_entity.dart';

class VisitModel {
  const VisitModel({
    required this.visitId,
    required this.patientId,
    required this.clinicId,
    required this.doctorId,
    this.tokenId,
    required this.symptoms,
    required this.diagnosis,
    required this.notes,
    required this.createdAt,
  });

  final String visitId;
  final String patientId;
  final String clinicId;
  final String doctorId;
  final String? tokenId;
  final String symptoms;
  final String diagnosis;
  final String notes;
  final DateTime createdAt;

  factory VisitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitModel(
      visitId: doc.id,
      patientId: data['patientId'] as String? ?? '',
      clinicId: data['clinicId'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      tokenId: data['tokenId'] as String?,
      symptoms: data['symptoms'] as String? ?? '',
      diagnosis: data['diagnosis'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'clinicId': clinicId,
      'doctorId': doctorId,
      if (tokenId != null) 'tokenId': tokenId,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  VisitEntity toEntity() => VisitEntity(
        visitId: visitId,
        patientId: patientId,
        clinicId: clinicId,
        doctorId: doctorId,
        tokenId: tokenId,
        symptoms: symptoms,
        diagnosis: diagnosis,
        notes: notes,
        createdAt: createdAt,
      );

  factory VisitModel.fromEntity(VisitEntity entity) => VisitModel(
        visitId: entity.visitId,
        patientId: entity.patientId,
        clinicId: entity.clinicId,
        doctorId: entity.doctorId,
        tokenId: entity.tokenId,
        symptoms: entity.symptoms,
        diagnosis: entity.diagnosis,
        notes: entity.notes,
        createdAt: entity.createdAt,
      );
}
