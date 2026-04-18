import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/clinic_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/create_clinic.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';

/// Watches all clinics belonging to the current doctor.
final doctorClinicsProvider =
    StreamProvider.autoDispose<List<ClinicEntity>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(clinicRepositoryProvider)
      .watchDoctorClinics(user.uid);
});

/// Watches all clinics the current staff member belongs to (for non-doctors).
final staffClinicsProvider =
    StreamProvider.autoDispose<List<ClinicEntity>>((ref) {
  final staff = ref.watch(currentStaffSyncProvider);
  if (staff == null) return Stream.value([]);
  return ref
      .watch(clinicRepositoryProvider)
      .watchStaffClinics(staff.clinicIds);
});

/// Resolves the correct clinic list provider based on the user's role.
final myClinicsProvider =
    StreamProvider.autoDispose<List<ClinicEntity>>((ref) {
  final staff = ref.watch(currentStaffSyncProvider);
  if (staff == null) return Stream.value([]);
  if (staff.isDoctor) {
    return ref
        .watch(clinicRepositoryProvider)
        .watchDoctorClinics(staff.userId);
  }
  return ref
      .watch(clinicRepositoryProvider)
      .watchStaffClinics(staff.clinicIds);
});

/// Currently selected clinic entity — FIXED to be a real-time Stream.
final currentClinicProvider =
    StreamProvider.autoDispose<ClinicEntity?>((ref) {
  final staff = ref.watch(currentStaffSyncProvider);
  if (staff == null) return Stream.value(null);

  final controller = StreamController<ClinicEntity?>();

  // 1. Get the local clinic ID
  ref.read(inviteRepositoryProvider).getCurrentClinic().then((localId) {
    final finalId = staff.currentClinicId ?? localId;
    if (finalId == null) {
      controller.add(null);
      return;
    }

    // 2. Listen to real-time changes of that specific clinic
    final sub = ref.read(clinicRepositoryProvider).watchClinicById(finalId).listen(
      (clinic) => controller.add(clinic),
      onError: (e) => controller.addError(e),
    );

    ref.onDispose(() => sub.cancel());
  });

  return controller.stream;
});

// ── Clinic creation notifier ──────────────────────────────────────────────────

class ClinicNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createClinic({
    required String doctorId,
    required String clinicName,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(createClinicProvider).call(
            CreateClinicParams(
              doctorId: doctorId,
              clinicName: clinicName,
              address: address,
              latitude: latitude,
              longitude: longitude,
            ),
          ),
    );
  }

  Future<void> switchClinic(String clinicId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(switchClinicProvider).call(clinicId),
    );
  }

  /// Starts the clinic session, allowing patients to join the queue.
  Future<void> startSession(String clinicId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.clinics)
          .doc(clinicId)
          .update({
        'isSessionActive': true,
        'totalTokensIssuedToday': 0,
        'serviceStartTime': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Ends the clinic session.
  Future<void> endSession(String clinicId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.clinics)
          .doc(clinicId)
          .update({
        'isSessionActive': false,
      });
    });
  }
}

final clinicNotifierProvider =
    AsyncNotifierProvider<ClinicNotifier, void>(() => ClinicNotifier());
