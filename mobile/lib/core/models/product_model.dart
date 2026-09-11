class Product {
  final int id;
  final String name;
  final int price;
  final int? oldPrice;
  final String category;
  final String artisan;
  final String location;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final int stock;
  final String status;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.oldPrice,
    required this.category,
    required this.artisan,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.description,
    required this.tags,
    required this.stock,
    this.status = 'Published',
  });
}

class ArtisanProduct {
  final Product product;
  final String status; // Published, Draft, Needs Review
  final int views;
  final int orders;
  final int completionPercent;
  final List<String> missingFields;

  const ArtisanProduct({
    required this.product,
    required this.status,
    required this.views,
    required this.orders,
    this.completionPercent = 100,
    this.missingFields = const [],
  });
}

class MockArtisanProducts {
  MockArtisanProducts._();

  static final List<ArtisanProduct> all = [
    ArtisanProduct(
      product: const Product(
        id: 101,
        name: 'Terracotta Decorative Pot',
        price: 999,
        category: 'Home Decor',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 4.7,
        reviews: 89,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: 'Hand-painted terracotta pot with traditional Rajasthani motifs.',
        tags: ['Terracotta', 'Handmade', 'Pottery', 'Rajasthan'],
        stock: 23,
      ),
      status: 'Published',
      views: 126,
      orders: 14,
    ),
    ArtisanProduct(
      product: const Product(
        id: 102,
        name: 'Blue Pottery Bowl',
        price: 749,
        category: 'Kitchen',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 0,
        reviews: 0,
        imageUrl: 'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?w=400&h=400&fit=crop',
        description: '',
        tags: ['Blue Pottery', 'Handmade'],
        stock: 0,
      ),
      status: 'Draft',
      views: 42,
      orders: 0,
      completionPercent: 70,
      missingFields: ['Product description', 'Price'],
    ),
    ArtisanProduct(
      product: const Product(
        id: 103,
        name: 'Hand-painted Clay Vase',
        price: 1299,
        category: 'Home Decor',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 4.8,
        reviews: 112,
        imageUrl: 'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?w=400&h=400&fit=crop',
        description: 'Elegant hand-painted vase with floral patterns.',
        tags: ['Pottery', 'Vase', 'Handmade', 'Home Decor'],
        stock: 15,
      ),
      status: 'Published',
      views: 183,
      orders: 21,
    ),
    ArtisanProduct(
      product: const Product(
        id: 104,
        name: 'Traditional Terracotta Diya Set',
        price: 499,
        category: 'Festive',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 0,
        reviews: 0,
        imageUrl: 'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=400&h=400&fit=crop',
        description: '',
        tags: ['Terracotta', 'Diya', 'Festive'],
        stock: 0,
      ),
      status: 'Needs Review',
      views: 68,
      orders: 7,
      completionPercent: 90,
      missingFields: ['Product photos'],
    ),
    ArtisanProduct(
      product: const Product(
        id: 105,
        name: 'Terracotta Garden Planter',
        price: 649,
        category: 'Home Decor',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 4.5,
        reviews: 34,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: 'Rustic terracotta planter for indoor and outdoor use.',
        tags: ['Terracotta', 'Planter', 'Garden', 'Handmade'],
        stock: 20,
      ),
      status: 'Published',
      views: 97,
      orders: 9,
    ),
    ArtisanProduct(
      product: const Product(
        id: 106,
        name: 'Hand-painted Water Bottle',
        price: 599,
        category: 'Kitchen',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 0,
        reviews: 0,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: '',
        tags: ['Pottery', 'Bottle', 'Handmade'],
        stock: 0,
      ),
      status: 'Draft',
      views: 12,
      orders: 0,
      completionPercent: 40,
      missingFields: ['Product description', 'Price', 'Product photos'],
    ),
    ArtisanProduct(
      product: const Product(
        id: 107,
        name: 'Terracotta Candle Holder',
        price: 399,
        category: 'Home Decor',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 4.6,
        reviews: 56,
        imageUrl: 'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=400&h=400&fit=crop',
        description: 'Elegant terracotta candle holder with carved patterns.',
        tags: ['Terracotta', 'Candle Holder', 'Handmade'],
        stock: 30,
      ),
      status: 'Published',
      views: 145,
      orders: 18,
    ),
    ArtisanProduct(
      product: const Product(
        id: 108,
        name: 'Clay Spice Box',
        price: 899,
        category: 'Kitchen',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 0,
        reviews: 0,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: '',
        tags: ['Clay', 'Spice Box', 'Kitchen'],
        stock: 0,
      ),
      status: 'Draft',
      views: 28,
      orders: 0,
      completionPercent: 55,
      missingFields: ['Product description', 'Category'],
    ),
    ArtisanProduct(
      product: const Product(
        id: 109,
        name: 'Terracotta Serving Bowl',
        price: 749,
        category: 'Kitchen',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 4.4,
        reviews: 42,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: 'Large terracotta serving bowl for traditional meals.',
        tags: ['Terracotta', 'Serving Bowl', 'Kitchen', 'Handmade'],
        stock: 12,
      ),
      status: 'Published',
      views: 88,
      orders: 11,
    ),
    ArtisanProduct(
      product: const Product(
        id: 110,
        name: 'Handmade Clay Ganesha',
        price: 1199,
        category: 'Festive',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 4.9,
        reviews: 67,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: 'Beautifully handcrafted Ganesha idol from terracotta clay.',
        tags: ['Clay', 'Ganesha', 'Festive', 'Handmade'],
        stock: 8,
      ),
      status: 'Published',
      views: 201,
      orders: 25,
    ),
    ArtisanProduct(
      product: const Product(
        id: 111,
        name: 'Terracotta Jug',
        price: 549,
        category: 'Kitchen',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 0,
        reviews: 0,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: '',
        tags: ['Terracotta', 'Jug', 'Kitchen'],
        stock: 0,
      ),
      status: 'Needs Review',
      views: 15,
      orders: 0,
      completionPercent: 85,
      missingFields: ['Craft story'],
    ),
    ArtisanProduct(
      product: const Product(
        id: 112,
        name: 'Decorative Terracotta Plate',
        price: 899,
        category: 'Home Decor',
        artisan: 'Sita Devi',
        location: 'Jaipur, Rajasthan',
        rating: 4.7,
        reviews: 38,
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
        description: 'Hand-painted decorative plate with traditional motifs.',
        tags: ['Terracotta', 'Plate', 'Home Decor', 'Handmade'],
        stock: 10,
      ),
      status: 'Published',
      views: 112,
      orders: 13,
    ),
  ];

