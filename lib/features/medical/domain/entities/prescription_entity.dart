import 'package:equatable/equatable.dart';

class PrescriptionEntity extends Equatable {
  const PrescriptionEntity({
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
  final List<MedicineInfo> medicines;
  final DateTime createdAt;
  final String? pdfUrl;

  @override
  List<Object?> get props => [
        prescriptionId,
        patientId,
        visitId,
        clinicId,
        doctorId,
        medicines,
        createdAt,
        pdfUrl,
      ];
}

class MedicineInfo extends Equatable {
  const MedicineInfo({
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

  @override
  List<Object?> get props => [name, dosage, frequency, duration, instructions];

  MedicineInfo copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return MedicineInfo(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }
}
