import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/b2b_models.dart';
import '../../../core/models/marketplace_product.dart';
import '../../../core/models/artisan_profile.dart';
import '../../../core/services/api_config.dart';

class B2BService {
  SupabaseClient get _client => Supabase.instance.client;

  // ==================== REQUIREMENTS ====================

  Future<List<B2BRequirement>> getRequirements({String? buyerId, String? status}) async {
    try {
      var query = _client.from('b2b_requirements').select();
      if (buyerId != null && buyerId.isNotEmpty) {
        query = query.eq('buyer_id', buyerId);
      }
      if (status != null && status.isNotEmpty) {
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
      final map = requirement.toMap()..remove('id');
      if (map['buyer_id'] == null || (map['buyer_id'] is String && (map['buyer_id'] as String).isEmpty)) {
        map.remove('buyer_id');
      }
      final data = await _client
          .from('b2b_requirements')
          .insert(map)
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

  // ==================== AI ARTISAN MATCHING (GROQ) ====================

  Future<B2BMatchResult> matchArtisansWithAI({
    required String title,
    String? category,
    String? craftType,
    String? material,
    int? quantity,
    double? budgetMin,
    double? budgetMax,
    String? deliveryLocation,
    DateTime? deadline,
    String? customization,
    String? description,
    String? requirementId,
  }) async {
    final payload = {
      'title': title,
      if (category != null && category.isNotEmpty) 'category': category,
      if (craftType != null && craftType.isNotEmpty) 'craft_type': craftType,
      if (material != null && material.isNotEmpty) 'material': material,
      if (quantity != null && quantity > 0) 'quantity': quantity,
      if (budgetMin != null) 'budget_min': budgetMin,
      if (budgetMax != null) 'budget_max': budgetMax,
      if (deliveryLocation != null && deliveryLocation.isNotEmpty) 'delivery_location': deliveryLocation,
      if (deadline != null) 'deadline': '${deadline.day}/${deadline.month}/${deadline.year}',
      if (customization != null && customization.isNotEmpty) 'customization': customization,
      if (description != null && description.isNotEmpty) 'description': description,
      if (requirementId != null && requirementId.isNotEmpty) 'requirement_id': requirementId,
    };

    for (final host in ApiConfig.candidateUrls) {
      try {
        final uri = Uri.parse('$host/api/b2b/match-artisans');
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          if (data['success'] == true && data['matches'] != null) {
            return B2BMatchResult.fromMap(data);
          }
        }
      } catch (_) {
        continue;
      }
    }

    // Fallback: smart matching using Supabase artisans or local catalog
    return _localArtisanMatchFallback(
      title: title,
      category: category,
      craftType: craftType,
      material: material,
      quantity: quantity,
      deliveryLocation: deliveryLocation,
      description: description,
    );
  }

  Future<B2BMatchResult> _localArtisanMatchFallback({
    required String title,
    String? category,
    String? craftType,
    String? material,
    int? quantity,
    String? deliveryLocation,
    String? description,
  }) async {
    var artisans = await getArtisans();
    if (artisans.isEmpty) {
      // Offline fallback dummy profiles
      artisans = [
        ArtisanProfile(
          id: 'a1000000-0000-0000-0000-000000000001',
          userId: '',
          name: 'Meera Devi',
          avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/66/A_working_woman_at_Ajmere.jpg',
          craftSpecialization: 'Block Printing & Textiles',
          location: 'Jaipur, Rajasthan',
          state: 'Rajasthan',
          yearsOfExperience: 18,
          averageRating: 4.8,
          totalReviews: 42,
          isVerified: true,
          bio: 'Master block printer from Sanganer, Jaipur carrying forward a 200-year-old family tradition with natural herbal dyes.',
          craftStory: 'I was born into a family of Chippa community block printers in Sanganer. From age 10, my grandmother taught me how to extract vibrant reds from madder root and deep blues from natural indigo. Every teakwood block carved by my brothers carries patterns handed down across six generations.',
          createdAt: DateTime.now(),
        ),
        ArtisanProfile(
          id: 'a1000000-0000-0000-0000-000000000002',
          userId: '',
          name: 'Ramesh Kumar',
          avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Potter%2C_near_Jaipur%2C_Rajasthan%2C_India.jpg',
          craftSpecialization: 'Blue Pottery',
          location: 'Jaipur, Rajasthan',
          state: 'Rajasthan',
          yearsOfExperience: 25,
          averageRating: 4.9,
          totalReviews: 56,
          isVerified: true,
          bio: 'Award-winning master potter from Jaipur. Fifth-generation artisan keeping the timeless art of quartz blue pottery alive.',
          craftStory: 'Blue pottery is an alchemy of quartz stone powder, Fuller\'s earth, and natural gum. My grandfather was among the handful of artisans who revived Jaipur blue pottery. Sitting barefoot at my traditional wheel, I mold each vase, plate, and bowl by hand.',
          createdAt: DateTime.now(),
        ),
        ArtisanProfile(
          id: 'a1000000-0000-0000-0000-000000000003',
          userId: '',
          name: 'Kavita Sharma',
          avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/dd/Handloom_Weaver_in_an_exhibition_1.jpg',
          craftSpecialization: 'Handloom & Banarasi Silk',
          location: 'Varanasi, Uttar Pradesh',
          state: 'Uttar Pradesh',
          yearsOfExperience: 22,
          averageRating: 4.7,
          totalReviews: 38,
          isVerified: true,
          bio: 'Master handloom weaver from Varanasi specializing in authentic pure silk sarees and heritage zari motifs.',
          craftStory: 'In the narrow lanes of Madanpura in Varanasi, the rhythmic clack-clack of pit looms has been the soundtrack of my life. My father sat at the loom before sunrise, and I grew up sorting pure mulberry silk threads and gold zari. A single bridal Banarasi saree takes up to 40 days of painstaking hand weaving.',
          createdAt: DateTime.now(),
        ),
        ArtisanProfile(
          id: 'a1000000-0000-0000-0000-000000000004',
          userId: '',
          name: 'Arjun Boro',
          avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/3a/Assamese_woman_using_traditional_handloom.jpg',
          craftSpecialization: 'Bamboo & Cane Craft',
          location: 'Guwahati, Assam',
          state: 'Assam',
          yearsOfExperience: 15,
          averageRating: 4.6,
          totalReviews: 29,
          isVerified: true,
          bio: 'Eco-artisan from Assam crafting sustainable, handcrafted bamboo and cane furniture and home decor.',
          craftStory: 'In our lush village along the Brahmaputra, bamboo is life itself. I learned from the elders of the Bodo community how to select mature bamboo during autumn, treat it naturally with water and smoke, and split it into delicate strands.',
          createdAt: DateTime.now(),
        ),
        ArtisanProfile(
          id: 'a1000000-0000-0000-0000-000000000005',
          userId: '',
          name: 'Sita Nair',
          avatarUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/8b/Carpenter_at_work.JPG',
          craftSpecialization: 'Woodcarving',
          location: 'Thrissur, Kerala',
          state: 'Kerala',
          yearsOfExperience: 20,
          averageRating: 4.8,
          totalReviews: 35,
          isVerified: true,
          bio: 'Traditional woodcarver from Thrissur, Kerala specializing in heritage rosewood sculptures and decorative woodwork.',
          craftStory: 'Woodcarving has been our family\'s worship for generations in Thrissur. Working with fragrant sandalwood, seasoned rosewood, and teak, my hands have shaped temple doors, Kathakali motifs, and intricate jewelry boxes.',
          createdAt: DateTime.now(),
        ),
      ];
    }

    final allQuery = '$title ${category ?? ''} ${craftType ?? ''} ${material ?? ''} ${description ?? ''}'.toLowerCase();
    final matches = <B2BMatchedArtisan>[];

    for (final a in artisans) {
      int score = 50;
      final spec = a.craftSpecialization.toLowerCase();
      final reasons = <String>[];
      final tags = <String>[];

      if (allQuery.contains('silk') || allQuery.contains('saree') || allQuery.contains('handloom') || allQuery.contains('dupatta')) {
        if (spec.contains('silk') || spec.contains('handloom')) {
          score += 42;
          reasons.add('Master handloom weaver with authentic pit loom production setup.');
          tags.add('Handloom Specialist');
        }
      }
      if (allQuery.contains('pottery') || allQuery.contains('clay') || allQuery.contains('terracotta') || allQuery.contains('ceramic') || allQuery.contains('cup')) {
        if (spec.contains('pottery') || spec.contains('ceramic') || spec.contains('terracotta')) {
          score += 44;
          reasons.add('Master potter experienced in bulk glazed tableware and artistic pottery.');
          tags.add('Pottery Studio');
        }
      }
      if (allQuery.contains('block') || allQuery.contains('print') || allQuery.contains('bag')) {
        if (spec.contains('block') || spec.contains('print')) {
          score += 42;
          reasons.add('Specializes in natural dye hand-block printing on natural fabrics.');
          tags.add('Block Printing');
        }
      }
      if (allQuery.contains('bamboo') || allQuery.contains('cane') || allQuery.contains('basket') || allQuery.contains('eco')) {
        if (spec.contains('bamboo') || spec.contains('cane')) {
          score += 42;
          reasons.add('Heritage tribal artisan crafting high-durability bamboo & cane products.');
          tags.add('Eco Artisan');
        }
      }
      if (allQuery.contains('wood') || allQuery.contains('carv') || allQuery.contains('box')) {
        if (spec.contains('wood')) {
          score += 42;
          reasons.add('Expert woodcarver specializing in solid wood articles and intricate carving.');
          tags.add('Master Carver');
        }
      }

      if (deliveryLocation != null && deliveryLocation.isNotEmpty) {
        if (a.location.toLowerCase().contains(deliveryLocation.toLowerCase()) ||
            a.state.toLowerCase().contains(deliveryLocation.toLowerCase())) {
          score += 8;
          reasons.add('Located near $deliveryLocation for prompt dispatch.');
          tags.add('Nearby Artisan');
        }
      }

      if (a.yearsOfExperience >= 15) {
        score += 5;
        tags.add('${a.yearsOfExperience}+ Yrs Exp');
      }

      final finalScore = score.clamp(35, 98);
      if (reasons.isEmpty) {
        reasons.add('Experienced artisan in ${a.craftSpecialization} capable of fulfilling custom production.');
      }
      if (tags.isEmpty) {
        tags.addAll(['Custom Crafts', 'Verified Artisan']);
      }

      matches.add(
        B2BMatchedArtisan(
          artisanId: a.id,
          artisanName: a.name,
          avatarUrl: a.avatarUrl,
          craftSpecialization: a.craftSpecialization,
          location: a.location,
          state: a.state,
          yearsOfExperience: a.yearsOfExperience,
          averageRating: a.averageRating,
          totalReviews: a.totalReviews,
          isVerified: a.isVerified,
          matchScore: finalScore,
          matchReason: reasons.join(' '),
          feasibility: finalScore >= 80 ? 'Very High' : 'High',
          highlightTags: tags.take(3).toList(),
        ),
      );
    }

    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return B2BMatchResult(
      success: true,
      requirementSummary: "Requirement for '$title' (${quantity ?? 'flexible'} pieces)",
      aiAnalysis: "Analyzed your requirement for '$title'. We found ${matches.length} skilled Indian artisans whose craftsmanship, tools, and materials align with this request.",
      suggestedCraft: category ?? craftType ?? 'Handcrafted Art',
      estimatedProductionTime: '2-4 weeks',
      matches: matches,
      totalMatches: matches.length,
      modelUsed: 'local-intelligence-engine',
    );
  }
}

