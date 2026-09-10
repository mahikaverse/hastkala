class CartItem {
  final String productId;
  final String storeId;
  final String artisanId;
  final String artisanName;
  final String storeName;
  final String productName;
  final String productImage;
  final double price;
  final double? discountPrice;
  final int quantity;
  final String? selectedVariant;

  const CartItem({
    required this.productId,
    required this.storeId,
    required this.artisanId,
    required this.artisanName,
    required this.storeName,
    required this.productName,
    required this.productImage,
    required this.price,
    this.discountPrice,
    this.quantity = 1,
    this.selectedVariant,
  });

  double get effectivePrice => discountPrice ?? price;
  double get totalPrice => effectivePrice * quantity;

  CartItem copyWith({
    int? quantity,
    String? selectedVariant,
    double? price,
    double? discountPrice,
  }) {
    return CartItem(
      productId: productId,
      storeId: storeId,
      artisanId: artisanId,
      artisanName: artisanName,
      storeName: storeName,
      productName: productName,
      productImage: productImage,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'storeId': storeId,
      'artisanId': artisanId,
      'artisanName': artisanName,
      'storeName': storeName,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'discountPrice': discountPrice,
      'quantity': quantity,
      'selectedVariant': selectedVariant,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      storeId: map['storeId'] ?? '',
      artisanId: map['artisanId'] ?? '',
      artisanName: map['artisanName'] ?? '',
      storeName: map['storeName'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      quantity: map['quantity'] ?? 1,
      selectedVariant: map['selectedVariant'],
    );
  }
}
