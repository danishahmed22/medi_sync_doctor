import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/widgets/loading_overlay.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/clinic_card.dart';

/// Multi-clinic switcher screen — allows users to switch their active clinic.
///
/// The selected [currentClinicId] is persisted in SharedPreferences and
/// refreshed across the app via [currentClinicProvider].
class ClinicSwitcherScreen extends ConsumerWidget {
  const ClinicSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffSyncProvider);
    final clinicsAsync = ref.watch(myClinicsProvider);
    final currentClinicAsync = ref.watch(currentClinicProvider);
    final clinicNotifier = ref.watch(clinicNotifierProvider);

    final currentClinicId = currentClinicAsync.value?.clinicId;

    return LoadingOverlay(
      isLoading: clinicNotifier.isLoading,
      message: 'Switching clinic…',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Switch Clinic'),
          actions: [
            // Add new clinic (doctors only)
            if (staff?.isDoctor == true)
              IconButton(
                icon: const Icon(Icons.add_business_rounded),
                color: AppColors.brandCyan,
                onPressed: () => context.push('/clinic-creation'),
                tooltip: 'Add New Clinic',
              ),
          ],
        ),
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Your Clinics',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.textPrimary),
                ).animate().fadeIn(),
              ),

              Expanded(
                child: clinicsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.brandCyan),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      e.toString(),
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (clinics) {
                    if (clinics.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_hospital_outlined,
                              size: 60,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No clinics yet.',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppColors.textHint),
                            ),
                            const SizedBox(height: 8),
                            if (staff?.isDoctor == true)
                              TextButton.icon(
                                onPressed: () =>
                                    context.push('/clinic-creation'),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Create your first clinic'),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: clinics.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final clinic = clinics[index];
                        final isActive =
                            clinic.clinicId == currentClinicId;
                        return ClinicCard(
                          clinic: clinic,
                          isActive: isActive,
                          onTap: () async {
                            if (isActive) return;
                            await ref
                                .read(clinicNotifierProvider.notifier)
                                .switchClinic(clinic.clinicId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Switched to ${clinic.clinicName}',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              context.pop();
                            }
                          },
                          trailing: isActive
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.brandCyan,
                                  size: 22,
                                )
                              : const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textHint,
                                ),
                        )
                            .animate(
                              delay: Duration(milliseconds: 50 * index),
                            )
                            .fadeIn()
                            .slideX(begin: 0.05);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
