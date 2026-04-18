import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';

class PatientModel {
  const PatientModel({
    required this.patientId,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.createdAt,
  });

  final String patientId;
  final String name;
  final String phone;
  final int age;
  final String gender;
  final DateTime createdAt;

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      patientId: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      age: data['age'] as int? ?? 0,
      gender: data['gender'] as String? ?? 'Other',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PatientEntity toEntity() => PatientEntity(
        patientId: patientId,
        name: name,
        phone: phone,
        age: age,
        gender: gender,
        createdAt: createdAt,
      );

  factory PatientModel.fromEntity(PatientEntity entity) => PatientModel(
        patientId: entity.patientId,
        name: entity.name,
        phone: entity.phone,
        age: entity.age,
        gender: entity.gender,
        createdAt: entity.createdAt,
      );
}
