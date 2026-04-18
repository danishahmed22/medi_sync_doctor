import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/usecases/get_estimated_wait_time.dart';
import 'package:medisync_doctor/features/clinic_flow/presentation/providers/clinic_flow_provider.dart';
import 'package:medisync_doctor/features/clinic_flow/presentation/widgets/current_patient_card.dart';
import 'package:medisync_doctor/features/clinic_flow/presentation/widgets/queue_list_tile.dart';

class QueueDashboardScreen extends ConsumerStatefulWidget {
  const QueueDashboardScreen({super.key});

  @override
  ConsumerState<QueueDashboardScreen> createState() => _QueueDashboardScreenState();
}

class _QueueDashboardScreenState extends ConsumerState<QueueDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex, List<TokenEntity> queue) {
    if (newIndex > oldIndex) newIndex -= 1;
    final items = List<TokenEntity>.from(queue);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    
    ref.read(clinicFlowRepositoryProvider).reorderQueue(items);
  }

  @override
  Widget build(BuildContext context) {
    final currentClinic = ref.watch(currentClinicProvider).value;
    final currentPatient = ref.watch(currentPatientProvider);
    final waitingQueue = ref.watch(waitingQueueProvider);
    final appointments = ref.watch(appointmentStreamProvider).value ?? [];
    final stats = ref.watch(clinicStatsStreamProvider).value;

    if (currentClinic == null) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.brandCyan,
          labelColor: AppColors.brandCyan,
          unselectedLabelColor: AppColors.textHint,
          tabs: const [Tab(text: 'Live Queue'), Tab(text: 'Appointments')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ── Live Queue Tab ────────────────────────────────────────
              Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async => ref.refresh(queueStreamProvider),
                    color: AppColors.brandCyan,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsHeader(context, stats?.avgConsultationTimeInMinutes ?? 10.0),
                          const SizedBox(height: 24),

                          const Text('NOW SERVING', style: TextStyle(color: AppColors.textHint, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 12),
                          if (currentPatient != null)
                            CurrentPatientCard(
                              token: currentPatient,
                              onComplete: () => ref.read(queueActionsProvider.notifier).completeConsultation(currentPatient.tokenId),
                            ).animate().fadeIn()
                          else
                            _buildEmptyCurrentState(context, ref, waitingQueue, currentClinic.isSessionActive),

                          const SizedBox(height: 32),

                          Text('WAITING LIST (${waitingQueue.length})', style: const TextStyle(color: AppColors.textHint, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 12),
                          
                          if (waitingQueue.isEmpty)
                            _buildEmptyQueueState(context)
                          else
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: waitingQueue.length,
                              onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, waitingQueue),
                              itemBuilder: (context, index) {
                                final token = waitingQueue[index];
                                final waitTime = const GetEstimatedWaitTime().call(
                                  waitingQueue: waitingQueue,
                                  avgConsultationTime: stats?.avgConsultationTimeInMinutes ?? 10.0,
                                  targetTokenId: token.tokenId,
                                );

                                return Padding(
                                  key: ValueKey(token.tokenId),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: QueueListTile(
                                    token: token,
                                    estimatedWaitMinutes: waitTime.round(),
                                    onStart: () => ref.read(queueActionsProvider.notifier).startConsultation(token.tokenId),
                                    onSkip: () => ref.read(queueActionsProvider.notifier).skipToken(token.tokenId),
                                    onPrioritize: () {}, 
                                  ),
                                );
                              },
                            ),
                          
                          const SizedBox(height: 40),
                          _buildDisclaimer(context),
                        ],
                      ),
                    ),
                  ),
                  if (!currentClinic.isSessionActive)
                    _buildStartSessionOverlay(context, ref, currentClinic.clinicId),
                ],
              ),

              // ── Appointments Tab ──────────────────────────────────────
              _buildAppointmentsTab(context, ref, appointments),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(BuildContext context, double avgTime) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandCyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandCyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed_rounded, color: AppColors.brandCyan),
          const SizedBox(width: 12),
          Text('Avg. Consultation: ${avgTime.toStringAsFixed(1)} min', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(BuildContext context, WidgetRef ref, List appointments) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            label: 'Book New Appointment',
            onPressed: () => _showAddAppointmentDialog(context, ref),
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
          ),
        ),
        Expanded(
          child: appointments.isEmpty
              ? const Center(child: Text('No upcoming appointments'))
              : ListView.builder(
                  itemCount: appointments.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Scheduled for ${appt.scheduledTime.toString().substring(0, 16)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.login_rounded, color: AppColors.brandCyan),
                          onPressed: () => ref.read(queueActionsProvider.notifier).convertAppointment(appt),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStartSessionOverlay(BuildContext context, WidgetRef ref, String clinicId) {
    return Container(
      color: AppColors.background.withOpacity(0.9),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.brandCyan.withOpacity(0.3))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_filled_rounded, size: 80, color: AppColors.brandCyan),
              const SizedBox(height: 24),
              const Text('Start Session?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              AppButton(label: 'Start Token Count', onPressed: () => ref.read(clinicNotifierProvider.notifier).startSession(clinicId)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCurrentState(BuildContext context, WidgetRef ref, List waiting, bool isSessionActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          const Icon(Icons.person_search_rounded, size: 48, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('No active consultation', style: TextStyle(fontWeight: FontWeight.bold)),
          if (isSessionActive && waiting.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppButton(label: 'Call Next Patient', onPressed: () => ref.read(queueActionsProvider.notifier).startConsultation(waiting.first.tokenId)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueueState(BuildContext context) {
    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Queue is empty')));
  }

  Widget _buildDisclaimer(BuildContext context) {
    return const Center(child: Text('⚠️ Estimated wait time is approximate and may vary.', style: TextStyle(color: AppColors.textHint, fontSize: 12, fontStyle: FontStyle.italic)));
  }

  void _showAddPatientDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Add Walk-in Patient'),
        content: TextField(controller: nameCtrl, autofocus: true, decoration: const InputDecoration(labelText: 'Patient Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ref.read(queueActionsProvider.notifier).generateWalkInToken(nameCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Book Appointment'),
        content: TextField(controller: nameCtrl, autofocus: true, decoration: const InputDecoration(labelText: 'Patient Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ref.read(queueActionsProvider.notifier).createAppointment(nameCtrl.text, DateTime.now().add(const Duration(minutes: 15)));
                Navigator.pop(context);
              }
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}
