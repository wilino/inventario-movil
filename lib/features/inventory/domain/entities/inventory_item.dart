/// Entidad que representa un registro de inventario
class InventoryItem {
  final String id;
  final String storeId;
  final String productId;
  final String? variantId;
  final double stockQty;
  final double minQty;
  final double maxQty;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.storeId,
    required this.productId,
    this.variantId,
    required this.stockQty,
    required this.minQty,
    required this.maxQty,
    required this.updatedAt,
  });

  /// Verifica si el stock está bajo el mínimo
  bool get isLowStock => stockQty <= minQty;

  /// Verifica si el stock está sobre el máximo
  bool get isOverStock => stockQty >= maxQty;

  /// Verifica si el stock está agotado
  bool get isOutOfStock => stockQty <= 0;

  /// Verifica si el stock está en nivel óptimo
  bool get isOptimalStock => stockQty > minQty && stockQty < maxQty;

  /// Porcentaje de utilización del stock
  double get stockPercentage {
    if (maxQty == 0) return 0;
    return (stockQty / maxQty).clamp(0.0, 1.0);
  }

  InventoryItem copyWith({
    String? id,
    String? storeId,
    String? productId,
    String? variantId,
    double? stockQty,
    double? minQty,
    double? maxQty,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      stockQty: stockQty ?? this.stockQty,
      minQty: minQty ?? this.minQty,
      maxQty: maxQty ?? this.maxQty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InventoryItem &&
        other.id == id &&
        other.storeId == storeId &&
        other.productId == productId &&
        other.variantId == variantId &&
        other.stockQty == stockQty &&
        other.minQty == minQty &&
        other.maxQty == maxQty &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        storeId.hashCode ^
        productId.hashCode ^
        variantId.hashCode ^
        stockQty.hashCode ^
        minQty.hashCode ^
        maxQty.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, storeId: $storeId, productId: $productId, stockQty: $stockQty)';
  }
}
