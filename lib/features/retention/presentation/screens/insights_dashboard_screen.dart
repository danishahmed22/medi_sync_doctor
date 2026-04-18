import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/auth_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/clinic_flow/presentation/providers/clinic_flow_provider.dart';

class InsightsDashboardScreen extends ConsumerWidget {
  const InsightsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(clinicStatsStreamProvider).value;
    final queue = ref.watch(queueStreamProvider).value ?? [];
    
    final completedCount = queue.where((t) => t.isCompleted).length;
    final skippedCount = queue.where((t) => t.isSkipped).length;
    
    // Revenue Estimate (Simple: 500 per patient)
    final revenue = completedCount * 500;
    final lostRevenue = skippedCount * 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Clinical Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildValueCard(
              context,
              title: 'Patients Treated Today',
              value: completedCount.toString(),
              subtitle: 'Target: 40 patients',
              icon: Icons.person,
              color: AppColors.brandCyan,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildValueCard(
                    context,
                    title: 'Revenue',
                    value: '₹$revenue',
                    subtitle: 'Today\'s Earnings',
                    icon: Icons.payments_rounded,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildValueCard(
                    context,
                    title: 'Lost Revenue',
                    value: '₹$lostRevenue',
                    subtitle: 'From No-Shows',
                    icon: Icons.money_off_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Operational Efficiency'),
            const SizedBox(height: 12),
            _buildEfficiencyCard(
              context,
              avgTime: stats?.avgConsultationTimeInMinutes ?? 10.0,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Time Saved with MediSync'),
            const SizedBox(height: 12),
            _buildTimeSavedCard(context, completedCount),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textHint,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }

  Widget _buildValueCard(BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard(BuildContext context, {required double avgTime}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandCyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(
            value: 0.85,
            strokeWidth: 8,
            backgroundColor: Colors.white10,
            color: AppColors.brandCyan,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consultation Speed', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Currently averaging ${avgTime.toStringAsFixed(1)} mins per patient.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSavedCard(BuildContext context, int completed) {
    final minsSaved = completed * 2;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.brandCyan, AppColors.brandTeal]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$minsSaved Minutes Saved', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Compared to manual registration', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
