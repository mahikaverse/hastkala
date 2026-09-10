class MarketplaceProduct {
  final String id;
  final String storeId;
  final String artisanId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String category;
  final String subcategory;
  final List<String> imageUrls;
  final List<ProductVariant> variants;
  final int stockQuantity;
  final bool isPublished;
  final bool isFeatured;
  final String? craftType;
  final String? material;
  final String? weight;
  final String? dimensions;
  final String? shippingInfo;
  final List<String> tags;
  final double averageRating;
  final int totalReviews;
  final int totalSales;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketplaceProduct({
    required this.id,
    required this.storeId,
    required this.artisanId,
    required this.name,
    this.description = '',
    required this.price,
    this.discountPrice,
    this.category = '',
    this.subcategory = '',
    this.imageUrls = const [],
    this.variants = const [],
    this.stockQuantity = 0,
    this.isPublished = true,
    this.isFeatured = false,
    this.craftType,
    this.material,
    this.weight,
    this.dimensions,
    this.shippingInfo,
    this.tags = const [],
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalSales = 0,
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get effectivePrice => discountPrice ?? price;
  double get discountPercent =>
      discountPrice != null && price > 0
          ? ((price - discountPrice!) / price * 100)
          : 0;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  MarketplaceProduct copyWith({
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? category,
    String? subcategory,
    List<String>? imageUrls,
    List<ProductVariant>? variants,
    int? stockQuantity,
    bool? isPublished,
    bool? isFeatured,
    String? craftType,
    String? material,
    String? weight,
    String? dimensions,
    String? shippingInfo,
    List<String>? tags,
    double? averageRating,
    int? totalReviews,
    int? totalSales,
    int? views,
    DateTime? updatedAt,
  }) {
    return MarketplaceProduct(
      id: id,
      storeId: storeId,
      artisanId: artisanId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrls: imageUrls ?? this.imageUrls,
      variants: variants ?? this.variants,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      craftType: craftType ?? this.craftType,
      material: material ?? this.material,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      tags: tags ?? this.tags,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSales: totalSales ?? this.totalSales,
      views: views ?? this.views,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'artisanId': artisanId,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'category': category,
      'subcategory': subcategory,
      'imageUrls': imageUrls,
      'variants': variants.map((v) => v.toMap()).toList(),
      'stockQuantity': stockQuantity,
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'craftType': craftType,
      'material': material,
      'weight': weight,
      'dimensions': dimensions,
      'shippingInfo': shippingInfo,
      'tags': tags,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalSales': totalSales,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MarketplaceProduct.fromMap(Map<String, dynamic> map) {
    return MarketplaceProduct(
      id: map['id'] ?? '',
      storeId: map['storeId'] ?? '',
      artisanId: map['artisanId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      variants: (map['variants'] as List?)
              ?.map((v) => ProductVariant.fromMap(v))
              .toList() ??
          [],
      stockQuantity: map['stockQuantity'] ?? 0,
      isPublished: map['isPublished'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      craftType: map['craftType'],
      material: map['material'],
      weight: map['weight'],
      dimensions: map['dimensions'],
      shippingInfo: map['shippingInfo'],
      tags: List<String>.from(map['tags'] ?? []),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      totalSales: map['totalSales'] ?? 0,
      views: map['views'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ProductVariant {
  final String id;
  final String name;
  final String type;
  final String value;
  final double? priceModifier;
  final int stockQuantity;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.priceModifier,
    this.stockQuantity = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'priceModifier': priceModifier,
      'stockQuantity': stockQuantity,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      priceModifier: map['priceModifier']?.toDouble(),
      stockQuantity: map['stockQuantity'] ?? 0,
    );
  }
}
