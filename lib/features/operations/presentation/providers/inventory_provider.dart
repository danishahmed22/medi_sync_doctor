import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/operations/data/repositories_impl/inventory_repository_impl.dart';
import 'package:medisync_doctor/features/operations/domain/entities/inventory_item_entity.dart';

final inventoryRepositoryProvider = Provider<InventoryRepositoryImpl>((ref) {
  return InventoryRepositoryImpl(FirebaseFirestore.instance);
});

final inventoryStreamProvider = StreamProvider.autoDispose<List<InventoryItemEntity>>((ref) {
  final clinic = ref.watch(currentClinicProvider).value;
  if (clinic == null) return Stream.value([]);
  
  return ref.read(inventoryRepositoryProvider).watchInventory(clinic.clinicId);
});
