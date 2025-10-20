import 'package:equatable/equatable.dart';

/// Entidad de dominio para Producto
class Product extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String category;
  final double costPrice;
  final double salePrice;
  final String unit;
  final bool hasVariants;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.category,
    required this.costPrice,
    required this.salePrice,
    required this.unit,
    this.hasVariants = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? category,
    double? costPrice,
    double? salePrice,
    String? unit,
    bool? hasVariants,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      unit: unit ?? this.unit,
      hasVariants: hasVariants ?? this.hasVariants,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  double get profit => salePrice - costPrice;
  double get profitMargin =>
      costPrice > 0 ? ((salePrice - costPrice) / costPrice) * 100 : 0;

  @override
  List<Object?> get props => [
    id,
    sku,
    name,
    description,
    category,
    costPrice,
    salePrice,
    unit,
    hasVariants,
    isActive,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
