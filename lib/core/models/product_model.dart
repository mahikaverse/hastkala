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

class MockProducts {
  MockProducts._();

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
