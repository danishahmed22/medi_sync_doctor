import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/core/widgets/app_button.dart';
import 'package:medisync_doctor/core/widgets/loading_overlay.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/user_provider.dart';
import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/patient_entity.dart';
import 'package:medisync_doctor/features/medical/domain/entities/prescription_entity.dart';
import 'package:medisync_doctor/features/medical/domain/utils/prescription_pdf_generator.dart';
import 'package:medisync_doctor/features/medical/presentation/providers/medical_provider.dart';
import 'package:medisync_doctor/features/medical/presentation/providers/medicine_intelligence_provider.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({
    super.key,
    required this.patient,
    this.token,
  });

  final PatientEntity patient;
  final TokenEntity? token;

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  final _symptomsCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final List<MedicineInfo> _medicines = [];

  void _addMedicine([String? name]) {
    setState(() {
      _medicines.add(MedicineInfo(
        name: name ?? '',
        dosage: '500mg',
        frequency: '1-0-1',
        duration: '5 days',
        instructions: 'After food',
      ));
    });
  }

  void _removeMedicine(int index) {
    setState(() => _medicines.removeAt(index));
  }

  Future<void> _finishAndExport() async {
    // 1. Save to Firestore
    await ref.read(consultationProvider.notifier).saveConsultation(
          patient: widget.patient,
          symptoms: _symptomsCtrl.text.trim(),
          diagnosis: _diagnosisCtrl.text.trim(),
          medicines: _medicines,
          tokenId: widget.token?.tokenId,
        );

    // 2. Track medicines in intelligence cache
    for (final med in _medicines) {
      ref.read(medicineSuggestionsProvider.notifier).trackMedicineUsage(med.name);
    }

    // 3. Generate and Export PDF (Save/Share/Print)
    if (mounted) {
      final clinic = ref.read(currentClinicProvider).value;
      final doctor = ref.read(currentStaffSyncProvider);
      
      if (clinic != null && doctor != null) {
        final rx = PrescriptionEntity(
          prescriptionId: 'TEMP',
          patientId: widget.patient.patientId,
          visitId: 'TEMP',
          clinicId: clinic.clinicId,
          doctorId: doctor.userId,
          medicines: _medicines,
          createdAt: DateTime.now(),
        );

        await PrescriptionPdfGenerator.generateAndExport(
          prescription: rx,
          patient: widget.patient,
          clinic: clinic,
          doctor: doctor,
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consultationProvider);
    final suggestions = ref.watch(medicineSuggestionsProvider);

    return LoadingOverlay(
      isLoading: state.isLoading,
      message: 'Generating Prescription...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Consultation: ${widget.patient.name}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Clinical Notes'),
              const SizedBox(height: 12),
              _buildTextField(_symptomsCtrl, 'Symptoms', 'e.g. Fever, Cough', 2),
              const SizedBox(height: 12),
              _buildTextField(_diagnosisCtrl, 'Diagnosis', 'e.g. Viral Infection', 2),
              
              const SizedBox(height: 32),

              _buildSectionHeader('Prescription Suggestions'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(s),
                      onPressed: () => _addMedicine(s),
                      backgroundColor: AppColors.brandCyan.withOpacity(0.1),
                    ),
                  )).toList(),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('Prescription (Rx)'),
                  IconButton(
                    onPressed: () => _addMedicine(),
                    icon: const Icon(Icons.add_circle_rounded, color: AppColors.brandCyan),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_medicines.isEmpty)
                _buildEmptyMedicinesState()
              else
                ..._medicines.asMap().entries.map((e) => _buildMedicineTile(e.key, e.value)),

              const SizedBox(height: 40),
              AppButton(
                label: 'Save & Export Rx',
                onPressed: _finishAndExport,
                icon: const Icon(Icons.ios_share_rounded, size: 20),
              ),
            ],
          ),
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

  Widget _buildTextField(TextEditingController ctrl, String label, String hint, int lines) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildMedicineTile(int index, MedicineInfo med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: med.name,
                  onChanged: (v) => _medicines[index] = med.copyWith(name: v),
                  decoration: const InputDecoration(hintText: 'Medicine Name', border: InputBorder.none),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: () => _removeMedicine(index),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              _buildQuickField('Dosage', med.dosage, (v) => setState(() => _medicines[index] = med.copyWith(dosage: v))),
              const SizedBox(width: 8),
              _buildQuickField('Frequency', med.frequency, (v) => setState(() => _medicines[index] = med.copyWith(frequency: v))),
              const SizedBox(width: 8),
              _buildQuickField('Days', med.duration, (v) => setState(() => _medicines[index] = med.copyWith(duration: v))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickField(String label, String value, Function(String) onEdit) {
    return Expanded(
      child: TextFormField(
        initialValue: value,
        onChanged: onEdit,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10, color: AppColors.textHint),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyMedicinesState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.medication_outlined, size: 48, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('No medicines added yet', style: TextStyle(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
