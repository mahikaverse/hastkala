import 'package:flutter/material.dart';

enum B2BOrderStatus { enquiry, quote, confirmed, production, ready, shipped, delivered, cancelled }

class B2BOrder {
  final String id;
  final String buyerId;
  final String artisanId;
  final String? productId;
  final String? quoteId;
  final String? enquiryId;
  final String productName;
  final int quantity;
  final double pricePerPiece;
  final double totalAmount;
  final int leadTimeDays;
  final String? deliveryLocation;
  final B2BOrderStatus status;
  final String? artisanMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const B2BOrder({
    required this.id,
    required this.buyerId,
    required this.artisanId,
    this.productId,
    this.quoteId,
    this.enquiryId,
    this.productName = '',
    required this.quantity,
    required this.pricePerPiece,
    required this.totalAmount,
    this.leadTimeDays = 0,
    this.deliveryLocation,
    this.status = B2BOrderStatus.enquiry,
    this.artisanMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case B2BOrderStatus.enquiry:
        return 'Enquiry';
      case B2BOrderStatus.quote:
        return 'Quote';
      case B2BOrderStatus.confirmed:
        return 'Confirmed';
      case B2BOrderStatus.production:
        return 'Production';
      case B2BOrderStatus.ready:
        return 'Ready';
      case B2BOrderStatus.shipped:
        return 'Shipped';
      case B2BOrderStatus.delivered:
        return 'Delivered';
      case B2BOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case B2BOrderStatus.enquiry:
        return const Color(0xFFC88927);
      case B2BOrderStatus.quote:
        return const Color(0xFF4A6FA5);
      case B2BOrderStatus.confirmed:
        return const Color(0xFF4F6530);
      case B2BOrderStatus.production:
        return const Color(0xFFB84E2F);
      case B2BOrderStatus.ready:
        return const Color(0xFF4F6530);
      case B2BOrderStatus.shipped:
        return const Color(0xFF4A6FA5);
      case B2BOrderStatus.delivered:
        return const Color(0xFF4F6530);
      case B2BOrderStatus.cancelled:
        return Colors.grey;
    }
  }

  B2BOrder copyWith({
    int? quantity,
    double? pricePerPiece,
    double? totalAmount,
    int? leadTimeDays,
    String? deliveryLocation,
    B2BOrderStatus? status,
    String? artisanMessage,
  }) {
    return B2BOrder(
      id: id,
      buyerId: buyerId,
      artisanId: artisanId,
      productId: productId,
      quoteId: quoteId,
      enquiryId: enquiryId,
      productName: productName,
      quantity: quantity ?? this.quantity,
      pricePerPiece: pricePerPiece ?? this.pricePerPiece,
      totalAmount: totalAmount ?? this.totalAmount,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      status: status ?? this.status,
      artisanMessage: artisanMessage ?? this.artisanMessage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'artisan_id': artisanId,
      'product_id': productId,
      'quote_id': quoteId,
      'enquiry_id': enquiryId,
      'product_name': productName,
      'quantity': quantity,
      'price_per_piece': pricePerPiece,
      'total_amount': totalAmount,
      'lead_time_days': leadTimeDays,
      'delivery_location': deliveryLocation,
      'status': status.name,
      'artisan_message': artisanMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory B2BOrder.fromMap(Map<String, dynamic> map) {
    return B2BOrder(
      id: map['id'] ?? '',
      buyerId: map['buyer_id'] ?? '',
      artisanId: map['artisan_id'] ?? '',
      productId: map['product_id'],
      quoteId: map['quote_id'],
      enquiryId: map['enquiry_id'],
      productName: map['product_name'] ?? '',
      quantity: map['quantity'] ?? 0,
      pricePerPiece: (map['price_per_piece'] ?? 0).toDouble(),
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      leadTimeDays: map['lead_time_days'] ?? 0,
      deliveryLocation: map['delivery_location'],
      status: B2BOrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => B2BOrderStatus.enquiry,
      ),
      artisanMessage: map['artisan_message'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
