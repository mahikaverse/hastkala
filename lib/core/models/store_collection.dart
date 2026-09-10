class StoreCollection {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> productIds;
  final int sortOrder;
  final bool isFeatured;
  final DateTime createdAt;

  const StoreCollection({
    required this.id,
    required this.storeId,
    required this.name,
    this.description = '',
    this.imageUrl,
    this.productIds = const [],
    this.sortOrder = 0,
    this.isFeatured = false,
    required this.createdAt,
  });

  StoreCollection copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<String>? productIds,
    int? sortOrder,
    bool? isFeatured,
  }) {
    return StoreCollection(
      id: id,
      storeId: storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      productIds: productIds ?? this.productIds,
      sortOrder: sortOrder ?? this.sortOrder,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'productIds': productIds,
      'sortOrder': sortOrder,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StoreCollection.fromMap(Map<String, dynamic> map) {
    return StoreCollection(
      id: map['id'] ?? '',
      storeId: map['storeId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      productIds: List<String>.from(map['productIds'] ?? []),
      sortOrder: map['sortOrder'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
