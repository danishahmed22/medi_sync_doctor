import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/invite_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/auth_form_card.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/document_upload_tile.dart';

/// Document upload screen — Step 3 of doctor onboarding.
///
/// Allows uploading medical license, clinic registration proof, and ID card
/// to Firebase Storage. URLs are persisted in `medical_staff.documents[]`.
class DocumentUploadScreen extends ConsumerWidget {
  const DocumentUploadScreen({super.key});

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    DocumentType docType,
    String userId,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);

    await ref.read(documentUploadProvider.notifier).uploadDocument(
          userId: userId,
          documentType: docType,
          file: file,
        );

    final state = ref.read(documentUploadProvider);
    if (state.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final staff = ref.watch(currentStaffSyncProvider);
    final uploadState = ref.watch(documentUploadProvider);

    final uploadedUrls = {
      for (final doc in staff?.documents ?? []) doc.type: doc.url,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification Documents'),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
        ],
      ),
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Step 3 of 3',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.brandCyan,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              const GradientHeading('Upload\nDocuments 📄')
                  .animate(delay: 50.ms)
                  .fadeIn()
                  .slideY(begin: -0.2),
              const SizedBox(height: 6),
              Text(
                'Required for account verification. Admin will review within 24–48 hours.',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate(delay: 100.ms).fadeIn(),

              // Verification status
              if (staff != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Text(
                      staff.isVerified
                          ? '✅ Your account is verified.'
                          : '⏳ Pending verification by admin.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: staff.isVerified
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 28),

              // Document tiles
              ...DocumentType.values.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DocumentUploadTile(
                        documentType: e.value,
                        uploadedUrl: uploadedUrls[e.value.firestoreValue],
                        isUploading: uploadState.isUploading,
                        progress: uploadState.progress,
                        onPickFile: () => _pickAndUpload(
                          context,
                          ref,
                          e.value,
                          user?.uid ?? '',
                        ),
                      )
                          .animate(
                            delay: Duration(milliseconds: 150 + e.key * 80),
                          )
                          .fadeIn()
                          .slideX(begin: 0.1),
                    ),
                  ),

              const SizedBox(height: 28),

              // Supported formats note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardDarker,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.file_present_outlined,
                        size: 16, color: AppColors.textHint),
                    const SizedBox(width: 10),
                    Text(
                      'Supported: PDF, JPG, JPEG, PNG (max 10 MB)',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: 24),
              AppButton(
                label: 'Finish Setup',
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.check_rounded, size: 18),
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
