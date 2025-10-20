/// Entidad que representa un ajuste de inventario
class InventoryAdjustment {
  final String id;
  final String inventoryId;
  final String userId;
  final String type; // 'increment', 'decrement', 'set'
  final double previousQty;
  final double adjustmentQty;
  final double newQty;
  final String? reason;
  final String? notes;
  final DateTime createdAt;

  const InventoryAdjustment({
    required this.id,
    required this.inventoryId,
    required this.userId,
    required this.type,
    required this.previousQty,
    required this.adjustmentQty,
    required this.newQty,
    this.reason,
    this.notes,
    required this.createdAt,
  });

  InventoryAdjustment copyWith({
    String? id,
    String? inventoryId,
    String? userId,
    String? type,
    double? previousQty,
    double? adjustmentQty,
    double? newQty,
    String? reason,
    String? notes,
    DateTime? createdAt,
  }) {
    return InventoryAdjustment(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      previousQty: previousQty ?? this.previousQty,
      adjustmentQty: adjustmentQty ?? this.adjustmentQty,
      newQty: newQty ?? this.newQty,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InventoryAdjustment &&
        other.id == id &&
        other.inventoryId == inventoryId &&
        other.userId == userId &&
        other.type == type &&
        other.previousQty == previousQty &&
        other.adjustmentQty == adjustmentQty &&
        other.newQty == newQty &&
        other.reason == reason &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        inventoryId.hashCode ^
        userId.hashCode ^
        type.hashCode ^
        previousQty.hashCode ^
        adjustmentQty.hashCode ^
        newQty.hashCode ^
        reason.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'InventoryAdjustment(id: $id, type: $type, adjustment: $adjustmentQty)';
  }
}
