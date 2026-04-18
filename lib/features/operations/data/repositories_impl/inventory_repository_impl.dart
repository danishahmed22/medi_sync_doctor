import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_doctor/core/constants/app_constants.dart';
import 'package:medisync_doctor/features/operations/data/models/inventory_item_model.dart';
import 'package:medisync_doctor/features/operations/domain/entities/inventory_item_entity.dart';

class InventoryRepositoryImpl {
  InventoryRepositoryImpl(this._db);
  final FirebaseFirestore _db;

  Stream<List<InventoryItemEntity>> watchInventory(String clinicId) {
    return _db
        .collection(FirestoreCollections.inventory)
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => InventoryItemModel.fromFirestore(doc).toEntity())
            .toList());
  }

  Future<void> updateStock(String itemId, int newQuantity) async {
    await _db
        .collection(FirestoreCollections.inventory)
        .doc(itemId)
        .update({'currentStock': newQuantity});
  }

  Future<void> addItem(InventoryItemEntity item) async {
    final ref = _db.collection(FirestoreCollections.inventory).doc();
    final model = InventoryItemModel.fromEntity(item.copyWith(itemId: ref.id));
    await ref.set(model.toFirestore());
  }

  Future<void> updateItem(InventoryItemEntity item) async {
    final model = InventoryItemModel.fromEntity(item);
    await _db
        .collection(FirestoreCollections.inventory)
        .doc(item.itemId)
        .update(model.toFirestore());
  }

  Future<void> deleteItem(String itemId) async {
    await _db.collection(FirestoreCollections.inventory).doc(itemId).delete();
  }
}
