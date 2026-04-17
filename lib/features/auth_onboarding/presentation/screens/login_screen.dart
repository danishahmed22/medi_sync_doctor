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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authActionsProvider.notifier).loginWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    _handleAuthError();
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    await ref.read(authActionsProvider.notifier).signInWithGoogle();
    if (mounted) setState(() => _googleLoading = false);
    _handleAuthError();
  }

  void _handleAuthError() {
    final state = ref.read(authActionsProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionsProvider);
    final isLoading = authState.isLoading;

    return LoadingOverlay(
      isLoading: isLoading && !_googleLoading,
      message: 'Signing in…',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const SizedBox(height: 16),
                    GradientHeading('Welcome\nBack 👋', fontSize: 34)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.2),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your MediSync account',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 32),

                    // Form card
                    AuthFormCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: _emailCtrl,
                              label: 'Email',
                              hint: 'doctor@hospital.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined, size: 18),
                              validator: Validators.email,
                              autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passCtrl,
                              label: 'Password',
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline, size: 18),
                              validator: Validators.password,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 4),
                            AppButton(
                              label: 'Sign In',
                              onPressed: _login,
                              isLoading: isLoading && !_googleLoading,
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                    const SizedBox(height: 24),
                    const OrDivider(),
                    const SizedBox(height: 24),

                    // Google Sign-In
                    GoogleSignInButton(
                      onPressed: _googleSignIn,
                      isLoading: _googleLoading,
                    ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

                    const SizedBox(height: 32),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('Register'),
                        ),
                      ],
                    ).animate(delay: 400.ms).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
