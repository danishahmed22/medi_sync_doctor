import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/staff_management/data/repositories_impl/staff_management_repository_impl.dart';
import 'package:medisync_doctor/features/staff_management/domain/entities/activity_log_entity.dart';
import 'package:medisync_doctor/features/staff_management/domain/repositories/staff_management_repository.dart';

final staffManagementRepositoryProvider = Provider<StaffManagementRepository>((ref) {
  return StaffManagementRepositoryImpl(FirebaseFirestore.instance);
});

final staffActivityStreamProvider = StreamProvider.autoDispose<List<ActivityLogEntity>>((ref) {
  final clinic = ref.watch(currentClinicProvider).value;
  if (clinic == null) return Stream.value([]);
  
  return ref.read(staffManagementRepositoryProvider).watchStaffActivity(clinic.clinicId);
});

final staffPerformanceStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final clinic = ref.watch(currentClinicProvider).value;
  if (clinic == null) return {'totalActions': 0, 'activeStaff': 0, 'exceptions': 0};
  
  // We trigger a refresh when logs change
  ref.watch(staffActivityStreamProvider);
  
  return ref.read(staffManagementRepositoryProvider).getStaffPerformanceStats(clinic.clinicId);
});
