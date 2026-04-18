/// MediSync — Application-wide constants, enums, and RBAC configuration.
library;

// ── Firestore collection paths ───────────────────────────────────────────────

class FirestoreCollections {
  FirestoreCollections._();

  static const String medicalStaff = 'medical_staff';
  static const String clinics = 'clinics';
  static const String invites = 'invites';
  static const String tokens = 'tokens';
  static const String clinicFlowStats = 'clinic_flow_stats';
  static const String appointments = 'appointments';
  static const String patients = 'patients';
  static const String visits = 'visits';
  static const String prescriptions = 'prescriptions';
  static const String prescriptionTemplates = 'prescription_templates';
  static const String consultationLogs = 'consultation_logs';
  static const String doctorDailyStats = 'doctor_daily_stats';
  static const String doctorPreferences = 'doctor_preferences';
  static const String ratings = 'ratings';
  static const String noShowStats = 'no_show_stats';
  
  // Operations module
  static const String vendors = 'vendors';
  static const String inventory = 'inventory';

  // Staff Management module
  static const String staffActivityLogs = 'staff_activity_logs';
  static const String permissionsConfig = 'permissions_config';

  // Analytics Module
  static const String analyticsEvents = 'analytics_events';
  static const String clinicDailyStats = 'clinic_daily_stats';
  static const String clinicWeeklyStats = 'clinic_weekly_stats';
  static const String clinicPeakStats = 'clinic_peak_stats';
  static const String doctorAnalytics = 'doctor_analytics';

  // Security & Compliance Module
  static const String securityAccessLogs = 'security_access_logs';
  static const String patientConsents = 'patient_consents';

  /// Internal counter collection used for uniqueId generation.
  static const String counters = '_counters';

  /// Counter document ID for medical_staff auto-incremented IDs.
  static const String staffCounterDoc = 'medical_staff';
}

// ── Role system ──────────────────────────────────────────────────────────────

enum UserRole {
  doctor,
  compounder,
  receptionist;

  String get displayName {
    switch (this) {
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.compounder:
        return 'Compounder';
      case UserRole.receptionist:
        return 'Receptionist';
    }
  }

  String get description {
    switch (this) {
      case UserRole.doctor:
        return 'Full clinic access, create & manage clinics';
      case UserRole.compounder:
        return 'Inventory management & view prescriptions';
      case UserRole.receptionist:
        return 'Appointment scheduling & token management';
    }
  }

  String get firestoreValue => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.receptionist,
    );
  }
}

// ── Invite status ────────────────────────────────────────────────────────────

enum InviteStatus {
  pending,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case InviteStatus.pending:
        return 'Pending';
      case InviteStatus.accepted:
        return 'Accepted';
      case InviteStatus.rejected:
        return 'Rejected';
    }
  }

  String get firestoreValue => name;

  static InviteStatus fromString(String value) {
    return InviteStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => InviteStatus.pending,
    );
  }
}

// ── Token status ─────────────────────────────────────────────────────────────

enum TokenStatus {
  waiting,
  inProgress,
  completed,
  skipped;

  String get firestoreValue => name;

  static TokenStatus fromString(String value) {
    return TokenStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => TokenStatus.waiting,
    );
  }
}

// ── Consultation Type ───────────────────────────────────────────────────────

enum ConsultationType {
  quick,
  normal,
  complex;

  double get weight {
    switch (this) {
      case ConsultationType.quick: return 0.7;
      case ConsultationType.normal: return 1.0;
      case ConsultationType.complex: return 1.5;
    }
  }

  String get firestoreValue => name;

  static ConsultationType fromString(String value) {
    return ConsultationType.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ConsultationType.normal,
    );
  }
}

// ── Appointment status ───────────────────────────────────────────────────────

enum AppointmentStatus {
  booked,
  completed,
  cancelled;

  String get firestoreValue => name;

  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => AppointmentStatus.booked,
    );
  }
}

// ── Document types ───────────────────────────────────────────────────────────

enum DocumentType {
  doctorLicense,
  clinicProof,
  idCard;

  String get displayName {
    switch (this) {
      case DocumentType.doctorLicense:
        return 'Doctor License';
      case DocumentType.clinicProof:
        return 'Clinic Registration Proof';
      case DocumentType.idCard:
        return 'Government ID Card';
    }
  }

  String get subtitle {
    switch (this) {
      case DocumentType.doctorLicense:
        return 'Upload your medical council registration certificate';
      case DocumentType.clinicProof:
        return 'Upload clinic registration or ownership document';
      case DocumentType.idCard:
        return 'Upload a valid government-issued photo ID';
    }
  }

  String get firestoreValue => name;

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
      (d) => d.name == value,
      orElse: () => DocumentType.idCard,
    );
  }
}

// ── RBAC Permission matrix ───────────────────────────────────────────────────

class RolePermissions {
  RolePermissions._();
  
  static bool canCreateClinic(UserRole role) => role == UserRole.doctor;
  static bool canInviteStaff(UserRole role) => role == UserRole.doctor;
  static bool canUploadDocuments(UserRole role) => role == UserRole.doctor;
  
  static bool canAccessMedicalData(UserRole role) => 
      role == UserRole.doctor || role == UserRole.compounder;
      
  static bool canModifyMedicalData(UserRole role) => 
      role == UserRole.doctor;

  static bool canManageTokens(UserRole role) => 
      role == UserRole.doctor || role == UserRole.receptionist;

  static bool canManageInventory(UserRole role) => 
      role == UserRole.doctor || role == UserRole.compounder;

  static bool canManageStaff(UserRole role) => 
      role == UserRole.doctor;
}

// ── Misc App Constants ───────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  static const String appName = 'MediSync';

  /// Maximum value for the 7-digit unique staff ID (0000001 – 9999999).
  static const int maxUniqueId = 9999999;

  /// Formats an integer as a zero-padded 7-digit unique staff ID string.
  static String formatUniqueId(int id) => id.toString().padLeft(7, '0');

  /// SharedPreferences keys.
  static const String prefCurrentClinicId = 'current_clinic_id';

  /// Firebase Storage base path for uploaded documents.
  static const String storageDocumentsPath = 'documents';

  /// Baseline average consultation time in minutes for manual paper-based workflow.
  /// Used to calculate "Time Saved".
  static const double manualAvgConsultationTime = 7.0;
}
