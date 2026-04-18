import 'package:equatable/equatable.dart';

class SyncActionEntity extends Equatable {
  const SyncActionEntity({
    required this.id,
    required this.actionType, // "CREATE_TOKEN" | "SAVE_PRESCRIPTION" | "UPDATE_STOCK"
    required this.payload,
    required this.status, // "pending" | "synced" | "failed"
    this.retryCount = 0,
    required this.createdAt,
  });

  final String id;
  final String actionType;
  final Map<String, dynamic> payload;
  final String status;
  final int retryCount;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, actionType, payload, status, retryCount, createdAt];

  SyncActionEntity copyWith({
    String? id,
    String? actionType,
    Map<String, dynamic>? payload,
    String? status,
    int? retryCount,
    DateTime? createdAt,
  }) {
    return SyncActionEntity(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
