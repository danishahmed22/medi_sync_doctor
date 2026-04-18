import 'package:equatable/equatable.dart';

/// Clinic domain entity.
class ClinicEntity extends Equatable {
  const ClinicEntity({
    required this.clinicId,
    required this.clinicName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.doctorId,
    required this.doctorName, // NEW: Added for patient-app optimization
    required this.staffIds,
    required this.rating,
    required this.ratingCount,
    required this.createdAt,
    this.isSessionActive = false,
    this.totalTokensIssuedToday = 0,
    this.serviceStartTime,
  });

  final String clinicId;
  final String clinicName;
  final String address;
  final double latitude;
  final double longitude;
  final String doctorId;
  final String doctorName; // NEW: The primary doctor's name
  final List<String> staffIds;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;

  final bool isSessionActive;
  final int totalTokensIssuedToday;
  final DateTime? serviceStartTime;

  ClinicEntity copyWith({
    String? clinicId,
    String? clinicName,
    String? address,
    double? latitude,
    double? longitude,
    String? doctorId,
    String? doctorName,
    List<String>? staffIds,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
    bool? isSessionActive,
    int? totalTokensIssuedToday,
    DateTime? serviceStartTime,
  }) {
    return ClinicEntity(
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      staffIds: staffIds ?? this.staffIds,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      totalTokensIssuedToday:
          totalTokensIssuedToday ?? this.totalTokensIssuedToday,
      serviceStartTime: serviceStartTime ?? this.serviceStartTime,
    );
  }

  @override
  List<Object?> get props => [
        clinicId,
        clinicName,
        address,
        latitude,
        longitude,
        doctorId,
        doctorName,
        staffIds,
        rating,
        ratingCount,
        createdAt,
        isSessionActive,
        totalTokensIssuedToday,
        serviceStartTime,
      ];
}
