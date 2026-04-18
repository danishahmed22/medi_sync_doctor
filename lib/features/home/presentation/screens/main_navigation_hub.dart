import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/router/app_router.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/clinic_flow/presentation/screens/queue_dashboard_screen.dart';
import 'package:medisync_doctor/features/retention/presentation/screens/insights_dashboard_screen.dart';
import 'package:medisync_doctor/features/operations/presentation/screens/inventory_screen.dart';
import 'package:medisync_doctor/features/staff_management/presentation/screens/staff_activity_screen.dart';
import 'package:medisync_doctor/features/home/presentation/screens/settings_screen.dart';

class MainNavigationHub extends ConsumerStatefulWidget {
  const MainNavigationHub({super.key});

  @override
  ConsumerState<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends ConsumerState<MainNavigationHub> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const QueueDashboardScreen(),
    const InsightsDashboardScreen(),
    const InventoryScreen(),
    const StaffActivityScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Live Queue',
    'Clinical Insights',
    'Inventory & Stock',
    'Staff Activity',
    'Account Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffSyncProvider);
    final currentClinic = ref.watch(currentClinicProvider).value;

    if (_selectedIndex >= _screens.length) _selectedIndex = 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titles[_selectedIndex]),
            if (currentClinic != null)
              Text(
                currentClinic.clinicName,
                style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
          ],
        ),
        actions: [
          if (currentClinic != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildSessionIndicator(currentClinic),
            ),
        ],
      ),
      drawer: _buildClinicalDrawer(context, staff),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.brandCyan.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.queue_play_next_rounded), label: 'Queue'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.history_edu_rounded), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSessionIndicator(dynamic clinic) {
    final isActive = clinic.isSessionActive;
    return InkWell(
      onTap: () => isActive ? _showEndSessionDialog(context, ref, clinic.clinicId) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.green : Colors.red, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: isActive ? Colors.green : Colors.red),
            const SizedBox(width: 6),
            Text(
              isActive ? 'LIVE' : 'OFFLINE',
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: isActive ? Colors.green : Colors.red,
                letterSpacing: 0.5,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.power_settings_new_rounded, size: 12, color: Colors.green),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalDrawer(BuildContext context, dynamic staff) {
    return Drawer(
      backgroundColor: AppColors.cardDark,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.brandCyan),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.medical_services_rounded, color: Colors.white, size: 32),
            ),
            accountName: Text(staff?.name ?? 'Doctor'),
            accountEmail: Text(staff?.specialistIn ?? 'Medical Professional'),
          ),
          ListTile(
            leading: const Icon(Icons.search_rounded),
            title: const Text('Patient Registry'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.patientSearch);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_business_rounded),
            title: const Text('Manage Clinics'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.clinicSwitcher);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            onTap: () => ref.read(authActionsProvider.notifier).logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, WidgetRef ref, String clinicId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('End Session?'),
        content: const Text('This will stop new tokens. You can restart it any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(clinicNotifierProvider.notifier).endSession(clinicId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}
