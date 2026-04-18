import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  const PatientEntity({
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

  @override
  List<Object?> get props => [patientId, name, phone, age, gender, createdAt];

  PatientEntity copyWith({
    String? patientId,
    String? name,
    String? phone,
    int? age,
    String? gender,
    DateTime? createdAt,
  }) {
    return PatientEntity(
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
