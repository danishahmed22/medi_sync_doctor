import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/medical/data/models/prescription_model.dart';
import 'package:medisync_doctor/features/retention/domain/entities/prescription_template_entity.dart';

class PrescriptionTemplateModel {
  const PrescriptionTemplateModel({
    required this.templateId,
    required this.doctorId,
    required this.name,
    required this.medicines,
    required this.createdAt,
  });

  final String templateId;
  final String doctorId;
  final String name;
  final List<MedicineInfoModel> medicines;
  final DateTime createdAt;

  factory PrescriptionTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrescriptionTemplateModel(
      templateId: doc.id,
      doctorId: data['doctorId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      medicines: (data['medicines'] as List? ?? [])
          .map((m) => MedicineInfoModel.fromMap(m as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'name': name,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PrescriptionTemplateEntity toEntity() => PrescriptionTemplateEntity(
        templateId: templateId,
        doctorId: doctorId,
        name: name,
        medicines: medicines.map((m) => m.toEntity()).toList(),
        createdAt: createdAt,
      );

  factory PrescriptionTemplateModel.fromEntity(PrescriptionTemplateEntity entity) =>
      PrescriptionTemplateModel(
        templateId: entity.templateId,
        doctorId: entity.doctorId,
        name: entity.name,
        medicines: entity.medicines
            .map((m) => MedicineInfoModel.fromEntity(m))
            .toList(),
        createdAt: entity.createdAt,
      );
}
