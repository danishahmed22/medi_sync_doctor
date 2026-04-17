import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/datasources/firestore_datasource.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/models/invite_model.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/models/medical_staff_model.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/invite_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';

/// Concrete implementation of [InviteRepository].
///
/// Orchestrates Firestore operations and SharedPreferences for local state.
class InviteRepositoryImpl implements InviteRepository {
  const InviteRepositoryImpl(this._datasource, this._prefs);

  final FirestoreDatasource _datasource;
  final SharedPreferences _prefs;

  // ── Staff profile ─────────────────────────────────────────────────────────

  @override
  Future<MedicalStaffEntity> createStaffProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    required String specialistIn,
  }) async {
    // Generate unique 7-digit ID atomically.
    final uniqueId = await _datasource.generateUniqueId();

    final model = MedicalStaffModel(
      userId: userId,
      uniqueId: uniqueId,
      name: name,
      email: email,
      phone: phone,
      role: role.firestoreValue,
      specialistIn: specialistIn,
      clinicIds: const [],
      isVerified: false,
      rating: 0.0,
      ratingCount: 0,
      documents: const [],
      createdAt: DateTime.now(),
    );

    await _datasource.createStaffDoc(model);
    return model.toEntity();
  }

  @override
  Stream<MedicalStaffEntity?> watchStaffProfile(String userId) {
    return _datasource
        .watchStaff(userId)
        .map((model) => model?.toEntity());
  }

  @override
  Future<MedicalStaffEntity?> getStaffByEmail(String email) async {
    final model = await _datasource.getStaffByEmail(email);
    return model?.toEntity();
  }

  // ── Invites ───────────────────────────────────────────────────────────────

  @override
  Future<InviteEntity> sendInvite({
    required String clinicId,
    required String clinicName,
    required String email,
    String? phone,
    required UserRole role,
  }) async {
    final model = InviteModel(
      inviteId: '',
      clinicId: clinicId,
      clinicName: clinicName,
      role: role.firestoreValue,
      email: email,
      phone: phone,
      status: InviteStatus.pending.firestoreValue,
      createdAt: DateTime.now(),
    );
    final created = await _datasource.createInvite(model);
    return created.toEntity();
  }

  @override
  Stream<List<InviteEntity>> watchClinicInvites(String clinicId) {
    return _datasource
        .watchInvitesByClinic(clinicId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<InviteEntity>> watchIncomingInvites(String email) {
    return _datasource
        .watchInvitesByEmail(email)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> acceptInvite(String inviteId) async {
    final invite = await _datasource.getInviteById(inviteId);
    if (invite == null) return;

    // Look up the staff member by email to get their userId.
    final staff = await _datasource.getStaffByEmail(invite.email);
    if (staff == null) return;

    // All three writes should be batched for atomicity.
    await Future.wait([
      _datasource.updateInviteStatus(
          inviteId, InviteStatus.accepted.firestoreValue),
      _datasource.addClinicToStaff(staff.userId, invite.clinicId),
      _datasource.addStaffToClinic(invite.clinicId, staff.userId),
    ]);
  }

  @override
  Future<void> rejectInvite(String inviteId) =>
      _datasource.updateInviteStatus(
          inviteId, InviteStatus.rejected.firestoreValue);

  // ── Documents ─────────────────────────────────────────────────────────────

  @override
  Future<void> addDocument({
    required String userId,
    required DocumentInfo document,
  }) async {
    final docMap = {
      'type': document.type,
      'url': document.url,
      'uploadedAt': document.uploadedAt.toIso8601String(),
    };
    await _datasource.addDocumentToStaff(userId, docMap);
  }

  // ── CurrentClinic (SharedPreferences) ─────────────────────────────────────

  @override
  Future<void> setCurrentClinic(String clinicId) async {
    await _prefs.setString(AppConstants.prefCurrentClinicId, clinicId);
  }

  @override
  Future<String?> getCurrentClinic() async {
    return _prefs.getString(AppConstants.prefCurrentClinicId);
  }
}
