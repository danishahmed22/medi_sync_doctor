import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_doctor/core/theme/app_colors.dart';
import 'package:medisync_doctor/features/auth_onboarding/presentation/providers/clinic_provider.dart';
import 'package:medisync_doctor/features/operations/presentation/providers/inventory_provider.dart';
import 'package:medisync_doctor/features/operations/domain/entities/inventory_item_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    final clinic = ref.watch(currentClinicProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory & Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            onPressed: () => _showItemDialog(context, ref, clinic?.clinicId),
          ),
        ],
      ),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No inventory items found. Add your first stock item!'));
          }

          final lowStockItems = items.where((i) => i.isLowStock).toList();

          return Column(
            children: [
              if (lowStockItems.isNotEmpty)
                _buildLowStockAlert(context, lowStockItems, clinic?.clinicName, clinic?.address),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildInventoryTile(context, ref, item);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildLowStockAlert(BuildContext context, List<InventoryItemEntity> lowStockItems, String? clinicName, String? address) {
    final itemNames = lowStockItems.map((i) => i.name).join(', ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text('${lowStockItems.length} Items Low in Stock', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Restock recommended for the items below.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _contactVendor(itemNames, clinicName, address),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Contact Vendor (WhatsApp)'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTile(BuildContext context, WidgetRef ref, InventoryItemEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showItemDialog(context, ref, item.clinicId, existingItem: item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.isLowStock ? AppColors.error.withOpacity(0.3) : AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Stock: ${item.currentStock} ${item.unit}',
                        style: TextStyle(color: item.isLowStock ? AppColors.error : AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    if (item.isLowStock)
                      const Icon(Icons.error_outline_rounded, color: AppColors.error)
                    else
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit_note_rounded, color: AppColors.textHint, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _contactVendor(String items, String? clinicName, String? address) async {
    final message = Uri.encodeComponent(
      'Hello, I need to restock the following medicines:\n\n'
      '$items\n\n'
      'Clinic: ${clinicName ?? "MediSync Clinic"}\n'
      'Address: ${address ?? ""}\n'
      'Please confirm availability.'
    );
    final url = Uri.parse('https://wa.me/919876543210?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showItemDialog(BuildContext context, WidgetRef ref, String? clinicId, {InventoryItemEntity? existingItem}) {
    if (clinicId == null) return;

    final nameCtrl = TextEditingController(text: existingItem?.name);
    final stockCtrl = TextEditingController(text: existingItem?.currentStock.toString() ?? '0');
    final thresholdCtrl = TextEditingController(text: existingItem?.threshold.toString() ?? '10');
    final unitCtrl = TextEditingController(text: existingItem?.unit ?? 'Strips');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(existingItem == null ? 'Add Stock Item' : 'Edit Stock Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicine Name')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Current Stock'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: thresholdCtrl, decoration: const InputDecoration(labelText: 'Min Threshold'), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (Strips, Bottles, etc.)')),
            ],
          ),
        ),
        actions: [
          if (existingItem != null)
            TextButton(
              onPressed: () async {
                await ref.read(inventoryRepositoryProvider).deleteItem(existingItem.itemId);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                final item = InventoryItemEntity(
                  itemId: existingItem?.itemId ?? '',
                  name: nameCtrl.text,
                  currentStock: int.tryParse(stockCtrl.text) ?? 0,
                  threshold: int.tryParse(thresholdCtrl.text) ?? 10,
                  unit: unitCtrl.text,
                  clinicId: clinicId,
                );

                if (existingItem == null) {
                  await ref.read(inventoryRepositoryProvider).addItem(item);
                } else {
                  await ref.read(inventoryRepositoryProvider).updateItem(item);
                }
                Navigator.pop(context);
              }
            },
            child: Text(existingItem == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
