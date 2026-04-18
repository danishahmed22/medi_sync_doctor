import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/core/errors/app_exceptions.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/models/clinic_model.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/models/invite_model.dart';
import 'package:medisync_doctor/features/auth_onboarding/data/models/medical_staff_model.dart';

/// Low-level Firestore CRUD operations for all collections.
class FirestoreDatasource {
  FirestoreDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── Convenience references ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _staffCol =>
      _db.collection(FirestoreCollections.medicalStaff);

  CollectionReference<Map<String, dynamic>> get _clinicsCol =>
      _db.collection(FirestoreCollections.clinics);

  CollectionReference<Map<String, dynamic>> get _invitesCol =>
      _db.collection(FirestoreCollections.invites);

  DocumentReference<Map<String, dynamic>> get _counterDoc => _db
      .collection(FirestoreCollections.counters)
      .doc(FirestoreCollections.staffCounterDoc);

  // ── uniqueId generation ───────────────────────────────────────────────────

  Future<String> generateUniqueId() async {
    try {
      return await _db.runTransaction<String>((txn) async {
        final snap = await txn.get(_counterDoc);
        final current =
            snap.exists ? (snap.data()?['lastId'] as int? ?? 0) : 0;
        final next = current + 1;

        if (next > AppConstants.maxUniqueId) {
          throw const UniqueIdException(
            'Staff unique ID capacity exceeded. Contact support.',
          );
        }

        txn.set(_counterDoc, {'lastId': next}, SetOptions(merge: true));
        return AppConstants.formatUniqueId(next);
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  // ── medical_staff CRUD ────────────────────────────────────────────────────

  Future<void> createStaffDoc(MedicalStaffModel model) async {
    try {
      await _staffCol.doc(model.userId).set(model.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Stream<MedicalStaffModel?> watchStaff(String userId) {
    return _staffCol.doc(userId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return MedicalStaffModel.fromFirestore(snap);
    });
  }

  Future<MedicalStaffModel?> getStaffByEmail(String email) async {
    try {
      final query =
          await _staffCol.where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isEmpty) return null;
      return MedicalStaffModel.fromFirestore(query.docs.first);
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Future<void> addClinicToStaff(String userId, String clinicId) async {
    try {
      await _staffCol.doc(userId).update({
        'clinicIds': FieldValue.arrayUnion([clinicId]),
        'currentClinicId': clinicId,
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  // ── clinics CRUD ──────────────────────────────────────────────────────────

  Future<ClinicModel> createClinic(ClinicModel model) async {
    try {
      final doctorSnap = await _staffCol.doc(model.doctorId).get();
      final doctorName = doctorSnap.exists 
          ? (doctorSnap.data()?['name'] as String? ?? 'Doctor')
          : 'Doctor';

      final ref = _clinicsCol.doc();
      final withId = ClinicModel(
        clinicId: ref.id,
        clinicName: model.clinicName,
        address: model.address,
        latitude: model.latitude,
        longitude: model.longitude,
        doctorId: model.doctorId,
        doctorName: doctorName,
        staffIds: [model.doctorId],
        rating: 0.0,
        ratingCount: 0,
        createdAt: DateTime.now(),
        isSessionActive: false,
        totalTokensIssuedToday: 0,
      );
      
      await ref.set(withId.toFirestore());
      await addClinicToStaff(model.doctorId, ref.id);
      return withId;
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Stream<ClinicModel?> watchClinic(String clinicId) {
    return _clinicsCol.doc(clinicId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ClinicModel.fromFirestore(snap);
    });
  }

  Stream<List<ClinicModel>> watchClinicsByDoctor(String doctorId) {
    return _clinicsCol
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ClinicModel.fromFirestore).toList());
  }

  Stream<List<ClinicModel>> watchClinicsByIds(List<String> clinicIds) {
    if (clinicIds.isEmpty) return Stream.value([]);
    return _clinicsCol
        .where(FieldPath.documentId, whereIn: clinicIds)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ClinicModel.fromFirestore).toList());
  }

  Future<ClinicModel?> getClinicById(String clinicId) async {
    try {
      final snap = await _clinicsCol.doc(clinicId).get();
      if (!snap.exists) return null;
      return ClinicModel.fromFirestore(snap);
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Future<void> addStaffToClinic(String clinicId, String staffId) async {
    try {
      await _clinicsCol.doc(clinicId).update({
        'staffIds': FieldValue.arrayUnion([staffId]),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Future<InviteModel> createInvite(InviteModel model) async {
    try {
      final ref = _invitesCol.doc();
      final withId = InviteModel(
        inviteId: ref.id,
        clinicId: model.clinicId,
        clinicName: model.clinicName,
        role: model.role,
        email: model.email,
        phone: model.phone,
        status: model.status,
        createdAt: model.createdAt,
      );
      await ref.set(withId.toFirestore());
      return withId;
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Stream<List<InviteModel>> watchInvitesByClinic(String clinicId) {
    return _invitesCol
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(InviteModel.fromFirestore).toList());
  }

  Stream<List<InviteModel>> watchInvitesByEmail(String email) {
    return _invitesCol
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(InviteModel.fromFirestore).toList());
  }

  Future<InviteModel?> getInviteById(String inviteId) async {
    try {
      final snap = await _invitesCol.doc(inviteId).get();
      if (!snap.exists) return null;
      return InviteModel.fromFirestore(snap);
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Future<void> updateInviteStatus(String inviteId, String status) async {
    try {
      await _invitesCol.doc(inviteId).update({'status': status});
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }

  Future<void> addDocumentToStaff(
      String userId, Map<String, dynamic> docMap) async {
    try {
      await _staffCol.doc(userId).update({
        'documents': FieldValue.arrayUnion([docMap]),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e.code, e.message);
    }
  }
}
