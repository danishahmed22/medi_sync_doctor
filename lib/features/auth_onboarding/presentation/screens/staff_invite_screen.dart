import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/utils/validators.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/core/widgets/app_text_field.dart';
import 'package:medisync_doctor/core/widgets/loading_overlay.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/invite_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/auth_form_card.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/invite_tile.dart';

/// Allows doctors to invite staff and view all pending/accepted invites
/// for the currently active clinic.
class StaffInviteScreen extends ConsumerStatefulWidget {
  const StaffInviteScreen({super.key});

  @override
  ConsumerState<StaffInviteScreen> createState() => _StaffInviteScreenState();
}

class _StaffInviteScreenState extends ConsumerState<StaffInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.compounder;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInvite(String clinicId, String clinicName) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(inviteNotifierProvider.notifier).sendInvite(
          clinicId: clinicId,
          clinicName: clinicName,
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isNotEmpty
              ? _phoneCtrl.text.trim()
              : null,
          role: _selectedRole,
        );

    if (!mounted) return;
    final state = ref.read(inviteNotifierProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(state.error.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      _emailCtrl.clear();
      _phoneCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite sent successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentClinic = ref.watch(currentClinicProvider).value;
    final inviteState = ref.watch(inviteNotifierProvider);

    if (currentClinic == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Staff Invites')),
        body: const Center(
          child: Text(
            'Please create or select a clinic first.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final invitesAsync = ref.watch(
        clinicInvitesProvider(currentClinic.clinicId));

    return LoadingOverlay(
      isLoading: inviteState.isLoading,
      message: 'Sending invite…',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Column(
            children: [
              const Text('Staff Management'),
              Text(
                currentClinic.clinicName,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () {},
              tooltip: 'Staff info',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invite form
              Text(
                'Invite Staff Member',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.textPrimary),
              ).animate().fadeIn(),
              const SizedBox(height: 12),

              AuthFormCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _emailCtrl,
                        label: 'Staff Email',
                        hint: 'staff@clinic.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _phoneCtrl,
                        label: 'Phone (optional)',
                        hint: '+91 9876543210',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                        validator: Validators.optionalPhone,
                      ),
                      const SizedBox(height: 12),

                      // Role dropdown
                      DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        dropdownColor: AppColors.cardDark,
                        decoration: InputDecoration(
                          labelText: 'Assign Role',
                          prefixIcon: const Icon(Icons.badge_outlined,
                              size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.brandCyan, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.cardDarker,
                        ),
                        items: [UserRole.compounder, UserRole.receptionist]
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.displayName),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedRole = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Send Invite',
                        onPressed: () =>
                            _sendInvite(currentClinic.clinicId,
                                currentClinic.clinicName),
                        isLoading: inviteState.isLoading,
                        icon: const Icon(Icons.send_rounded, size: 16),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Invites list
              Text(
                'Sent Invites',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.textPrimary),
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 12),

              invitesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brandCyan),
                ),
                error: (e, _) => Text(
                  e.toString(),
                  style: const TextStyle(color: AppColors.error),
                ),
                data: (invites) {
                  if (invites.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.group_add_outlined,
                            color: AppColors.textHint,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No invites sent yet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: invites
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InviteTile(
                                invite: e.value,
                                showActions: false,
                              ).animate(
                                delay: Duration(
                                    milliseconds: 50 * e.key),
                              ).fadeIn(),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
