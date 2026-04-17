import 'package:flutter/material.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/features/auth_onboarding/domain/entities/clinic_entity.dart';

/// Card displaying clinic summary — used in lists and the clinic switcher.
class ClinicCard extends StatelessWidget {
  const ClinicCard({
    super.key,
    required this.clinic,
    this.isActive = false,
    this.onTap,
    this.trailing,
  });

  final ClinicEntity clinic;
  final bool isActive;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandCyan.withOpacity(0.08)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.brandCyan : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Clinic avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.brandCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.brandCyan,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinic name + active badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          clinic.clinicName,
                          style: tt.titleSmall?.copyWith(
                            color: isActive
                                ? AppColors.brandCyan
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandCyan.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.brandCyan,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clinic.address,
                          style: tt.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating + staff count
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        clinic.rating > 0
                            ? '${clinic.rating.toStringAsFixed(1)} '
                                '(${clinic.ratingCount})'
                            : 'No ratings yet',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textHint, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.groups_outlined,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${clinic.staffIds.length} staff',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
