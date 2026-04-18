import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/medical/data/models/patient_model.dart';
import 'package:medisync_doctor/features/medical/data/models/prescription_model.dart';
import 'package:medisync_doctor/features/medical/data/models/visit_model.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/prescription_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/visit_entity.dart';
import 'package:medisync_doctor/features/medical/domain/repositories/medical_repository.dart';

class MedicalRepositoryImpl implements MedicalRepository {
  final FirebaseFirestore _db;

  MedicalRepositoryImpl(this._db);

  CollectionReference get _patientsCol => _db.collection(FirestoreCollections.patients);
  CollectionReference get _visitsCol => _db.collection(FirestoreCollections.visits);
  CollectionReference get _prescriptionsCol => _db.collection(FirestoreCollections.prescriptions);

  @override
  Future<PatientEntity?> getPatientByPhone(String phone) async {
    final query = await _patientsCol.where('phone', isEqualTo: phone).limit(1).get();
    if (query.docs.isEmpty) return null;
    return PatientModel.fromFirestore(query.docs.first).toEntity();
  }

  @override
  Future<PatientEntity?> getPatientById(String patientId) async {
    try {
      final doc = await _patientsCol.doc(patientId).get();
      if (!doc.exists) return null;
      return PatientModel.fromFirestore(doc).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PatientEntity> createPatient(PatientEntity patient) async {
    final ref = _patientsCol.doc();
    final model = PatientModel.fromEntity(patient.copyWith(patientId: ref.id));
    await ref.set(model.toFirestore());
    return model.toEntity();
  }

  @override
  Future<List<PatientEntity>> searchPatients(String query) async {
    final snap = await _patientsCol
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();
    
    return snap.docs.map((doc) => PatientModel.fromFirestore(doc).toEntity()).toList();
  }

  @override
  Future<void> saveConsultation({
    required VisitEntity visit,
    required List<MedicineInfo> medicines,
    String? tokenId,
  }) async {
    final visitRef = _visitsCol.doc();
    final prescriptionRef = _prescriptionsCol.doc();

    final visitModel = VisitModel.fromEntity(visit.copyWith(visitId: visitRef.id));
    
    final prescriptionModel = PrescriptionModel(
      prescriptionId: prescriptionRef.id,
      patientId: visit.patientId,
      visitId: visitRef.id,
      clinicId: visit.clinicId,
      doctorId: visit.doctorId,
      medicines: medicines.map((m) => MedicineInfoModel.fromEntity(m)).toList(),
      createdAt: DateTime.now(),
    );

    await _db.runTransaction((transaction) async {
      transaction.set(visitRef, visitModel.toFirestore());
      transaction.set(prescriptionRef, prescriptionModel.toFirestore());
      
      if (tokenId != null) {
        transaction.update(_db.collection(FirestoreCollections.tokens).doc(tokenId), {
          'status': TokenStatus.completed.firestoreValue,
          'completedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Stream<List<VisitEntity>> watchPatientVisits(String patientId) {
    return _visitsCol
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => VisitModel.fromFirestore(doc).toEntity()).toList());
  }

  @override
  Future<PrescriptionEntity?> getPrescriptionByVisit(String visitId) async {
    final query = await _prescriptionsCol.where('visitId', isEqualTo: visitId).limit(1).get();
    if (query.docs.isEmpty) return null;
    return PrescriptionModel.fromFirestore(query.docs.first).toEntity();
  }
}
