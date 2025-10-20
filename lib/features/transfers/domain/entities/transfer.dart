import 'package:equatable/equatable.dart';

/// Estados de una transferencia
enum TransferStatus {
  pending,    // Pendiente de envío
  inTransit,  // En tránsito
  completed,  // Completada
  cancelled,  // Cancelada
}

/// Entity que representa una transferencia entre almacenes
class Transfer extends Equatable {
  final String id;
  final String fromStoreId;
  final String fromStoreName;
  final String toStoreId;
  final String toStoreName;
  final String productId;
  final String? variantId;
  final String productName;
  final double qty;
  final TransferStatus status;
  final String authorUserId;
  final String? notes;
  final DateTime requestedAt;
  final DateTime? sentAt;
  final DateTime? receivedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transfer({
    required this.id,
    required this.fromStoreId,
    required this.fromStoreName,
    required this.toStoreId,
    required this.toStoreName,
    required this.productId,
    this.variantId,
    required this.productName,
    required this.qty,
    required this.status,
    required this.authorUserId,
    this.notes,
    required this.requestedAt,
    this.sentAt,
    this.receivedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fromStoreId,
        fromStoreName,
        toStoreId,
        toStoreName,
        productId,
        variantId,
        productName,
        qty,
        status,
        authorUserId,
        notes,
        requestedAt,
        sentAt,
        receivedAt,
        cancelledAt,
        cancellationReason,
        createdAt,
        updatedAt,
      ];

  /// Copia con modificaciones
  Transfer copyWith({
    String? id,
    String? fromStoreId,
    String? fromStoreName,
    String? toStoreId,
    String? toStoreName,
    String? productId,
    String? variantId,
    String? productName,
    double? qty,
    TransferStatus? status,
    String? authorUserId,
    String? notes,
    DateTime? requestedAt,
    DateTime? sentAt,
    DateTime? receivedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transfer(
      id: id ?? this.id,
      fromStoreId: fromStoreId ?? this.fromStoreId,
      fromStoreName: fromStoreName ?? this.fromStoreName,
      toStoreId: toStoreId ?? this.toStoreId,
      toStoreName: toStoreName ?? this.toStoreName,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      qty: qty ?? this.qty,
      status: status ?? this.status,
      authorUserId: authorUserId ?? this.authorUserId,
      notes: notes ?? this.notes,
      requestedAt: requestedAt ?? this.requestedAt,
      sentAt: sentAt ?? this.sentAt,
      receivedAt: receivedAt ?? this.receivedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verificar si está pendiente
  bool get isPending => status == TransferStatus.pending;

  /// Verificar si está en tránsito
  bool get isInTransit => status == TransferStatus.inTransit;

  /// Verificar si está completada
  bool get isCompleted => status == TransferStatus.completed;

  /// Verificar si está cancelada
  bool get isCancelled => status == TransferStatus.cancelled;

  /// Verificar si puede ser enviada
  bool get canBeSent => status == TransferStatus.pending;

  /// Verificar si puede ser recibida
  bool get canBeReceived => status == TransferStatus.inTransit;

  /// Verificar si puede ser cancelada
  bool get canBeCancelled =>
      status == TransferStatus.pending || status == TransferStatus.inTransit;

  /// Obtener el texto del estado
  String get statusText {
    switch (status) {
      case TransferStatus.pending:
        return 'Pendiente';
      case TransferStatus.inTransit:
        return 'En Tránsito';
      case TransferStatus.completed:
        return 'Completada';
      case TransferStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Convertir de string a enum
  static TransferStatus statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransferStatus.pending;
      case 'intransit':
      case 'in_transit':
        return TransferStatus.inTransit;
      case 'completed':
        return TransferStatus.completed;
      case 'cancelled':
        return TransferStatus.cancelled;
      default:
        return TransferStatus.pending;
    }
  }

  /// Convertir de enum a string
  static String statusToString(TransferStatus status) {
    switch (status) {
      case TransferStatus.pending:
        return 'pending';
      case TransferStatus.inTransit:
        return 'in_transit';
      case TransferStatus.completed:
        return 'completed';
      case TransferStatus.cancelled:
        return 'cancelled';
    }
  }
}
