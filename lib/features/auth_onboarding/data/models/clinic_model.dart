import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/clinic_entity.dart';

/// Firestore DTO for [ClinicEntity].
class ClinicModel {
  const ClinicModel({
    required this.clinicId,
    required this.clinicName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.doctorId,
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
  final List<String> staffIds;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final bool isSessionActive;
  final int totalTokensIssuedToday;
  final DateTime? serviceStartTime;

  // ── Factory: from Firestore document ──────────────────────────────────────

  factory ClinicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClinicModel(
      clinicId: doc.id,
      clinicName: data['clinicName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      doctorId: data['doctorId'] as String? ?? '',
      staffIds: List<String>.from(data['staffIds'] as List? ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSessionActive: data['isSessionActive'] as bool? ?? false,
      totalTokensIssuedToday: data['totalTokensIssuedToday'] as int? ?? 0,
      serviceStartTime: (data['serviceStartTime'] as Timestamp?)?.toDate(),
    );
  }

  // ── To Firestore map ──────────────────────────────────────────────────────

  Map<String, dynamic> toFirestore() {
    return {
      'clinicName': clinicName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'doctorId': doctorId,
      'staffIds': staffIds,
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'isSessionActive': isSessionActive,
      'totalTokensIssuedToday': totalTokensIssuedToday,
      if (serviceStartTime != null)
        'serviceStartTime': Timestamp.fromDate(serviceStartTime!),
    };
  }

  // ── Map to domain entity ──────────────────────────────────────────────────

  ClinicEntity toEntity() {
    return ClinicEntity(
      clinicId: clinicId,
      clinicName: clinicName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      doctorId: doctorId,
      staffIds: staffIds,
      rating: rating,
      ratingCount: ratingCount,
      createdAt: createdAt,
      isSessionActive: isSessionActive,
      totalTokensIssuedToday: totalTokensIssuedToday,
      serviceStartTime: serviceStartTime,
    );
  }

  factory ClinicModel.fromEntity(ClinicEntity entity) => ClinicModel(
        clinicId: entity.clinicId,
        clinicName: entity.clinicName,
        address: entity.address,
        latitude: entity.latitude,
        longitude: entity.longitude,
        doctorId: entity.doctorId,
        staffIds: entity.staffIds,
        rating: entity.rating,
        ratingCount: entity.ratingCount,
        createdAt: entity.createdAt,
        isSessionActive: entity.isSessionActive,
        totalTokensIssuedToday: entity.totalTokensIssuedToday,
        serviceStartTime: entity.serviceStartTime,
      );
}