  static int get totalProducts => all.length;
  static int get publishedCount => all.where((p) => p.status == 'Published').length;
  static int get draftCount => all.where((p) => p.status == 'Draft').length;
  static int get reviewCount => all.where((p) => p.status == 'Needs Review').length;

  static List<ArtisanProduct> byStatus(String status) {
    if (status == 'All') return all;
    return all.where((p) => p.status == status).toList();
  }

  static List<ArtisanProduct> search(String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((p) =>
      p.product.name.toLowerCase().contains(q) ||
      p.product.category.toLowerCase().contains(q) ||
      p.product.tags.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }

  static void addProduct(ArtisanProduct p) {
    all.removeWhere((item) => item.product.id == p.product.id);
    all.insert(0, p);
  }
}

class MockProducts {
  MockProducts._();

  static void addProduct(Product p) {
    all.removeWhere((item) => item.id == p.id);
    all.insert(0, p);
  }

  static const String _unsplashBase = 'https://images.unsplash.com';

  static final List<Product> all = [
    Product(
      id: 1,
      name: 'Handwoven Tote Bag',
      price: 1299,
      oldPrice: 1599,
      category: 'Textiles',
      artisan: 'Ravi Kumar',
      location: 'Jaipur, Rajasthan',
      rating: 4.5,
      reviews: 128,
      imageUrl: '$_unsplashBase/photo-1590874103328-eac38ef682fc?w=400&h=400&fit=crop',
      description: 'Handcrafted tote bag made by skilled artisans using traditional weaving techniques from Jaipur.',
      tags: ['Handmade', 'Textiles', 'Jaipur', 'EcoFriendly'],
      stock: 15,
    ),
    Product(
      id: 2,
      name: 'Terracotta Decorative Pot',
      price: 899,
      oldPrice: null,
      category: 'Pottery',
      artisan: 'Sita Devi',
      location: 'Blue Pottery, Jaipur',
      rating: 4.7,
      reviews: 89,
      imageUrl: '$_unsplashBase/photo-1565193566173-7a0ee3dbe261?w=400&h=400&fit=crop',
      description: 'Beautiful terracotta pot hand-painted with traditional Indian motifs by skilled craftsmen.',
      tags: ['Terracotta', 'Handmade', 'Pottery', 'Rajasthan'],
      stock: 23,
    ),
    Product(
      id: 3,
      name: 'Block Print Kurti',
      price: 1499,
      oldPrice: 1799,
      category: 'Textiles',
      artisan: 'Anita Sharma',
      location: 'Bagru, Rajasthan',
      rating: 4.3,
      reviews: 201,
      imageUrl: '$_unsplashBase/photo-1583391733956-6c78276477e2?w=400&h=400&fit=crop',
      description: 'Elegant block print kurti featuring traditional Rajasthani patterns on pure cotton.',
      tags: ['BlockPrint', 'Textiles', 'Kurti', 'Rajasthan'],
      stock: 8,
    ),
    Product(
      id: 4,
      name: 'Wooden Wall Art',
      price: 2499,
      oldPrice: null,
      category: 'Woodwork',
      artisan: 'Ramesh Ji',
      location: 'Saharanpur, UP',
      rating: 4.8,
      reviews: 67,
      imageUrl: '$_unsplashBase/photo-1582561833406-b5cf8b6e381f?w=400&h=400&fit=crop',
      description: 'Intricately carved wooden wall art showcasing traditional Indian craftsmanship.',
      tags: ['Woodwork', 'WallArt', 'Handcrafted', 'Saharanpur'],
      stock: 5,
    ),
    Product(
      id: 5,
      name: 'Terracotta Lamp',
      price: 799,
      oldPrice: 999,
      category: 'Pottery',
      artisan: 'Gopal Lal',
      location: 'Moradabad, UP',
      rating: 4.4,
      reviews: 156,
      imageUrl: '$_unsplashBase/photo-1513519245088-0e12902e35ca?w=400&h=400&fit=crop',
      description: 'Traditional terracotta lamp with hand-painted designs, perfect for home decor.',
      tags: ['Terracotta', 'Lamp', 'Handmade', 'HomeDecor'],
      stock: 30,
    ),
    Product(
      id: 6,
      name: 'Handmade Jute Bag',
      price: 999,
      oldPrice: null,
      category: 'Textiles',
      artisan: 'Kamla Devi',
      location: 'Bihar',
      rating: 4.2,
      reviews: 94,
      imageUrl: '$_unsplashBase/photo-1590874103328-eac38ef682fc?w=400&h=400&fit=crop',
      description: 'Eco-friendly jute bag with beautiful hand embroidery by rural women artisans.',
      tags: ['Jute', 'Handmade', 'EcoFriendly', 'Bihar'],
      stock: 42,
    ),
    Product(
      id: 7,
      name: 'Blue Pottery Vase',
      price: 1199,
      oldPrice: 1499,
      category: 'Pottery',
      artisan: 'Gopal Lal',
      location: 'Jaipur, Rajasthan',
      rating: 4.6,
      reviews: 112,
      imageUrl: '$_unsplashBase/photo-1612196808214-b8e1d6145a8c?w=400&h=400&fit=crop',
      description: 'Classic blue pottery vase with intricate floral patterns from Jaipur.',
      tags: ['BluePottery', 'Vase', 'Jaipur', 'Handmade'],
      stock: 18,
    ),
    Product(
      id: 8,
      name: 'Handcrafted Jewellery Set',
      price: 2199,
      oldPrice: null,
      category: 'Jewellery',
      artisan: 'Priya Kumari',
      location: 'Kolkata, WB',
      rating: 4.9,
      reviews: 73,
      imageUrl: '$_unsplashBase/photo-1515562141589-67f0d89d5432?w=400&h=400&fit=crop',
      description: 'Traditional handcrafted jewellery set with ethnic design and natural stones.',
      tags: ['Jewellery', 'Handmade', 'Traditional', 'Bengal'],
      stock: 10,
    ),
  ];

  static final List<Product> featured = all.where((p) => p.rating >= 4.4).toList();

  static List<Product> byCategory(String category) {
    if (category == 'All') return all;
    return all.where((p) => p.category == category).toList();
  }

  static Product? byId(int id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
