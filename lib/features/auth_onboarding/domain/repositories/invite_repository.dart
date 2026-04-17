import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/invite_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';

/// Abstract contract for staff invite and medical_staff profile operations.
abstract interface class InviteRepository {
  // ── Staff-profile CRUD ───────────────────────────────────────────────────

  /// Creates a new [MedicalStaffEntity] document in Firestore.
  /// Atomically generates and assigns a uniqueId.
  Future<MedicalStaffEntity> createStaffProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    required String specialistIn,
  });

  /// Watches the current user's[MedicalStaffEntity] in real time.
  Stream<MedicalStaffEntity?> watchStaffProfile(String userId);

  /// Fetches a [MedicalStaffEntity] by email (used for invite lookup).
  Future<MedicalStaffEntity?> getStaffByEmail(String email);

  // ── Invites ──────────────────────────────────────────────────────────────

  /// Sends an invite to [email] for the given [clinicId] and [role].
  Future<InviteEntity> sendInvite({
    required String clinicId,
    required String clinicName,
    required String email,
    String? phone,
    required UserRole role,
  });

  /// Watches all invites for a given clinic (for the doctor's Staff Invite screen).
  Stream<List<InviteEntity>> watchClinicInvites(String clinicId);

  /// Watches all pending invites addressed to [email] (for incoming staff).
  Stream<List<InviteEntity>> watchIncomingInvites(String email);

  /// Accepts an invite: updates invite status, adds clinicId to staff, adds
  /// staffId to clinic.
  Future<void> acceptInvite(String inviteId);

  /// Rejects an invite (sets status to rejected).
  Future<void> rejectInvite(String inviteId);

  // ── Documents ────────────────────────────────────────────────────────────

  /// Saves a document URL to the staff member's documents array in Firestore.
  Future<void> addDocument({
    required String userId,
    required DocumentInfo document,
  });

  // ── uniqueId ─────────────────────────────────────────────────────────────

  /// Stores [currentClinicId] in SharedPreferences for the current session.
  Future<void> setCurrentClinic(String clinicId);

  /// Retrieves the locally stored current clinic ID.
  Future<String?> getCurrentClinic();
}
