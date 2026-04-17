import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';

/// Abstract contract for all authentication operations.
/// Implemented in the data layer — never imported by the UI directly.
abstract interface class AuthRepository {
  /// Stream that emits the current Firebase [User] on auth state changes.
  Stream<User?> get authStateChanges;

  /// Signs in with Google OAuth.
  /// Returns the [MedicalStaffEntity] if the user already exists, otherwise
  /// null (new user still needs role selection + profile creation).
  Future<({User firebaseUser, bool isNewUser})> signInWithGoogle();

  /// Creates a new Firebase Auth account with email + password.
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Signs in an existing account with email + password.
  Future<User> loginWithEmail({
    required String email,
    required String password,
  });

  /// Signs out the current user from Firebase Auth.
  Future<void> logout();

  /// Returns the currently signed-in Firebase [User], or null.
  User? get currentUser;
}
