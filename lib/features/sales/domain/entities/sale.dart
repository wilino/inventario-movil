/// Entidad que representa una venta
class Sale {
  final String id;
  final String storeId;
  final String? authorUserId;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? customer;
  final String? notes;
  final DateTime at;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Sale({
    required this.id,
    required this.storeId,
    this.authorUserId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    this.customer,
    this.notes,
    required this.at,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Calcula el total basado en items, descuento e impuesto
  static double calculateTotal(
    List<SaleItem> items,
    double discount,
    double tax,
  ) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final afterDiscount = subtotal - discount;
    return afterDiscount + (afterDiscount * tax / 100);
  }

  /// Número de items en la venta
  int get itemCount =>
      items.fold<int>(0, (sum, item) => sum + item.qty.toInt());

  Sale copyWith({
    String? id,
    String? storeId,
    String? authorUserId,
    List<SaleItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? customer,
    String? notes,
    DateTime? at,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Sale(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      authorUserId: authorUserId ?? this.authorUserId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      customer: customer ?? this.customer,
      notes: notes ?? this.notes,
      at: at ?? this.at,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sale &&
        other.id == id &&
        other.storeId == storeId &&
        other.total == total;
  }

  @override
  int get hashCode => id.hashCode ^ storeId.hashCode ^ total.hashCode;

  @override
  String toString() {
    return 'Sale(id: $id, total: $total, items: ${items.length})';
  }
}

/// Entidad que representa un item de una venta
class SaleItem {
  final String productId;
  final String? variantId;
  final String productName;
  final double qty;
  final double unitPrice;
  final double total;

  const SaleItem({
    required this.productId,
    this.variantId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.total,
  });

  SaleItem copyWith({
    String? productId,
    String? variantId,
    String? productName,
    double? qty,
    double? unitPrice,
    double? total,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SaleItem &&
        other.productId == productId &&
        other.variantId == variantId &&
        other.qty == qty;
  }

  @override
  int get hashCode => productId.hashCode ^ variantId.hashCode ^ qty.hashCode;

  @override
  String toString() {
    return 'SaleItem(product: $productName, qty: $qty, total: $total)';
  }
}
