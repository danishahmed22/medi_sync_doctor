import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/datasources/auth_remote_datasource.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/datasources/firestore_datasource.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/datasources/storage_datasource.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/repositories_impl/auth_repository_impl.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/repositories_impl/clinic_repository_impl.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/repositories_impl/invite_repository_impl.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/auth_repository.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/clinic_repository.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/accept_invite.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/login_with_email.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/logout.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/sign_in_with_google.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/sign_up_with_email.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/switch_clinic.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/upload_documents.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/add_staff.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/create_clinic.dart';

// ── Infrastructure ───────────────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  );
});

// ── Datasources ───────────────────────────────────────────────────────────────

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource();
});

final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  return FirestoreDatasource();
});

final storageDatasourceProvider = Provider<StorageRemoteDatasource>((ref) {
  return StorageRemoteDatasource();
});

// ── Repositories ──────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});

final clinicRepositoryProvider = Provider<ClinicRepository>((ref) {
  return ClinicRepositoryImpl(ref.watch(firestoreDatasourceProvider));
});

final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  return InviteRepositoryImpl(
    ref.watch(firestoreDatasourceProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(
    ref.watch(authRepositoryProvider),
    ref.watch(inviteRepositoryProvider),
  );
});

final signUpWithEmailProvider = Provider<SignUpWithEmail>((ref) {
  return SignUpWithEmail(ref.watch(authRepositoryProvider));
});

final loginWithEmailProvider = Provider<LoginWithEmail>((ref) {
  return LoginWithEmail(ref.watch(authRepositoryProvider));
});

final logoutProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final createClinicProvider = Provider<CreateClinic>((ref) {
  return CreateClinic(
    ref.watch(clinicRepositoryProvider),
    ref.watch(inviteRepositoryProvider),
  );
});

final addStaffProvider = Provider<AddStaff>((ref) {
  return AddStaff(ref.watch(inviteRepositoryProvider));
});

final acceptInviteProvider = Provider<AcceptInvite>((ref) {
  return AcceptInvite(ref.watch(inviteRepositoryProvider));
});

final rejectInviteProvider = Provider<RejectInvite>((ref) {
  return RejectInvite(ref.watch(inviteRepositoryProvider));
});

final uploadDocumentsProvider = Provider<UploadDocuments>((ref) {
  return UploadDocuments(ref.watch(inviteRepositoryProvider));
});

final switchClinicProvider = Provider<SwitchClinic>((ref) {
  return SwitchClinic(ref.watch(inviteRepositoryProvider));
});

// ── Auth State Stream ──────────────────────────────────────────────────────────

/// Emits [User?] on every Firebase Auth state change.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
