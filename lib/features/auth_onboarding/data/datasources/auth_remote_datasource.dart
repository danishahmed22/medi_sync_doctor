import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medisync_doctor/core/errors/app_exceptions.dart';

/// Wraps Firebase Auth and Google Sign-In SDK calls.
///
/// All exceptions are caught here and rethrown as typed [AuthException]s
/// so the repository layer never leaks SDK-specific errors.
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(scopes: ['email', 'profile']);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ── Auth state ────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<({User firebaseUser, bool isNewUser})> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google Sign-In was cancelled by the user.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      return (
        firebaseUser: userCredential.user!,
        isNewUser: isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e.code, e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e.code, e.message);
    }
  }

  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e.code, e.message);
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
