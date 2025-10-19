import 'package:equatable/equatable.dart';

/// Entidad de Producto en el dominio
class Product extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? sku;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.sku,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? sku,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    sku,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}
