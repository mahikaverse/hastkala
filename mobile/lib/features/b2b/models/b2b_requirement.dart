import 'package:flutter/material.dart';

enum RequirementStatus { draft, active, fulfilled, closed }

class B2BRequirement {
  final String id;
  final String buyerId;
  final String title;
  final String description;
  final String category;
  final String? material;
  final String? craftType;
  final int quantity;
  final double? budgetMin;
  final double? budgetMax;
  final String? deliveryLocation;
  final DateTime? deadline;
  final String? customization;
  final RequirementStatus status;
  final int enquiriesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const B2BRequirement({
    required this.id,
    required this.buyerId,
    required this.title,
    this.description = '',
    this.category = '',
    this.material,
    this.craftType,
    this.quantity = 0,
    this.budgetMin,
    this.budgetMax,
    this.deliveryLocation,
    this.deadline,
    this.customization,
    this.status = RequirementStatus.active,
    this.enquiriesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case RequirementStatus.draft:
        return 'Draft';
      case RequirementStatus.active:
        return 'Active';
      case RequirementStatus.fulfilled:
        return 'Fulfilled';
      case RequirementStatus.closed:
        return 'Closed';
    }
  }

  Color get statusColor {
    switch (status) {
      case RequirementStatus.draft:
        return Colors.grey;
      case RequirementStatus.active:
        return const Color(0xFF4F6530);
      case RequirementStatus.fulfilled:
        return const Color(0xFFB84E2F);
      case RequirementStatus.closed:
        return Colors.grey;
    }
  }

  B2BRequirement copyWith({
    String? title,
    String? description,
    String? category,
    String? material,
    String? craftType,
    int? quantity,
    double? budgetMin,
    double? budgetMax,
    String? deliveryLocation,
    DateTime? deadline,
    String? customization,
    RequirementStatus? status,
    int? enquiriesCount,
  }) {
    return B2BRequirement(
      id: id,
      buyerId: buyerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      material: material ?? this.material,
      craftType: craftType ?? this.craftType,
      quantity: quantity ?? this.quantity,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deadline: deadline ?? this.deadline,
      customization: customization ?? this.customization,
      status: status ?? this.status,
      enquiriesCount: enquiriesCount ?? this.enquiriesCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'title': title,
      'description': description,
      'category': category,
      'material': material,
      'craft_type': craftType,
      'quantity': quantity,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'delivery_location': deliveryLocation,
      'deadline': deadline?.toIso8601String(),
      'customization': customization,
      'status': status.name,
      'enquiries_count': enquiriesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory B2BRequirement.fromMap(Map<String, dynamic> map) {
    return B2BRequirement(
      id: map['id'] ?? '',
      buyerId: map['buyer_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      material: map['material'],
      craftType: map['craft_type'],
      quantity: map['quantity'] ?? 0,
      budgetMin: map['budget_min']?.toDouble(),
      budgetMax: map['budget_max']?.toDouble(),
      deliveryLocation: map['delivery_location'],
      deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline']) : null,
      customization: map['customization'],
      status: RequirementStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RequirementStatus.active,
      ),
      enquiriesCount: map['enquiries_count'] ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
