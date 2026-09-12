import 'package:flutter/material.dart';

enum QuoteStatus { pending, accepted, rejected, expired }

class B2BQuote {
  final String id;
  final String enquiryId;
  final String artisanId;
  final int quantity;
  final double pricePerPiece;
  final int leadTimeDays;
  final String message;
  final QuoteStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const B2BQuote({
    required this.id,
    required this.enquiryId,
    required this.artisanId,
    required this.quantity,
    required this.pricePerPiece,
    this.leadTimeDays = 0,
    this.message = '',
    this.status = QuoteStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalPrice => quantity * pricePerPiece;

  String get statusLabel {
    switch (status) {
      case QuoteStatus.pending:
        return 'Pending';
      case QuoteStatus.accepted:
        return 'Accepted';
      case QuoteStatus.rejected:
        return 'Rejected';
      case QuoteStatus.expired:
        return 'Expired';
    }
  }

  Color get statusColor {
    switch (status) {
      case QuoteStatus.pending:
        return const Color(0xFFC88927);
      case QuoteStatus.accepted:
        return const Color(0xFF4F6530);
      case QuoteStatus.rejected:
        return const Color(0xFFB3261E);
      case QuoteStatus.expired:
        return Colors.grey;
    }
  }

  B2BQuote copyWith({
    int? quantity,
    double? pricePerPiece,
    int? leadTimeDays,
    String? message,
    QuoteStatus? status,
  }) {
    return B2BQuote(
      id: id,
      enquiryId: enquiryId,
      artisanId: artisanId,
      quantity: quantity ?? this.quantity,
      pricePerPiece: pricePerPiece ?? this.pricePerPiece,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enquiry_id': enquiryId,
      'artisan_id': artisanId,
      'quantity': quantity,
      'price_per_piece': pricePerPiece,
      'lead_time_days': leadTimeDays,
      'message': message,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory B2BQuote.fromMap(Map<String, dynamic> map) {
    return B2BQuote(
      id: map['id'] ?? '',
      enquiryId: map['enquiry_id'] ?? '',
      artisanId: map['artisan_id'] ?? '',
      quantity: map['quantity'] ?? 0,
      pricePerPiece: (map['price_per_piece'] ?? 0).toDouble(),
      leadTimeDays: map['lead_time_days'] ?? 0,
      message: map['message'] ?? '',
      status: QuoteStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => QuoteStatus.pending,
      ),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
