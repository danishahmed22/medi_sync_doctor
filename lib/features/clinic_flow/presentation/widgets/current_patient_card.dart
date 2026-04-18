import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/presentation/providers/active_patient_provider.dart';
import 'package:medisync_doctor/features/medical/presentation/screens/consultation_screen.dart';

class CurrentPatientCard extends ConsumerWidget {
  const CurrentPatientCard({
    super.key,
    required this.token,
    required this.onComplete,
  });

  final TokenEntity token;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(activePatientDetailProvider);
    final history = ref.watch(activePatientHistoryProvider).value ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandCyan, AppColors.brandTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandCyan.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOKEN #${token.tokenNumber}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    token.patientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 28,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
              ),
            ],
          ),
          
          patientAsync.when(
            data: (patient) {
              if (patient == null) return const SizedBox.shrink();
              final isNew = patient.patientId == 'NEW_PATIENT';
              
              return Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem('Age/Sex', isNew ? 'Pending' : '${patient.age} / ${patient.gender}'),
                      _buildInfoItem('Total Visits', isNew ? '0' : history.length.toString()),
                      _buildInfoItem('Status', isNew ? 'Walk-in' : 'Registered'),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LinearProgressIndicator(color: Colors.white24),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Robust lookup using ref.read to bypass any async UI lag
                    final patient = ref.read(activePatientDetailProvider).value ?? 
                      PatientEntity(
                        patientId: 'NEW_PATIENT',
                        name: token.patientName,
                        phone: '', age: 0, gender: 'Not Specified',
                        createdAt: DateTime.now(),
                      );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultationScreen(
                          patient: patient,
                          token: token,
                        ),
                      ),
                    );
                  },
                  child: AppButton(
                    label: 'Start Consultation',
                    onPressed: null, // Tap handled by GestureDetector for maximum reliability
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.medical_services_outlined, size: 20, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onComplete,
                  child: AppButton(
                    label: 'Complete',
                    onPressed: null, // Tap handled by GestureDetector
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.brandTeal,
                    icon: const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.brandTeal),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
