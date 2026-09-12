import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/b2b_models.dart';
import '../../../core/models/marketplace_product.dart';
import '../../../core/models/artisan_profile.dart';

class B2BService {
  final SupabaseClient _client = Supabase.instance.client;

  // ==================== REQUIREMENTS ====================

  Future<List<B2BRequirement>> getRequirements({String? buyerId, String? status}) async {
    try {
      var query = _client.from('b2b_requirements').select();
      if (buyerId != null) {
        query = query.eq('buyer_id', buyerId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List).map((e) => B2BRequirement.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<B2BRequirement?> createRequirement(B2BRequirement requirement) async {
    try {
      final data = await _client
          .from('b2b_requirements')
          .insert(requirement.toMap()..remove('id'))
          .select()
          .single();
      return B2BRequirement.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<B2BRequirement?> updateRequirement(B2BRequirement requirement) async {
    try {
      final data = await _client
          .from('b2b_requirements')
          .update(requirement.toMap()..remove('created_at'))
          .eq('id', requirement.id)
          .select()
          .single();
      return B2BRequirement.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteRequirement(String id) async {
    try {
      await _client.from('b2b_requirements').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== ENQUIRIES ====================

  Future<List<B2BEnquiry>> getEnquiries({
    String? buyerId,
    String? artisanId,
    String? productId,
    String? requirementId,
  }) async {
    try {
      var query = _client.from('b2b_enquiries').select();
      if (buyerId != null) query = query.eq('buyer_id', buyerId);
      if (artisanId != null) query = query.eq('artisan_id', artisanId);
      if (productId != null) query = query.eq('product_id', productId);
      if (requirementId != null) query = query.eq('requirement_id', requirementId);
      final data = await query.order('created_at', ascending: false);
      return (data as List).map((e) => B2BEnquiry.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<B2BEnquiry?> createEnquiry(B2BEnquiry enquiry) async {
    try {
      final data = await _client
          .from('b2b_enquiries')
          .insert(enquiry.toMap()..remove('id'))
          .select()
          .single();
      return B2BEnquiry.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<B2BEnquiry?> updateEnquiry(B2BEnquiry enquiry) async {
    try {
      final data = await _client
          .from('b2b_enquiries')
          .update(enquiry.toMap()..remove('created_at'))
          .eq('id', enquiry.id)
          .select()
          .single();
      return B2BEnquiry.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteEnquiry(String id) async {
    try {
      await _client.from('b2b_enquiries').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== QUOTES ====================

  Future<List<B2BQuote>> getQuotes({
    String? enquiryId,
    String? artisanId,
  }) async {
    try {
      var query = _client.from('b2b_quotes').select();
      if (enquiryId != null) query = query.eq('enquiry_id', enquiryId);
      if (artisanId != null) query = query.eq('artisan_id', artisanId);
      final data = await query.order('created_at', ascending: false);
      return (data as List).map((e) => B2BQuote.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<B2BQuote?> createQuote(B2BQuote quote) async {
    try {
      final data = await _client
          .from('b2b_quotes')
          .insert(quote.toMap()..remove('id'))
          .select()
          .single();
      return B2BQuote.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<B2BQuote?> updateQuote(B2BQuote quote) async {
    try {
      final data = await _client
          .from('b2b_quotes')
          .update(quote.toMap()..remove('created_at'))
          .eq('id', quote.id)
          .select()
          .single();
      return B2BQuote.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  // ==================== ORDERS ====================

  Future<List<B2BOrder>> getOrders({
    String? buyerId,
    String? artisanId,
  }) async {
    try {
      var query = _client.from('b2b_orders').select();
      if (buyerId != null) query = query.eq('buyer_id', buyerId);
      if (artisanId != null) query = query.eq('artisan_id', artisanId);
      final data = await query.order('created_at', ascending: false);
      return (data as List).map((e) => B2BOrder.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<B2BOrder?> createOrder(B2BOrder order) async {
    try {
      final data = await _client
          .from('b2b_orders')
          .insert(order.toMap()..remove('id'))
          .select()
          .single();
      return B2BOrder.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<B2BOrder?> updateOrder(B2BOrder order) async {
    try {
      final data = await _client
          .from('b2b_orders')
          .update(order.toMap()..remove('created_at'))
          .eq('id', order.id)
          .select()
          .single();
      return B2BOrder.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  // ==================== SAVED ARTISANS ====================

  Future<List<Map<String, dynamic>>> getSavedArtisans(String buyerId) async {
    try {
      final data = await _client
          .from('b2b_saved_artisans')
          .select('*, artisans:artisan_id(*)')
          .eq('buyer_id', buyerId)
          .order('created_at', ascending: false);
      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveArtisan(String buyerId, String artisanId) async {
    try {
      await _client.from('b2b_saved_artisans').insert({
        'buyer_id': buyerId,
        'artisan_id': artisanId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unsaveArtisan(String buyerId, String artisanId) async {
    try {
      await _client
          .from('b2b_saved_artisans')
          .delete()
          .eq('buyer_id', buyerId)
          .eq('artisan_id', artisanId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isArtisanSaved(String buyerId, String artisanId) async {
    try {
      final data = await _client
          .from('b2b_saved_artisans')
          .select('id')
          .eq('buyer_id', buyerId)
          .eq('artisan_id', artisanId)
          .limit(1);
      return (data as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== HELPERS: snake_case → camelCase ====================

  static Map<String, dynamic> _productToCamel(Map<String, dynamic> row) {
    return {
      'id': row['id'] ?? '',
      'storeId': row['store_id'] ?? '',
      'artisanId': row['artisan_id'] ?? '',
      'name': row['name'] ?? '',
      'description': row['description'] ?? '',
      'price': row['price'],
      'discountPrice': row['discount_price'],
      'category': row['category'] ?? '',
      'subcategory': row['subcategory'] ?? '',
      'imageUrls': row['image_urls'] ?? [],
      'variants': row['variants'] ?? [],
      'stockQuantity': row['stock_quantity'] ?? 0,
      'isPublished': row['is_published'] ?? true,
      'isFeatured': row['is_featured'] ?? false,
      'craftType': row['craft_type'],
      'material': row['material'],
      'weight': row['weight'],
      'dimensions': row['dimensions'],
      'shippingInfo': row['shipping_info'],
      'tags': row['tags'] ?? [],
      'averageRating': row['average_rating'] ?? 0.0,
      'totalReviews': row['total_reviews'] ?? 0,
      'totalSales': row['total_sales'] ?? 0,
      'views': row['views'] ?? 0,
      'createdAt': row['created_at'] ?? '',
      'updatedAt': row['updated_at'] ?? '',
    };
  }

  static Map<String, dynamic> _artisanToCamel(Map<String, dynamic> row) {
    return {
      'id': row['id'] ?? '',
      'userId': row['user_id'] ?? '',
      'name': row['name'] ?? '',
      'avatarUrl': row['avatar_url'] ?? '',
      'bio': row['bio'] ?? '',
      'craftSpecialization': row['craft_specialization'] ?? '',
      'location': row['location'] ?? '',
      'state': row['state'] ?? '',
      'yearsOfExperience': row['years_of_experience'] ?? 0,
      'craftStory': row['craft_story'] ?? '',
      'contactEmail': row['contact_email'],
      'contactPhone': row['contact_phone'],
      'website': row['website'],
      'instagram': row['instagram'],
      'facebook': row['facebook'],
      'isVerified': row['is_verified'] ?? false,
      'createdAt': row['created_at'] ?? '',
      'followersCount': row['followers_count'] ?? 0,
      'productsCount': row['products_count'] ?? 0,
      'averageRating': row['average_rating'] ?? 0.0,
      'totalReviews': row['total_reviews'] ?? 0,
    };
  }

  // ==================== PRODUCTS (read-only from artisan side) ====================

  Future<List<MarketplaceProduct>> exploreProducts({
    String? category,
    String? craftType,
    String? material,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    try {
      var query = _client
          .from('products')
          .select()
          .eq('status', 'approved')
          .eq('visibility', 'public');
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (craftType != null && craftType.isNotEmpty) {
        query = query.ilike('craft_type', '%$craftType%');
      }
      if (material != null && material.isNotEmpty) {
        query = query.ilike('material', '%$material%');
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,description.ilike.%$search%,craft_type.ilike.%$search%');
      }
      final data = await query.order('created_at', ascending: false).limit(50);
      return (data as List)
          .map((e) => MarketplaceProduct.fromMap(_productToCamel(e as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MarketplaceProduct?> getProduct(String productId) async {
    try {
      final data = await _client
          .from('products')
          .select()
          .eq('id', productId)
          .single();
      return MarketplaceProduct.fromMap(_productToCamel(data));
    } catch (e) {
      return null;
    }
  }

  Future<List<ArtisanProfile>> getArtisans({
    String? craftType,
    String? location,
  }) async {
    try {
      var query = _client.from('artisans').select();
      if (craftType != null && craftType.isNotEmpty) {
        query = query.ilike('craft_specialization', '%$craftType%');
      }
      if (location != null && location.isNotEmpty) {
        query = query.ilike('location', '%$location%');
      }
      final data = await query.order('created_at', ascending: false).limit(50);
      return (data as List)
          .map((e) => ArtisanProfile.fromMap(_artisanToCamel(e as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<ArtisanProfile?> getArtisan(String artisanId) async {
    try {
      final data = await _client
          .from('artisans')
          .select()
          .eq('id', artisanId)
          .single();
      return ArtisanProfile.fromMap(_artisanToCamel(data));
    } catch (e) {
      return null;
    }
  }

  // ==================== STATS ====================

  Future<Map<String, int>> getBuyerStats(String buyerId) async {
    final requirements = await getRequirements(buyerId: buyerId);
    final enquiries = await getEnquiries(buyerId: buyerId);
    final orders = await getOrders(buyerId: buyerId);
    final saved = await getSavedArtisans(buyerId);
    return {
      'requirements': requirements.length,
      'enquiries': enquiries.length,
      'orders': orders.length,
      'saved': saved.length,
    };
  }

  // ==================== CATEGORIES ====================

  Future<List<String>> getCategories() async {
    try {
      final data = await _client
          .from('products')
          .select('category')
          .eq('status', 'approved')
          .eq('visibility', 'public');
      final cats = (data as List)
          .map((e) => (e['category'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      cats.sort();
      return cats;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCraftTypes() async {
    try {
      final data = await _client
          .from('products')
          .select('craft_type')
          .eq('status', 'approved')
          .eq('visibility', 'public');
      final types = (data as List)
          .map((e) => (e['craft_type'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      types.sort();
      return types;
    } catch (e) {
      return [];
    }
  }
}
