import 'package:flutter/material.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';

/// Tile for a single document type at the upload screen.
/// Shows upload status, progress, and a pick-file action.
class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile({
    super.key,
    required this.documentType,
    this.uploadedUrl,
    this.isUploading = false,
    this.progress = 0.0,
    required this.onPickFile,
  });

  final DocumentType documentType;
  final String? uploadedUrl;
  final bool isUploading;
  final double progress;
  final VoidCallback onPickFile;

  bool get isUploaded => uploadedUrl != null && uploadedUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded ? AppColors.success.withOpacity(0.5) : AppColors.border,
          width: isUploaded ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isUploaded ? AppColors.success : AppColors.brandCyan)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUploaded
                      ? Icons.task_alt_rounded
                      : Icons.upload_file_rounded,
                  color: isUploaded ? AppColors.success : AppColors.brandCyan,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentType.displayName,
                      style: tt.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      documentType.subtitle,
                      style: tt.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Upload button / status icon
              if (isUploading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandCyan,
                  ),
                )
              else if (isUploaded)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                )
              else
                GestureDetector(
                  onTap: onPickFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Text(
                      'Upload',
                      style: TextStyle(
                        color: AppColors.brandCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Progress bar
          if (isUploading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surface,
                color: AppColors.brandCyan,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}%',
              style: tt.bodySmall?.copyWith(color: AppColors.textHint),
            ),
          ],
          // View uploaded document link
          if (isUploaded) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onPickFile,
              child: Text(
                'Replace document',
                style: tt.bodySmall?.copyWith(
                  color: AppColors.brandCyan,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.brandCyan,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
