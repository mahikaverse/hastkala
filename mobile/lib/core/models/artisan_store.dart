class ArtisanStore {
  final String id;
  final String artisanId;
  final String name;
  final String slug;
  final String description;
  final String logoUrl;
  final String bannerUrl;
  final String craftCategory;
  final String location;
  final String state;
  final double averageRating;
  final int totalReviews;
  final int totalProducts;
  final int totalSales;
  final int totalFollowers;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArtisanStore({
    required this.id,
    required this.artisanId,
    required this.name,
    required this.slug,
    this.description = '',
    this.logoUrl = '',
    this.bannerUrl = '',
    this.craftCategory = '',
    this.location = '',
    this.state = '',
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalProducts = 0,
    this.totalSales = 0,
    this.totalFollowers = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  ArtisanStore copyWith({
    String? name,
    String? slug,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? craftCategory,
    String? location,
    String? state,
    double? averageRating,
    int? totalReviews,
    int? totalProducts,
    int? totalSales,
    int? totalFollowers,
    bool? isVerified,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return ArtisanStore(
      id: id,
      artisanId: artisanId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      craftCategory: craftCategory ?? this.craftCategory,
      location: location ?? this.location,
      state: state ?? this.state,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalProducts: totalProducts ?? this.totalProducts,
      totalSales: totalSales ?? this.totalSales,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artisanId': artisanId,
      'name': name,
      'slug': slug,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'craftCategory': craftCategory,
      'location': location,
      'state': state,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalProducts': totalProducts,
      'totalSales': totalSales,
      'totalFollowers': totalFollowers,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ArtisanStore.fromMap(Map<String, dynamic> map) {
    return ArtisanStore(
      id: map['id'] ?? '',
      artisanId: map['artisanId'] ?? '',
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      craftCategory: map['craftCategory'] ?? '',
      location: map['location'] ?? '',
      state: map['state'] ?? '',
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      totalProducts: map['totalProducts'] ?? 0,
      totalSales: map['totalSales'] ?? 0,
      totalFollowers: map['totalFollowers'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static String generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
