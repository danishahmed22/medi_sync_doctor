import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/features/operations/domain/entities/inventory_item_entity.dart';

class InventoryItemModel {
  const InventoryItemModel({
    required this.itemId,
    required this.name,
    required this.currentStock,
    required this.threshold,
    required this.unit,
    required this.clinicId,
    this.vendorId,
  });

  final String itemId;
  final String name;
  final int currentStock;
  final int threshold;
  final String unit;
  final String clinicId;
  final String? vendorId;

  factory InventoryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItemModel(
      itemId: doc.id,
      name: data['name'] as String? ?? '',
      currentStock: data['currentStock'] as int? ?? 0,
      threshold: data['threshold'] as int? ?? 10,
      unit: data['unit'] as String? ?? 'strips',
      clinicId: data['clinicId'] as String? ?? '',
      vendorId: data['vendorId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'currentStock': currentStock,
      'threshold': threshold,
      'unit': unit,
      'clinicId': clinicId,
      if (vendorId != null) 'vendorId': vendorId,
    };
  }

  InventoryItemEntity toEntity() => InventoryItemEntity(
        itemId: itemId,
        name: name,
        currentStock: currentStock,
        threshold: threshold,
        unit: unit,
        clinicId: clinicId,
        vendorId: vendorId,
      );

  factory InventoryItemModel.fromEntity(InventoryItemEntity entity) => InventoryItemModel(
        itemId: entity.itemId,
        name: entity.name,
        currentStock: entity.currentStock,
        threshold: entity.threshold,
        unit: entity.unit,
        clinicId: entity.clinicId,
        vendorId: entity.vendorId,
      );
}
