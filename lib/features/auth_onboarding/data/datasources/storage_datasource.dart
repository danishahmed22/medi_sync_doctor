import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/core/errors/app_exceptions.dart';

/// Handles all Firebase Storage interactions for document uploads.
class StorageRemoteDatasource {
  StorageRemoteDatasource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads [file] to Firebase Storage under the path:
  ///   `documents/{userId}/{documentType}/{timestamp}_{filename}`
  ///
  /// Returns the public download URL on success.
  /// Reports upload progress via [onProgress] (0.0 → 1.0).
  Future<String> uploadDocument({
    required String userId,
    required String documentType,
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path =
          '${AppConstants.storageDocumentsPath}/$userId/$documentType/$filename';

      final ref = _storage.ref().child(path);
      final task = ref.putFile(file);

      // Report upload progress.
      task.snapshotEvents.listen((snapshot) {
        if (onProgress != null && snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });

      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException.fromFirebase(e.code, e.message);
    }
  }

  /// Deletes a file given its full [downloadUrl].
  Future<void> deleteDocument(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException.fromFirebase(e.code, e.message);
    }
  }
}
