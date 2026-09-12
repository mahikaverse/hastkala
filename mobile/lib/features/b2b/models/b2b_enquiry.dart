import 'package:flutter/material.dart';

enum EnquiryStatus { pending, replied, accepted, rejected, closed }

class B2BEnquiry {
  final String id;
  final String buyerId;
  final String buyerName;
  final String artisanId;
  final String? productId;
  final String? requirementId;
  final String message;
  final int quantity;
  final double? budget;
  final String? deliveryLocation;
  final DateTime? deadline;
  final String? customization;
  final EnquiryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const B2BEnquiry({
    required this.id,
    required this.buyerId,
    this.buyerName = '',
    required this.artisanId,
    this.productId,
    this.requirementId,
    this.message = '',
    this.quantity = 0,
    this.budget,
    this.deliveryLocation,
    this.deadline,
    this.customization,
    this.status = EnquiryStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case EnquiryStatus.pending:
        return 'Pending';
      case EnquiryStatus.replied:
        return 'Replied';
      case EnquiryStatus.accepted:
        return 'Accepted';
      case EnquiryStatus.rejected:
        return 'Rejected';
      case EnquiryStatus.closed:
        return 'Closed';
    }
  }

  Color get statusColor {
    switch (status) {
      case EnquiryStatus.pending:
        return const Color(0xFFC88927);
      case EnquiryStatus.replied:
        return const Color(0xFF4A6FA5);
      case EnquiryStatus.accepted:
        return const Color(0xFF4F6530);
      case EnquiryStatus.rejected:
        return const Color(0xFFB3261E);
      case EnquiryStatus.closed:
        return Colors.grey;
    }
  }

  B2BEnquiry copyWith({
    String? message,
    int? quantity,
    double? budget,
    String? deliveryLocation,
    DateTime? deadline,
    String? customization,
    EnquiryStatus? status,
  }) {
    return B2BEnquiry(
      id: id,
      buyerId: buyerId,
      buyerName: buyerName,
      artisanId: artisanId,
      productId: productId,
      requirementId: requirementId,
      message: message ?? this.message,
      quantity: quantity ?? this.quantity,
      budget: budget ?? this.budget,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deadline: deadline ?? this.deadline,
      customization: customization ?? this.customization,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'artisan_id': artisanId,
      'product_id': productId,
      'requirement_id': requirementId,
      'message': message,
      'quantity': quantity,
      'budget': budget,
      'delivery_location': deliveryLocation,
      'deadline': deadline?.toIso8601String(),
      'customization': customization,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory B2BEnquiry.fromMap(Map<String, dynamic> map) {
    return B2BEnquiry(
      id: map['id'] ?? '',
      buyerId: map['buyer_id'] ?? '',
      buyerName: map['buyer_name'] ?? '',
      artisanId: map['artisan_id'] ?? '',
      productId: map['product_id'],
      requirementId: map['requirement_id'],
      message: map['message'] ?? '',
      quantity: map['quantity'] ?? 0,
      budget: map['budget']?.toDouble(),
      deliveryLocation: map['delivery_location'],
      deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline']) : null,
      customization: map['customization'],
      status: EnquiryStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EnquiryStatus.pending,
      ),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
