import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/clinic_flow/data/repositories_impl/clinic_flow_repository_impl.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/appointment_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/clinic_stats_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/repositories/clinic_flow_repository.dart';

// ── Infrastructure ───────────────────────────────────────────────────────────

final clinicFlowRepositoryProvider = Provider<ClinicFlowRepository>((ref) {
  return ClinicFlowRepositoryImpl(FirebaseFirestore.instance);
});

// ── Streams ──────────────────────────────────────────────────────────────────

final queueStreamProvider = StreamProvider.autoDispose<List<TokenEntity>>((ref) {
  final clinic = ref.watch(currentClinicProvider).value;
  if (clinic == null) return Stream.value([]);
  return ref.read(clinicFlowRepositoryProvider).watchQueue(clinic.clinicId);
});

final clinicStatsStreamProvider = StreamProvider.autoDispose<ClinicStatsEntity?>((ref) {
  final clinic = ref.watch(currentClinicProvider).value;
  if (clinic == null) return Stream.value(null);
  return ref.read(clinicFlowRepositoryProvider).watchClinicStats(clinic.clinicId);
});

final appointmentStreamProvider = StreamProvider.autoDispose<List<AppointmentEntity>>((ref) {
  final clinic = ref.watch(currentClinicProvider).value;
  if (clinic == null) return Stream.value([]);
  return ref.read(clinicFlowRepositoryProvider).watchAppointments(clinic.clinicId);
});

// ── Derived State ────────────────────────────────────────────────────────────

final currentPatientProvider = Provider.autoDispose<TokenEntity?>((ref) {
  final queue = ref.watch(queueStreamProvider).value ?? [];
  return queue.where((t) => t.isInProgress).firstOrNull;
});

final waitingQueueProvider = Provider.autoDispose<List<TokenEntity>>((ref) {
  final queue = ref.watch(queueStreamProvider).value ?? [];
  return queue.where((t) => t.isWaiting).toList();
});

// ── Action Notifier ──────────────────────────────────────────────────────────

class QueueActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> generateWalkInToken(String name) async {
    final clinic = ref.read(currentClinicProvider).value;
    if (clinic == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clinicFlowRepositoryProvider).generateToken(
            clinicId: clinic.clinicId,
            patientName: name,
          ),
    );
  }

  Future<void> startConsultation(String tokenId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clinicFlowRepositoryProvider).startConsultation(tokenId),
    );
  }

  Future<void> completeConsultation(String tokenId) async {
    // FIXED: Correctly accessing stream value
    final clinicState = ref.read(currentClinicProvider);
    final clinic = clinicState.value;
    if (clinic == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clinicFlowRepositoryProvider).completeConsultation(
            tokenId,
            clinic.clinicId,
          ),
    );
  }

  Future<void> skipToken(String tokenId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clinicFlowRepositoryProvider).skipToken(tokenId),
    );
  }

  Future<void> prioritizeToken(String tokenId, int priority) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clinicFlowRepositoryProvider).prioritizeToken(tokenId, priority),
    );
  }

  Future<void> createAppointment(String name, DateTime time) async {
    final clinic = ref.read(currentClinicProvider).value;
    if (clinic == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clinicFlowRepositoryProvider).createAppointment(
            clinicId: clinic.clinicId,
            patientName: name,
            scheduledTime: time,
          ),
    );
  }

  Future<void> convertAppointment(AppointmentEntity appointment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clinicFlowRepositoryProvider).convertAppointmentToToken(appointment),
    );
  }
}

final queueActionsProvider = AsyncNotifierProvider<QueueActionsNotifier, void>(() {
  return QueueActionsNotifier();
});
