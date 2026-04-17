import 'dart:io';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/medical_staff_entity.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/repositories/invite_repository.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';

class UploadDocumentParams {
  const UploadDocumentParams({
    required this.userId,
    required this.file,
    required this.documentType,
  });

  final String userId;
  final File file;
  final DocumentType documentType;
}

/// Coordinates uploading a document to Firebase Storage and persisting
/// the resulting URL to Firestore (via the [StorageRemoteDatasource] and
/// [InviteRepository]).
///
/// Note: The actual Storage upload is handled in the datasource layer.
/// This use case receives the download URL from the caller (via the provider)
/// and writes it to Firestore.
class UploadDocuments {
  const UploadDocuments(this._inviteRepo);
  final InviteRepository _inviteRepo;

  Future<void> saveDocumentUrl({
    required String userId,
    required DocumentType documentType,
    required String downloadUrl,
  }) async {
    final doc = DocumentInfo(
      type: documentType.firestoreValue,
      url: downloadUrl,
      uploadedAt: DateTime.now(),
    );
    await _inviteRepo.addDocument(userId: userId, document: doc);
  }
}
