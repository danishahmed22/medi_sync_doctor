import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/features/staff_management/presentation/providers/staff_management_provider.dart';
import 'package:medisync_doctor/features/staff_management/domain/entities/activity_log_entity.dart';
import 'package:intl/intl.dart';

class StaffActivityScreen extends ConsumerWidget {
  const StaffActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(staffActivityStreamProvider);
    final statsAsync = ref.watch(staffPerformanceStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Management & Audit'),
      ),
      body: Column(
        children: [
          statsAsync.when(
            data: (stats) => _buildSummaryStats(context, stats),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
          ),
          Expanded(
            child: activityAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return _buildActivityLogTile(context, logs[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, Map<String, int> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Actions', '${stats['totalActions'] ?? 0}', Icons.bolt_rounded),
          _buildStatItem('Active Staff', '${stats['activeStaff'] ?? 0}', Icons.people_outline_rounded),
          _buildStatItem('Exceptions', '${stats['exceptions'] ?? 0}', Icons.gpp_maybe_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.brandCyan, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No activity logs found for today', style: TextStyle(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildActivityLogTile(BuildContext context, ActivityLogEntity log) {
    final isWarning = log.actionType == 'SKIP_TOKEN' || log.actionType == 'DELETE_MEDICINE';
    final timeStr = DateFormat('hh:mm a').format(log.createdAt);

    IconData icon;
    switch (log.actionType) {
      case 'CREATE_TOKEN':
        icon = Icons.add_circle_outline;
        break;
      case 'START_CONSULTATION':
        icon = Icons.play_circle_outline;
        break;
      case 'COMPLETE_CONSULTATION':
        icon = Icons.check_circle_outline;
        break;
      case 'UPDATE_STOCK':
        icon = Icons.inventory_2_outlined;
        break;
      default:
        icon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isWarning ? AppColors.error.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWarning ? AppColors.error.withOpacity(0.1) : AppColors.brandCyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isWarning ? AppColors.error : AppColors.brandCyan, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    children: [
                      TextSpan(text: '${log.userName} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '(${log.userRole}) ', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ),
                ),
                Text(log.humanReadableMessage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Text(timeStr, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
        ],
      ),
    );
  }
}
