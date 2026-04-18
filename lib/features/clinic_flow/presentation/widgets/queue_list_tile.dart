import 'package:flutter/material.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';

class QueueListTile extends StatelessWidget {
  const QueueListTile({
    super.key,
    required this.token,
    required this.estimatedWaitMinutes,
    required this.onStart,
    required this.onSkip,
    required this.onPrioritize,
  });

  final TokenEntity token;
  final int estimatedWaitMinutes;
  final VoidCallback onStart;
  final VoidCallback onSkip;
  final VoidCallback onPrioritize;

  @override
  Widget build(BuildContext context) {
    // Logic for "No-Show" visual warning
    final waitDuration = DateTime.now().difference(token.createdAt);
    final isWaitingLong = waitDuration.inMinutes > 30; // Threshold for no-show warning

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWaitingLong ? AppColors.error.withOpacity(0.5) : AppColors.border,
          width: isWaitingLong ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Token Number
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${token.tokenNumber}',
                style: const TextStyle(
                  color: AppColors.brandCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      token.patientName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (token.priority > 0) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.priority_high_rounded, size: 14, color: AppColors.error),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (token.isAppointment) ...[
                      const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.brandTeal),
                      const SizedBox(width: 4),
                      const Text('Appointment', style: TextStyle(color: AppColors.brandTeal, fontSize: 12)),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.access_time_rounded, size: 12, color: isWaitingLong ? AppColors.error : AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      'Waiting ${waitDuration.inMinutes}m',
                      style: TextStyle(color: isWaitingLong ? AppColors.error : AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Wait Time & Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$estimatedWaitMinutes min',
                style: const TextStyle(
                  color: AppColors.brandCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _IconButton(
                    icon: Icons.priority_high_rounded,
                    color: token.priority > 0 ? AppColors.brandCyan : AppColors.textHint,
                    onTap: onPrioritize,
                    tooltip: 'Prioritize (Emergency)',
                  ),
                  const SizedBox(width: 8),
                  _IconButton(
                    icon: Icons.skip_next_rounded,
                    color: AppColors.error,
                    onTap: onSkip,
                    tooltip: 'Skip (No-show)',
                  ),
                  const SizedBox(width: 8),
                  _IconButton(
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.success,
                    onTap: onStart,
                    tooltip: 'Start Consultation',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.color, required this.onTap, this.tooltip});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
