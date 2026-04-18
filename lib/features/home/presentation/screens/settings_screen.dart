import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffSyncProvider);
    final currentClinic = ref.watch(currentClinicProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Summary
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.brandCyan,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    staff?.name ?? 'Loading...',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    staff?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(staff?.role.toUpperCase() ?? ''),
                    backgroundColor: AppColors.brandCyan.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.brandCyan, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Session Control
            if (currentClinic != null) ...[
              _buildSectionHeader('Clinic Session'),
              ListTile(
                leading: Icon(
                  Icons.power_settings_new_rounded,
                  color: currentClinic.isSessionActive ? AppColors.error : AppColors.success,
                ),
                title: Text(currentClinic.isSessionActive ? 'End Session' : 'Start Session'),
                subtitle: Text(currentClinic.isSessionActive 
                  ? 'Close clinic and stop token issuance' 
                  : 'Open clinic for patient tokens'),
                trailing: Switch(
                  value: currentClinic.isSessionActive,
                  onChanged: (value) {
                    if (value) {
                      ref.read(clinicNotifierProvider.notifier).startSession(currentClinic.clinicId);
                    } else {
                      ref.read(clinicNotifierProvider.notifier).endSession(currentClinic.clinicId);
                    }
                  },
                ),
              ),
              const Divider(),
            ],

            _buildSectionHeader('Account'),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              onTap: () => _showLogoutDialog(context, ref),
            ),
            
            const SizedBox(height: 40),
            const Text(
              'MediSync Doctor v1.0.0',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.brandCyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to log out of MediSync?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authActionsProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
