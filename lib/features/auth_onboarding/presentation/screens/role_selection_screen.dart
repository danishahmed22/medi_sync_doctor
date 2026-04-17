import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/utils/validators.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/core/widgets/app_text_field.dart';
import 'package:medisync_doctor/core/widgets/loading_overlay.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/auth_form_card.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/role_selection_card.dart';

/// Role selection + specialisation screen.
///
/// Shown after first-time registration (email or Google). On completion,
/// creates the Firestore `medical_staff` document with a unique 7-digit ID.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selectedRole;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _specialistCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _specialistCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your role.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    await ref.read(authActionsProvider.notifier).createProfile(
          userId: user.uid,
          name: _nameCtrl.text.trim().isNotEmpty
              ? _nameCtrl.text.trim()
              : (user.displayName ?? 'User'),
          email: user.email ?? '',
          phone: _phoneCtrl.text.trim(),
          role: _selectedRole!.firestoreValue,
          specialistIn: _specialistCtrl.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(authActionsProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(state.error.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    // GoRouter redirect will push to clinic-creation for doctors.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionsProvider);
    final isLoading = authState.isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Setting up your profile…',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Step 1 of 3',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.brandCyan,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  const GradientHeading('Your Role &\nSpecialisation')
                      .animate(delay: 50.ms)
                      .fadeIn()
                      .slideY(begin: -0.2),
                  const SizedBox(height: 6),
                  Text(
                    'This determines your access level in MediSync.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 32),

                  // Role cards
                  ...UserRole.values
                      .asMap()
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RoleSelectionCard(
                              role: e.value,
                              isSelected: _selectedRole == e.value,
                              onTap: () =>
                                  setState(() => _selectedRole = e.value),
                            )
                                .animate(
                                  delay: Duration(milliseconds: 150 + e.key * 80),
                                )
                                .fadeIn()
                                .slideX(begin: 0.1),
                          )),

                  const SizedBox(height: 24),

                  AuthFormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Complete your profile',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            hint: 'Dr. Aisha Patel',
                            prefixIcon:
                                const Icon(Icons.person_outline, size: 18),
                            validator: Validators.name,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _phoneCtrl,
                            label: 'Phone Number',
                            hint: '+91 9876543210',
                            keyboardType: TextInputType.phone,
                            prefixIcon:
                                const Icon(Icons.phone_outlined, size: 18),
                            validator: Validators.phone,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _specialistCtrl,
                            label: 'Specialisation',
                            hint:
                                'e.g. Cardiology, Paediatrics, General Practice',
                            prefixIcon: const Icon(
                                Icons.medical_services_outlined,
                                size: 18),
                            validator: Validators.specialistIn,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Continue',
                            onPressed: _continue,
                            isLoading: isLoading,
                            icon: const Icon(Icons.arrow_forward_rounded,
                                size: 18),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
