import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/widgets/app_text_field.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/presentation/providers/medical_provider.dart';
import 'package:medisync_doctor/features/medical/presentation/screens/consultation_screen.dart';

class PatientSearchScreen extends ConsumerWidget {
  const PatientSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(patientSearchResultsProvider);
    final query = ref.watch(patientSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Patient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (v) => ref.read(patientSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search by phone or name...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: searchResults.when(
              data: (patients) {
                if (patients.isEmpty && query.isNotEmpty) {
                  return _buildNoResults(context);
                }
                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(patient.name),
                      subtitle: Text(patient.phone),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ConsultationScreen(patient: patient)),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPatientDialog(context, ref),
        label: const Text('New Patient'),
        icon: const Icon(Icons.person_add_rounded),
        backgroundColor: AppColors.brandCyan,
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('No patient found. Add them as a new patient.', style: TextStyle(color: AppColors.textHint)),
        ],
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context, WidgetRef ref) {
    // Basic dialog to add patient quickly
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Add New Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
            TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(medicalRepositoryProvider);
              final p = PatientEntity(
                patientId: '',
                name: nameCtrl.text,
                phone: phoneCtrl.text,
                age: int.tryParse(ageCtrl.text) ?? 0,
                gender: 'Male', // Default for now
                createdAt: DateTime.now(),
              );
              final created = await repo.createPatient(p);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConsultationScreen(patient: created)),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
