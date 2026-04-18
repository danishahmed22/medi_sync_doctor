import 'package:equatable/equatable.dart';

class InventoryItemEntity extends Equatable {
  const InventoryItemEntity({
    required this.itemId,
    required this.name,
    required this.currentStock,
    required this.threshold,
    required this.unit, // e.g., 'strips', 'bottles'
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

  bool get isLowStock => currentStock <= threshold;
  bool get isOutOfStock => currentStock == 0;

  @override
  List<Object?> get props => [itemId, name, currentStock, threshold, unit, clinicId, vendorId];

  InventoryItemEntity copyWith({
    String? itemId,
    String? name,
    int? currentStock,
    int? threshold,
    String? unit,
    String? clinicId,
    String? vendorId,
  }) {
    return InventoryItemEntity(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      currentStock: currentStock ?? this.currentStock,
      threshold: threshold ?? this.threshold,
      unit: unit ?? this.unit,
      clinicId: clinicId ?? this.clinicId,
      vendorId: vendorId ?? this.vendorId,
    );
  }
}
