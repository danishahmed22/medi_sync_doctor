import 'package:equatable/equatable.dart';

class VisitEntity extends Equatable {
  const VisitEntity({
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

  @override
  List<Object?> get props => [
        visitId,
        patientId,
        clinicId,
        doctorId,
        tokenId,
        symptoms,
        diagnosis,
        notes,
        createdAt,
      ];

  VisitEntity copyWith({
    String? visitId,
    String? patientId,
    String? clinicId,
    String? doctorId,
    String? tokenId,
    String? symptoms,
    String? diagnosis,
    String? notes,
    DateTime? createdAt,
  }) {
    return VisitEntity(
      visitId: visitId ?? this.visitId,
      patientId: patientId ?? this.patientId,
      clinicId: clinicId ?? this.clinicId,
      doctorId: doctorId ?? this.doctorId,
      tokenId: tokenId ?? this.tokenId,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
