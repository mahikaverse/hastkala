enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled, returned }

class MarketplaceOrder {
  final String id;
  final String orderNumber;
  final String buyerId;
  final String storeId;
  final String artisanId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double total;
  final OrderStatus status;
  final String paymentMethod;
  final bool isPaid;
  final String? shippingAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketplaceOrder({
    required this.id,
    required this.orderNumber,
    required this.buyerId,
    required this.storeId,
    required this.artisanId,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0,
    required this.total,
    this.status = OrderStatus.pending,
    this.paymentMethod = '',
    this.isPaid = false,
    this.shippingAddress,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  MarketplaceOrder copyWith({
    OrderStatus? status,
    String? trackingNumber,
    String? notes,
    bool? isPaid,
    DateTime? updatedAt,
  }) {
    return MarketplaceOrder(
      id: id,
      orderNumber: orderNumber,
      buyerId: buyerId,
      storeId: storeId,
      artisanId: artisanId,
      items: items,
      subtotal: subtotal,
      shippingCost: shippingCost,
      total: total,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      shippingAddress: shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'buyerId': buyerId,
      'storeId': storeId,
      'artisanId': artisanId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MarketplaceOrder.fromMap(Map<String, dynamic> map) {
    return MarketplaceOrder(
      id: map['id'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      buyerId: map['buyerId'] ?? '',
      storeId: map['storeId'] ?? '',
      artisanId: map['artisanId'] ?? '',
      items: (map['items'] as List?)
              ?.map((i) => OrderItem.fromMap(i))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingCost: (map['shippingCost'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: map['paymentMethod'] ?? '',
      isPaid: map['isPaid'] ?? false,
      shippingAddress: map['shippingAddress'],
      trackingNumber: map['trackingNumber'],
      notes: map['notes'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? variantName;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage = '',
    required this.price,
    required this.quantity,
    this.variantName,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'variantName': variantName,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      variantName: map['variantName'],
    );
  }
}
