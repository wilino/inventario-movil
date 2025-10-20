import 'package:equatable/equatable.dart';

/// Entity que representa una compra a proveedor
class Purchase extends Equatable {
  final String id;
  final String storeId;
  final String supplierId;
  final String supplierName;
  final String authorUserId;
  final List<PurchaseItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? invoiceNumber;
  final String? notes;
  final DateTime at;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Purchase({
    required this.id,
    required this.storeId,
    required this.supplierId,
    required this.supplierName,
    required this.authorUserId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    this.invoiceNumber,
    this.notes,
    required this.at,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  @override
  List<Object?> get props => [
        id,
        storeId,
        supplierId,
        supplierName,
        authorUserId,
        items,
        subtotal,
        discount,
        tax,
        total,
        invoiceNumber,
        notes,
        at,
        createdAt,
        updatedAt,
        isDeleted,
      ];

  /// Calcula el total de una compra
  static double calculateTotal(
    List<PurchaseItem> items,
    double discount,
    double tax,
  ) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final afterDiscount = subtotal - discount;
    return afterDiscount + (afterDiscount * tax / 100);
  }

  /// Retorna el número total de items en la compra
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.qty.toInt());

  Purchase copyWith({
    String? id,
    String? storeId,
    String? supplierId,
    String? supplierName,
    String? authorUserId,
    List<PurchaseItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? invoiceNumber,
    String? notes,
    DateTime? at,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Purchase(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      authorUserId: authorUserId ?? this.authorUserId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
      at: at ?? this.at,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

/// Entity que representa un item de compra
class PurchaseItem extends Equatable {
  final String productId;
  final String? variantId;
  final String productName;
  final double qty;
  final double unitCost;
  final double total;

  const PurchaseItem({
    required this.productId,
    this.variantId,
    required this.productName,
    required this.qty,
    required this.unitCost,
    required this.total,
  });

  @override
  List<Object?> get props => [
        productId,
        variantId,
        productName,
        qty,
        unitCost,
        total,
      ];

  PurchaseItem copyWith({
    String? productId,
    String? variantId,
    String? productName,
    double? qty,
    double? unitCost,
    double? total,
  }) {
    return PurchaseItem(
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      qty: qty ?? this.qty,
      unitCost: unitCost ?? this.unitCost,
      total: total ?? this.total,
    );
  }
}
