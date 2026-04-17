import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/clinic_creation_screen.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/clinic_switcher_screen.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/document_upload_screen.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/login_screen.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/register_screen.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/role_selection_screen.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/splash_screen.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/screens/staff_invite_screen.dart';

// ── Route paths ──────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const roleSelection = '/role-selection';
  static const clinicCreation = '/clinic-creation';
  static const staffInvite = '/staff-invite';
  static const documentUpload = '/document-upload';
  static const clinicSwitcher = '/clinic-switcher';
  static const home = '/home';
}

// ── Router provider ──────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  // We listen directly to auth + staff to know when to rebuild.
  final authNotifier = ValueNotifier<bool>(false);

  ref.listen(authStateProvider, (_, __) => authNotifier.value = !authNotifier.value);
  ref.listen(currentStaffProvider, (_, __) => authNotifier.value = !authNotifier.value);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final staffAsync = ref.read(currentStaffProvider);

      // Still loading auth — stay on splash.
      if (authAsync.isLoading) return AppRoutes.splash;

      final user = authAsync.value;
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Not signed in → send to login.
      if (user == null) {
        if (isOnAuthRoute) return null;
        return AppRoutes.login;
      }

      // Signed in — check if staff profile exists.
      if (staffAsync.isLoading) return AppRoutes.splash;

      final staff = staffAsync.value;

      // No profile yet — new user, needs role selection.
      if (staff == null) {
        if (state.matchedLocation == AppRoutes.roleSelection) return null;
        // Allow register route so user can sign out etc.
        if (isOnAuthRoute) return null;
        return AppRoutes.roleSelection;
      }

      // Profile exists but no clinic yet (doctors only).
      if (staff.isDoctor && staff.clinicIds.isEmpty) {
        if (state.matchedLocation == AppRoutes.clinicCreation) return null;
        if (state.matchedLocation == AppRoutes.home) return null;
        return AppRoutes.clinicCreation;
      }

      // Redirect away from auth screens if already signed in.
      if (isOnAuthRoute ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.roleSelection) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.clinicCreation,
        builder: (_, __) => const ClinicCreationScreen(),
      ),
      GoRoute(
        path: AppRoutes.staffInvite,
        builder: (_, __) => const StaffInviteScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentUpload,
        builder: (_, __) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.clinicSwitcher,
        builder: (_, __) => const ClinicSwitcherScreen(),
      ),
      // ── Phase 2 placeholder home ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const _HomePlaceholder(),
      ),
    ],
  );
});

// ── Phase 2 placeholder ──────────────────────────────────────────────────────

class _HomePlaceholder extends ConsumerWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffSyncProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => context.push(AppRoutes.clinicSwitcher),
            tooltip: 'Switch Clinic',
          ),
          PopupMenuButton<void>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => <PopupMenuEntry<void>>[
              PopupMenuItem(
                child: const Text('Staff Management'),
                onTap: () => context.push(AppRoutes.staffInvite),
              ),
              PopupMenuItem(
                child: const Text('Upload Documents'),
                onTap: () => context.push(AppRoutes.documentUpload),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const Text('Sign Out'),
                onTap: () =>
                    ref.read(authActionsProvider.notifier).logout(),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_hospital_rounded,
              size: 64,
              color: Color(0xFF00E5CC),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${staff?.name ?? 'Doctor'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (staff != null)
              Text(
                'ID: #${staff.uniqueId}  •  ${staff.role.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 32),
            Text(
              'Phase 2 — Clinic Flow System\ncoming soon 🚀',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: const Color(0xFF8899BB)),
            ),
          ],
        ),
      ),
    );
  }
}
