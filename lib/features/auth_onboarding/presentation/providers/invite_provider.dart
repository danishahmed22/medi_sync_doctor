import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/invite_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/add_staff.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';

/// Watches all invites for the currently active clinic (doctor view).
final clinicInvitesProvider = StreamProvider.autoDispose
    .family<List<InviteEntity>, String>((ref, clinicId) {
  return ref
      .watch(inviteRepositoryProvider)
      .watchClinicInvites(clinicId);
});

/// Watches pending invites addressed to the current user's email (staff view).
final incomingInvitesProvider =
    StreamProvider.autoDispose<List<InviteEntity>>((ref) {
  final staff = ref.watch(currentStaffSyncProvider);
  if (staff == null) return Stream.value([]);
  return ref
      .watch(inviteRepositoryProvider)
      .watchIncomingInvites(staff.email);
});

// ── Invite action notifier ────────────────────────────────────────────────────

class InviteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendInvite({
    required String clinicId,
    required String clinicName,
    required String email,
    String? phone,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(addStaffProvider).call(
            AddStaffParams(
              clinicId: clinicId,
              clinicName: clinicName,
              email: email,
              phone: phone,
              role: role,
              requestingDoctorId:
                  ref.read(authStateProvider).value?.uid ?? '',
            ),
          ),
    );
  }

  Future<void> acceptInvite(String inviteId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(acceptInviteProvider).call(inviteId),
    );
  }

  Future<void> rejectInvite(String inviteId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(rejectInviteProvider).call(inviteId),
    );
  }
}

final inviteNotifierProvider =
    AsyncNotifierProvider<InviteNotifier, void>(() => InviteNotifier());

// ── Document upload notifier ──────────────────────────────────────────────────

class DocumentUploadState {
  const DocumentUploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.error,
  });

  final bool isUploading;
  final double progress;
  final String? error;

  DocumentUploadState copyWith({
    bool? isUploading,
    double? progress,
    String? error,
  }) {
    return DocumentUploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

class DocumentUploadNotifier extends StateNotifier<DocumentUploadState> {
  DocumentUploadNotifier(this._ref) : super(const DocumentUploadState());

  final Ref _ref;

  Future<void> uploadDocument({
    required String userId,
    required DocumentType documentType,
    required File file,
  }) async {
    state = state.copyWith(isUploading: true, progress: 0.0);
    try {
      final url =
          await _ref.read(storageDatasourceProvider).uploadDocument(
                userId: userId,
                documentType: documentType.firestoreValue,
                file: file,
                onProgress: (p) {
                  state = state.copyWith(progress: p);
                },
              );

      await _ref.read(uploadDocumentsProvider).saveDocumentUrl(
            userId: userId,
            documentType: documentType,
            downloadUrl: url,
          );
      state = const DocumentUploadState();
    } catch (e) {
      state = DocumentUploadState(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final documentUploadProvider =
    StateNotifierProvider<DocumentUploadNotifier, DocumentUploadState>((ref) {
  return DocumentUploadNotifier(ref);
});
