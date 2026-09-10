class Review {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerAvatar;
  final String storeId;
  final String? productId;
  final String? orderId;
  final double rating;
  final String comment;
  final String? sellerReply;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    this.buyerAvatar = '',
    required this.storeId,
    this.productId,
    this.orderId,
    required this.rating,
    this.comment = '',
    this.sellerReply,
    required this.createdAt,
  });

  Review copyWith({
    String? comment,
    double? rating,
    String? sellerReply,
  }) {
    return Review(
      id: id,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerAvatar: buyerAvatar,
      storeId: storeId,
      productId: productId,
      orderId: orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      sellerReply: sellerReply ?? this.sellerReply,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerAvatar': buyerAvatar,
      'storeId': storeId,
      'productId': productId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'sellerReply': sellerReply,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerAvatar: map['buyerAvatar'] ?? '',
      storeId: map['storeId'] ?? '',
      productId: map['productId'],
      orderId: map['orderId'],
      rating: (map['rating'] ?? 5.0).toDouble(),
      comment: map['comment'] ?? '',
      sellerReply: map['sellerReply'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
