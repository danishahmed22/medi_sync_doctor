import 'package:equatable/equatable.dart';
import 'package:medisync_doctor/features/medical/domain/entities/prescription_entity.dart';

class PrescriptionTemplateEntity extends Equatable {
  const PrescriptionTemplateEntity({
    required this.templateId,
    required this.doctorId,
    required this.name,
    required this.medicines,
    required this.createdAt,
  });

  final String templateId;
  final String doctorId;
  final String name;
  final List<MedicineInfo> medicines;
  final DateTime createdAt;

  @override
  List<Object?> get props => [templateId, doctorId, name, medicines, createdAt];

  PrescriptionTemplateEntity copyWith({
    String? templateId,
    String? doctorId,
    String? name,
    List<MedicineInfo>? medicines,
    DateTime? createdAt,
  }) {
    return PrescriptionTemplateEntity(
      templateId: templateId ?? this.templateId,
      doctorId: doctorId ?? this.doctorId,
      name: name ?? this.name,
      medicines: medicines ?? this.medicines,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
