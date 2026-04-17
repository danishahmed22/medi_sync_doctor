import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/login_with_email.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/sign_in_with_google.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/usecases/sign_up_with_email.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';

/// Watches the current user's [MedicalStaffEntity] from Firestore in real time.
///
/// Returns null if:
///  - The user is not signed in.
///  - The Firestore document for this user doesn't exist yet (new user).
final currentStaffProvider =
    StreamProvider.autoDispose<MedicalStaffEntity?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref
          .watch(inviteRepositoryProvider)
          .watchStaffProfile(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Convenience provider — returns the current staff profile synchronously
/// (null if not yet loaded).
final currentStaffSyncProvider = Provider<MedicalStaffEntity?>((ref) {
  return ref.watch(currentStaffProvider).value;
});

/// Async notifier for profile creation + auth actions.
class AuthActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signInWithGoogleProvider).call(
            const SignInWithGoogleParams(),
          ),
    );
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(loginWithEmailProvider).call(
            LoginWithEmailParams(email: email, password: password),
          ),
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signUpWithEmailProvider).call(
            SignUpWithEmailParams(email: email, password: password),
          ),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(logoutProvider).call(),
    );
  }

  Future<void> createProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String role,
    required String specialistIn,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(inviteRepositoryProvider).createStaffProfile(
            userId: userId,
            name: name,
            email: email,
            phone: phone,
            role: UserRole.fromString(role),
            specialistIn: specialistIn,
          ),
    );
  }
}

final authActionsProvider =
    AsyncNotifierProvider<AuthActionsNotifier, void>(() {
  return AuthActionsNotifier();
});
