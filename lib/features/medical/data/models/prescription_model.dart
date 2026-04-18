import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/medical/domain/entities/prescription_entity.dart';

class PrescriptionModel {
  const PrescriptionModel({
    required this.prescriptionId,
    required this.patientId,
    required this.visitId,
    required this.clinicId,
    required this.doctorId,
    required this.medicines,
    required this.createdAt,
    this.pdfUrl,
  });

  final String prescriptionId;
  final String patientId;
  final String visitId;
  final String clinicId;
  final String doctorId;
  final List<MedicineInfoModel> medicines;
  final DateTime createdAt;
  final String? pdfUrl;

  factory PrescriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrescriptionModel(
      prescriptionId: doc.id,
      patientId: data['patientId'] as String? ?? '',
      visitId: data['visitId'] as String? ?? '',
      clinicId: data['clinicId'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      medicines: (data['medicines'] as List? ?? [])
          .map((m) => MedicineInfoModel.fromMap(m as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pdfUrl: data['pdfUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'visitId': visitId,
      'clinicId': clinicId,
      'doctorId': doctorId,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
    };
  }

  PrescriptionEntity toEntity() => PrescriptionEntity(
        prescriptionId: prescriptionId,
        patientId: patientId,
        visitId: visitId,
        clinicId: clinicId,
        doctorId: doctorId,
        medicines: medicines.map((m) => m.toEntity()).toList(),
        createdAt: createdAt,
        pdfUrl: pdfUrl,
      );
}

class MedicineInfoModel {
  const MedicineInfoModel({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
  });

  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  factory MedicineInfoModel.fromMap(Map<String, dynamic> map) {
    return MedicineInfoModel(
      name: map['name'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      instructions: map['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'instructions': instructions,
      };

  MedicineInfo toEntity() => MedicineInfo(
        name: name,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        instructions: instructions,
      );

  factory MedicineInfoModel.fromEntity(MedicineInfo entity) => MedicineInfoModel(
        name: entity.name,
        dosage: entity.dosage,
        frequency: entity.frequency,
        duration: entity.duration,
        instructions: entity.instructions,
      );
}
