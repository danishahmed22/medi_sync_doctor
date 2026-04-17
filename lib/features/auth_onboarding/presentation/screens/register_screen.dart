import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/utils/validators.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/core/widgets/app_text_field.dart';
import 'package:medisync_doctor/core/widgets/loading_overlay.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/auth_form_card.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/widgets/google_sign_in_button.dart';

/// Registration screen — creates Firebase Auth account then navigates to
/// role selection for profile completion.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _googleLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authActionsProvider.notifier).signUpWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    _handleResult();
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    await ref.read(authActionsProvider.notifier).signInWithGoogle();
    if (mounted) setState(() => _googleLoading = false);
    _handleResult();
  }

  void _handleResult() {
    final state = ref.read(authActionsProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
    // GoRouter redirect handles navigation after auth state changes.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionsProvider);
    final isLoading = authState.isLoading;

    return LoadingOverlay(
      isLoading: isLoading && !_googleLoading,
      message: 'Creating account…',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  GradientHeading('Create\nAccount ✨', fontSize: 32)
                      .animate()
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 6),
                  Text(
                    'Join MediSync as a healthcare professional.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 28),

                  AuthFormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            hint: 'Dr. Aisha Patel',
                            prefixIcon: const Icon(Icons.person_outline, size: 18),
                            validator: Validators.name,
                            autofillHints: const [AutofillHints.name],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            hint: 'doctor@hospital.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, size: 18),
                            validator: Validators.email,
                            autofillHints: const [AutofillHints.email],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _phoneCtrl,
                            label: 'Phone Number',
                            hint: '+91 9876543210',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                            validator: Validators.phone,
                            autofillHints: const [AutofillHints.telephoneNumber],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _passCtrl,
                            label: 'Password',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline, size: 18),
                            validator: Validators.password,
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _confirmPassCtrl,
                            label: 'Confirm Password',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline, size: 18),
                            validator: (v) => Validators.confirmPassword(
                                v, _passCtrl.text),
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Create Account',
                            onPressed: _register,
                            isLoading: isLoading && !_googleLoading,
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 24),
                  const OrDivider(),
                  const SizedBox(height: 24),

                  GoogleSignInButton(
                    onPressed: _googleSignIn,
                    isLoading: _googleLoading,
                  ).animate(delay: 300.ms).fadeIn(),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ).animate(delay: 400.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
