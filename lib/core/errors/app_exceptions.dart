/// MediSync typed exception hierarchy.
///
/// All exceptions thrown from datasources/repositories are typed here so
/// that the domain and presentation layers can handle them specifically.
library;

sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

// ── Auth exceptions ──────────────────────────────────────────────────────────

final class AuthException extends AppException {
  const AuthException(super.message, {this.code});
  final String? code;

  /// Maps Firebase Auth error codes to user-friendly messages.
  factory AuthException.fromFirebase(String code, [String? message]) {
    final msg = switch (code) {
      'user-not-found' => 'No account found with this email address.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' => 'Invalid credentials. Please try again.',
      'email-already-in-use' =>
        'An account already exists with this email.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait before trying again.',
      'network-request-failed' =>
        'Network error. Please check your connection.',
      'account-exists-with-different-credential' =>
        'An account already exists with a different sign-in method.',
      _ => message ?? 'Authentication failed. Please try again.',
    };
    return AuthException(msg, code: code);
  }
}

// ── Firestore exceptions ─────────────────────────────────────────────────────

final class FirestoreException extends AppException {
  const FirestoreException(super.message, {this.code});
  final String? code;

  factory FirestoreException.fromFirebase(String code, [String? message]) {
    final msg = switch (code) {
      'permission-denied' => 'Access denied. Please check your permissions.',
      'not-found' => 'The requested document was not found.',
      'already-exists' => 'This record already exists.',
      'resource-exhausted' => 'Quota exceeded. Please try again later.',
      'unavailable' =>
        'Service temporarily unavailable. Please try again.',
      'deadline-exceeded' => 'Request timed out. Please try again.',
      _ => message ?? 'Database operation failed.',
    };
    return FirestoreException(msg, code: code);
  }
}

// ── Storage exceptions ───────────────────────────────────────────────────────

final class StorageException extends AppException {
  const StorageException(super.message, {this.code});
  final String? code;

  factory StorageException.fromFirebase(String code, [String? message]) {
    final msg = switch (code) {
      'object-not-found' => 'File not found in storage.',
      'unauthorized' => 'Not authorized to access this file.',
      'canceled' => 'Upload was cancelled.',
      'invalid-url' => 'Invalid file URL.',
      _ => message ?? 'File operation failed.',
    };
    return StorageException(msg, code: code);
  }
}

// ── Validation / general exceptions ─────────────────────────────────────────

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class UniqueIdException extends AppException {
  const UniqueIdException(super.message);
}

final class GeneralException extends AppException {
  const GeneralException(super.message);
}
