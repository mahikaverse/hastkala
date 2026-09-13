class ListingData {
  final String productId;
  final String productName;
  String title;
  String description;
  List<String> bulletPoints;
  List<String> keywords;
  String category;
  String material;
  String craftType;
  String color;
  String size;
  String weight;
  String dimensions;
  double price;
  double mrp;
  int stockQuantity;
  String brand;
  List<String> missingFields;

  ListingData({
    required this.productId,
    required this.productName,
    this.title = '',
    this.description = '',
    this.bulletPoints = const [],
    this.keywords = const [],
    this.category = '',
    this.material = '',
    this.craftType = '',
    this.color = '',
    this.size = '',
    this.weight = '',
    this.dimensions = '',
    this.price = 0,
    this.mrp = 0,
    this.stockQuantity = 0,
    this.brand = 'HastKala Artisan',
    this.missingFields = const [],
  });

  bool get isReady => missingFields.isEmpty;

  int get missingCount => missingFields.length;

  Map<String, String> toExportRow() {
    return {
      'Product Name': productName,
      'Title': title,
      'Description': description,
      'Bullet Points': bulletPoints.join(' | '),
      'Keywords': keywords.join(', '),
      'Category': category,
      'Material': material,
      'Craft Type': craftType,
      'Color': color,
      'Size': size,
      'Weight': weight,
      'Dimensions': dimensions,
      'Price': '₹${price.toInt()}',
      'MRP': '₹${mrp.toInt()}',
      'Stock': '$stockQuantity',
      'Brand': brand,
    };
  }

  ListingData copyWith({
    String? title,
    String? description,
    List<String>? bulletPoints,
    List<String>? keywords,
    String? category,
    String? material,
    String? craftType,
    String? color,
    String? size,
    String? weight,
    String? dimensions,
    double? price,
    double? mrp,
    int? stockQuantity,
    String? brand,
    List<String>? missingFields,
  }) {
    return ListingData(
      productId: productId,
      productName: productName,
      title: title ?? this.title,
      description: description ?? this.description,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      keywords: keywords ?? this.keywords,
      category: category ?? this.category,
      material: material ?? this.material,
      craftType: craftType ?? this.craftType,
      color: color ?? this.color,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      brand: brand ?? this.brand,
      missingFields: missingFields ?? this.missingFields,
    );
  }
}
