import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:medisync_doctor/features/home/presentation/screens/main_navigation_hub.dart';
import 'package:medisync_doctor/features/medical/presentation/screens/patient_search_screen.dart';

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
  static const patientSearch = '/patient-search';
}

// ── Router provider ──────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);

  ref.listen(authStateProvider, (_, __) => authNotifier.value = !authNotifier.value);
  ref.listen(currentStaffProvider, (_, __) => authNotifier.value = !authNotifier.value);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final staffAsync = ref.read(currentStaffProvider);

      if (authAsync.isLoading) return AppRoutes.splash;

      final user = authAsync.value;
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (user == null) {
        if (isOnAuthRoute) return null;
        return AppRoutes.login;
      }

      if (staffAsync.isLoading) return AppRoutes.splash;

      final staff = staffAsync.value;

      if (staff == null) {
        if (state.matchedLocation == AppRoutes.roleSelection) return null;
        if (isOnAuthRoute) return null;
        return AppRoutes.roleSelection;
      }

      if (staff.isDoctor && staff.clinicIds.isEmpty) {
        if (state.matchedLocation == AppRoutes.clinicCreation) return null;
        if (state.matchedLocation == AppRoutes.home) return null;
        return AppRoutes.clinicCreation;
      }

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
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const MainNavigationHub(),
      ),
      GoRoute(
        path: AppRoutes.patientSearch,
        builder: (_, __) => const PatientSearchScreen(),
      ),
    ],
  );
});
