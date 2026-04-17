/// MediSync form validation utilities.
library;

class Validators {
  Validators._();

  // ── Email ────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final regex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-z]{2,}$', caseSensitive: false);
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // ── Password ─────────────────────────────────────────────────────────────

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final basic = password(value);
    if (basic != null) return basic;
    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // ── Name ─────────────────────────────────────────────────────────────────

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  // ── Phone ─────────────────────────────────────────────────────────────────

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-+()]'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number (10–15 digits).';
    }
    if (!RegExp(r'^\d+$').hasMatch(digits)) {
      return 'Phone number must contain only digits.';
    }
    return null;
  }

  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return phone(value);
  }

  // ── Required generic ─────────────────────────────────────────────────────

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  // ── Clinic name ───────────────────────────────────────────────────────────

  static String? clinicName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Clinic name is required.';
    }
    if (value.trim().length < 3) {
      return 'Clinic name must be at least 3 characters.';
    }
    return null;
  }

  // ── Address ───────────────────────────────────────────────────────────────

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required.';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address.';
    }
    return null;
  }

  // ── Latitude ──────────────────────────────────────────────────────────────

  static String? latitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude is required.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number (e.g. 28.7041).';
    if (parsed < -90 || parsed > 90) {
      return 'Latitude must be between -90 and 90.';
    }
    return null;
  }

  // ── Longitude ─────────────────────────────────────────────────────────────

  static String? longitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude is required.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number (e.g. 77.1025).';
    if (parsed < -180 || parsed > 180) {
      return 'Longitude must be between -180 and 180.';
    }
    return null;
  }

  // ── Specialist in ────────────────────────────────────────────────────────

  static String? specialistIn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Specialisation is required.';
    }
    return null;
  }
}
