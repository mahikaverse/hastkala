import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/products/models/product_draft.dart';
import '../models/models.dart';
import 'api_config.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _cachedProductsKey = 'hastkala_published_products';

  final List<ArtisanProfile> _artisanProfiles = [];
  final List<ArtisanStore> _stores = [];
  final List<MarketplaceProduct> _products = [];
  final List<StoreCollection> _collections = [];
  final List<MarketplaceOrder> _orders = [];
  final List<Review> _reviews = [];
  final List<CartItem> _cart = [];
  final Set<String> _followedStoreIds = {};
  final Set<String> _wishlistProductIds = {};

  List<ArtisanProfile> get artisanProfiles => List.unmodifiable(_artisanProfiles);
  List<ArtisanStore> get stores => List.unmodifiable(_stores);
  List<MarketplaceProduct> get products => List.unmodifiable(_products);
  List<StoreCollection> get collections => List.unmodifiable(_collections);
  List<MarketplaceOrder> get orders => List.unmodifiable(_orders);
  List<Review> get reviews => List.unmodifiable(_reviews);
  List<CartItem> get cart => List.unmodifiable(_cart);
  Set<String> get followedStoreIds => Set.unmodifiable(_followedStoreIds);
  Set<String> get wishlistProductIds => Set.unmodifiable(_wishlistProductIds);

  bool isFollowing(String storeId) => _followedStoreIds.contains(storeId);
  bool isWishlisted(String productId) => _wishlistProductIds.contains(productId);

  Future<void> init() async {
    if (_artisanProfiles.isEmpty) {
      _seedData();
    }
    await _loadCachedProducts();
    // In background, sync fresh products from backend
    syncPublishedProducts();
  }

  // ─── ARTISAN PROFILES ─────────────────────────────────────────────────────

  ArtisanProfile? getArtisanProfile(String id) {
    try {
      return _artisanProfiles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  ArtisanProfile? getArtisanProfileByUserId(String userId) {
    try {
      return _artisanProfiles.firstWhere((a) => a.userId == userId);
    } catch (_) {
      return null;
    }
  }

  ArtisanProfile createArtisanProfile({
    required String userId,
    required String name,
    String avatarUrl = '',
    String bio = '',
    String craftSpecialization = '',
    String location = '',
    String state = '',
    int yearsOfExperience = 0,
  }) {
    final profile = ArtisanProfile(
      id: 'ap_${_artisanProfiles.length + 1}',
      userId: userId,
      name: name,
      avatarUrl: avatarUrl,
      bio: bio,
      craftSpecialization: craftSpecialization,
      location: location,
      state: state,
      yearsOfExperience: yearsOfExperience,
      createdAt: DateTime.now(),
    );
    _artisanProfiles.add(profile);
    return profile;
  }

  void updateArtisanProfile(String id, ArtisanProfile updated) {
    final index = _artisanProfiles.indexWhere((a) => a.id == id);
    if (index != -1) _artisanProfiles[index] = updated;
  }

  // ─── STORES ───────────────────────────────────────────────────────────────

  ArtisanStore? getStore(String id) {
    try {
      return _stores.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  ArtisanStore? getStoreBySlug(String slug) {
    try {
      return _stores.firstWhere((s) => s.slug == slug);
    } catch (_) {
      return null;
    }
  }

  ArtisanStore? getStoreByArtisanId(String artisanId) {
    try {
      return _stores.firstWhere((s) => s.artisanId == artisanId);
    } catch (_) {
      return null;
    }
  }

  ArtisanStore createStore({
    required String artisanId,
    required String name,
    String description = '',
    String craftCategory = '',
    String location = '',
    String state = '',
  }) {
    final slug = ArtisanStore.generateSlug(name);
    final now = DateTime.now();
    final store = ArtisanStore(
      id: 'st_${_stores.length + 1}',
      artisanId: artisanId,
      name: name,
      slug: slug,
      description: description,
      craftCategory: craftCategory,
      location: location,
      state: state,
      createdAt: now,
      updatedAt: now,
    );
    _stores.add(store);
    return store;
  }

  void updateStore(String id, ArtisanStore updated) {
    final index = _stores.indexWhere((s) => s.id == id);
    if (index != -1) _stores[index] = updated;
  }

  List<ArtisanStore> searchStores(String query) {
    final q = query.toLowerCase();
    return _stores.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.craftCategory.toLowerCase().contains(q) ||
        s.location.toLowerCase().contains(q) ||
        s.state.toLowerCase().contains(q) ||
        s.description.toLowerCase().contains(q)).toList();
  }

  List<ArtisanStore> getStoresByCategory(String category) {
    return _stores.where((s) => s.craftCategory == category).toList();
  }

  // ─── PRODUCTS ─────────────────────────────────────────────────────────────

  MarketplaceProduct? getProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<MarketplaceProduct> getProductsByStore(String storeId) {
    return _products.where((p) => p.storeId == storeId).toList();
  }

  List<MarketplaceProduct> getPublishedProductsByStore(String storeId) {
    return _products.where((p) => p.storeId == storeId && p.isPublished).toList();
  }

  List<MarketplaceProduct> getFeaturedProducts() {
    return _products.where((p) => p.isFeatured && p.isPublished).toList();
  }

  List<MarketplaceProduct> searchProducts(String query) {
    final q = query.toLowerCase();
    return _products.where((p) =>
        p.isPublished &&
        (p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q)))).toList();
  }

  List<MarketplaceProduct> getProductsByCategory(String category) {
    return _products.where((p) => p.isPublished && p.category == category).toList();
  }

  MarketplaceProduct addProduct(MarketplaceProduct product) {
    _products.insert(0, product);
    _registerInMockLists(product);
    _updateStoreProductCount(product.storeId);
    _saveCachedProducts();
    return product;
  }

  Future<void> _saveCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final published = _products
          .where((p) => p.id.startsWith('prod_'))
          .map((p) => p.toMap())
          .toList();
      await prefs.setString(_cachedProductsKey, jsonEncode(published));
    } catch (e) {
      debugPrint('Failed to cache products: $e');
    }
  }

  Future<void> _loadCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedProductsKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        for (final item in list) {
          final p = MarketplaceProduct.fromMap(Map<String, dynamic>.from(item));
          if (!_products.any((existing) => existing.id == p.id)) {
            _products.insert(0, p);
            _registerInMockLists(p);
          }
        }
        if (_stores.isNotEmpty) {
          _updateStoreProductCount(_stores.first.id);
        }
      }
    } catch (e) {
      debugPrint('Failed to load cached products: $e');
    }
  }

  void _registerInMockLists(MarketplaceProduct p) {
    final digits = p.id.replaceAll(RegExp(r'[^0-9]'), '');
    final numId = digits.length >= 6
        ? int.tryParse(digits.substring(digits.length - 6)) ?? (2000 + _products.length)
        : (2000 + _products.length);

    final product = Product(
      id: numId,
      name: p.name,
      price: p.price.toInt(),
      category: p.category.isNotEmpty ? p.category : 'Handicrafts',
      artisan: _stores.isNotEmpty ? _stores.first.name : 'Artisan',
      location: _stores.isNotEmpty ? _stores.first.location : 'Jaipur, Rajasthan',
      rating: p.averageRating > 0 ? p.averageRating : 5.0,
      reviews: p.totalReviews,
      imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
      description: p.description,
      tags: p.tags,
      stock: p.stockQuantity,
      status: 'Published',
    );
    MockProducts.addProduct(product);
    MockArtisanProducts.addProduct(ArtisanProduct(
      product: product,
      status: 'Published',
      views: p.views,
      orders: p.totalSales,
    ));
  }

  Future<void> syncPublishedProducts() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/products');
      final resp = await http.get(uri).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final List items = data['products'] ?? [];
        bool changed = false;
        for (final item in items) {
          final id = item['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final existingIdx = _products.indexWhere((p) => p.id == id);
          final img = item['image_url']?.toString() ?? '';
          final name = item['name']?.toString() ?? 'Product';
          final price = (item['price'] as num?)?.toDouble() ?? 500.0;
          final cat = item['category']?.toString() ?? 'Handicrafts';
          final desc = item['description']?.toString() ?? '';
          final storeId = item['store_id']?.toString() ?? (_stores.isNotEmpty ? _stores.first.id : 'st_1');
          final tags = (item['tags'] as List?)?.map((t) => t.toString()).toList() ?? ['Handmade'];

          final mp = MarketplaceProduct(
            id: id,
            storeId: storeId,
            artisanId: _artisanProfiles.isNotEmpty ? _artisanProfiles.first.id : 'ap_1',
            name: name,
            description: desc,
            price: price,
            category: cat,
            imageUrls: [if (img.isNotEmpty) img],
            stockQuantity: (item['stock'] as num?)?.toInt() ?? 10,
            isPublished: true,
            isFeatured: true,
            tags: tags,
            createdAt: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.now(),
          );

          if (existingIdx == -1) {
            _products.insert(0, mp);
            _registerInMockLists(mp);
            changed = true;
          } else {
            _products[existingIdx] = mp;
            _registerInMockLists(mp);
          }
        }
        if (changed) {
          if (_stores.isNotEmpty) _updateStoreProductCount(_stores.first.id);
          _saveCachedProducts();
        }
      }
    } catch (e) {
      debugPrint('Sync products skipped: $e');
    }
  }

  Future<MarketplaceProduct> publishProductDraft(ProductDraft draft) async {
    final priceVal = (draft.price ?? draft.suggestedPrice ?? draft.expectedPrice ?? 750).toDouble();
    final prodId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
    final storeId = _stores.isNotEmpty ? _stores.first.id : 'st_1';
    final artisanId = _artisanProfiles.isNotEmpty ? _artisanProfiles.first.id : 'ap_1';

    String? base64Img;
    if (draft.isBase64Image && draft.imagePath != null) {
      base64Img = draft.imagePath!;
    } else if (draft.imagePath != null && !draft.isBase64Image) {
      try {
        final f = File(draft.imagePath!);
        if (f.existsSync()) {
          base64Img = base64Encode(f.readAsBytesSync());
        }
      } catch (_) {}
    }

    final imageUrl = draft.imagePath ?? '';
    final mp = MarketplaceProduct(
      id: prodId,
      storeId: storeId,
      artisanId: artisanId,
      name: draft.productName?.trim().isNotEmpty == true
          ? draft.productName!.trim()
          : 'Product',
      description: draft.description?.trim().isNotEmpty == true
          ? draft.description!.trim()
          : draft.craftStory?.trim().isNotEmpty == true
              ? draft.craftStory!.trim()
              : '',
      price: priceVal > 0 ? priceVal : 750.0,
      category: draft.category?.trim().isNotEmpty == true
          ? draft.category!.trim()
          : 'Pottery & Ceramics',
      craftType: draft.craft,
      material: draft.material,
      imageUrls: [if (imageUrl.isNotEmpty) imageUrl],
      tags: [
        if (draft.craft != null && draft.craft!.isNotEmpty) draft.craft!,
        if (draft.material != null && draft.material!.isNotEmpty) draft.material!,
        'Handmade',
      ],
      stockQuantity: 10,
      isPublished: true,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 1. Instantly display in local lists
    _products.insert(0, mp);
    _registerInMockLists(mp);
    _updateStoreProductCount(storeId);
    await _saveCachedProducts();

    // 2. Persist to Backend & Supabase Storage
    _sendToBackend(prodId, mp, draft, base64Img);

    return mp;
  }

  void _sendToBackend(
    String prodId,
    MarketplaceProduct mp,
    ProductDraft draft,
    String? base64Img,
  ) async {
    try {
      final payload = {
        'id': prodId,
        'name': mp.name,
        'price': mp.price,
        'category': mp.category,
        'craft': draft.craft,
        'material': draft.material,
        'color': draft.color,
        'artisan_name': draft.artisanName ??
            (_artisanProfiles.isNotEmpty ? _artisanProfiles.first.name : 'Artisan'),
        'artisan_id': mp.artisanId,
        'store_id': mp.storeId,
        'location': draft.location ?? draft.artisanLocation ?? 'Jaipur, Rajasthan',
        'description': mp.description,
        'craft_story': draft.craftStory,
        'making_time': draft.makingTime,
        'tags': mp.tags,
        'image_base64': base64Img,
        'image_url': mp.imageUrls.isNotEmpty ? mp.imageUrls.first : '',
        'stock': 10,
        'is_published': true,
      };

      final resp = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final remoteUrl = data['product']?['image_url']?.toString();
        if (remoteUrl != null && remoteUrl.isNotEmpty) {
          final idx = _products.indexWhere((p) => p.id == prodId);
          if (idx != -1) {
            final updated = _products[idx].copyWith(imageUrls: [remoteUrl]);
            _products[idx] = updated;
            _registerInMockLists(updated);
            _saveCachedProducts();
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending product to backend: $e');
    }
  }

  void updateProduct(String id, MarketplaceProduct updated) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updated;
      _updateStoreProductCount(updated.storeId);
      _saveCachedProducts();
    }
  }

  void deleteProduct(String id) {
    final product = getProduct(id);
    if (product != null) {
      _products.removeWhere((p) => p.id == id);
      _updateStoreProductCount(product.storeId);
      _saveCachedProducts();
    }
  }

  void _updateStoreProductCount(String storeId) {
    final count = _products.where((p) => p.storeId == storeId && p.isPublished).length;
    final storeIndex = _stores.indexWhere((s) => s.id == storeId);
    if (storeIndex != -1) {
      _stores[storeIndex] = _stores[storeIndex].copyWith(totalProducts: count);
    }
  }

  // ─── COLLECTIONS ──────────────────────────────────────────────────────────

  List<StoreCollection> getCollectionsByStore(String storeId) {
    return _collections.where((c) => c.storeId == storeId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  StoreCollection addCollection(StoreCollection collection) {
    _collections.add(collection);
    return collection;
  }

  void updateCollection(String id, StoreCollection updated) {
    final index = _collections.indexWhere((c) => c.id == id);
    if (index != -1) _collections[index] = updated;
  }

  void deleteCollection(String id) {
    _collections.removeWhere((c) => c.id == id);
  }

  // ─── ORDERS ───────────────────────────────────────────────────────────────

  List<MarketplaceOrder> getOrdersByStore(String storeId) {
    return _orders.where((o) => o.storeId == storeId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<MarketplaceOrder> getOrdersByBuyer(String buyerId) {
    return _orders.where((o) => o.buyerId == buyerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  MarketplaceOrder? getOrder(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  MarketplaceOrder createOrder(MarketplaceOrder order) {
    _orders.add(order);
    return order;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  // ─── REVIEWS ──────────────────────────────────────────────────────────────

  List<Review> getReviewsByStore(String storeId) {
    return _reviews.where((r) => r.storeId == storeId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Review> getReviewsByProduct(String productId) {
    return _reviews.where((r) => r.productId == productId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Review addReview(Review review) {
    _reviews.add(review);
    _updateStoreRating(review.storeId);
    return review;
  }

  void _updateStoreRating(String storeId) {
    final storeReviews = _reviews.where((r) => r.storeId == storeId).toList();
    if (storeReviews.isNotEmpty) {
      final avg = storeReviews.map((r) => r.rating).reduce((a, b) => a + b) / storeReviews.length;
      final storeIndex = _stores.indexWhere((s) => s.id == storeId);
      if (storeIndex != -1) {
        _stores[storeIndex] = _stores[storeIndex].copyWith(
          averageRating: double.parse(avg.toStringAsFixed(1)),
          totalReviews: storeReviews.length,
        );
      }
    }
  }

  // ─── CART ─────────────────────────────────────────────────────────────────

  void addToCart(CartItem item) {
    final existingIndex = _cart.indexWhere(
        (c) => c.productId == item.productId && c.selectedVariant == item.selectedVariant);
    if (existingIndex != -1) {
      _cart[existingIndex] = _cart[existingIndex].copyWith(
        quantity: _cart[existingIndex].quantity + item.quantity,
      );
    } else {
      _cart.add(item);
    }
  }

  void updateCartItemQuantity(String productId, int quantity, {String? variant}) {
    final index = _cart.indexWhere(
        (c) => c.productId == productId && c.selectedVariant == variant);
    if (index != -1) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = _cart[index].copyWith(quantity: quantity);
      }
    }
  }

  void removeFromCart(String productId, {String? variant}) {
    _cart.removeWhere(
        (c) => c.productId == productId && c.selectedVariant == variant);
  }

  void clearCart() {
    _cart.clear();
  }

  double get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);

  Map<String, List<CartItem>> get cartByStore {
    final map = <String, List<CartItem>>{};
    for (final item in _cart) {
      map.putIfAbsent(item.storeId, () => []).add(item);
    }
    return map;
  }

  // ─── FOLLOW / UNFOLLOW ────────────────────────────────────────────────────

  void toggleFollow(String storeId) {
    if (_followedStoreIds.contains(storeId)) {
      _followedStoreIds.remove(storeId);
      final storeIndex = _stores.indexWhere((s) => s.id == storeId);
      if (storeIndex != -1) {
        _stores[storeIndex] = _stores[storeIndex].copyWith(
          totalFollowers: _stores[storeIndex].totalFollowers - 1,
        );
      }
    } else {
      _followedStoreIds.add(storeId);
      final storeIndex = _stores.indexWhere((s) => s.id == storeId);
      if (storeIndex != -1) {
        _stores[storeIndex] = _stores[storeIndex].copyWith(
          totalFollowers: _stores[storeIndex].totalFollowers + 1,
        );
      }
    }
  }

  // ─── WISHLIST ─────────────────────────────────────────────────────────────

  void toggleWishlist(String productId) {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
  }

  List<MarketplaceProduct> getWishlistProducts() {
    return _products.where((p) => _wishlistProductIds.contains(p.id)).toList();
  }

  // ─── DASHBOARD STATS ──────────────────────────────────────────────────────

  Map<String, dynamic> getStoreStats(String storeId) {
    final storeProducts = getProductsByStore(storeId);
    final storeOrders = getOrdersByStore(storeId);
    final publishedProducts = storeProducts.where((p) => p.isPublished).length;
    final totalRevenue = storeOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + o.total);
    final pendingOrders = storeOrders
        .where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.confirmed)
        .length;
    final totalViews = storeProducts.fold(0, (sum, p) => sum + p.views);
    final store = getStore(storeId);
    final avgRating = store?.averageRating ?? 0.0;
    final totalSales = storeOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0, (sum, o) => sum + o.items.fold(0, (s, i) => s + i.quantity));

    return {
      'totalProducts': storeProducts.length,
      'publishedProducts': publishedProducts,
      'draftProducts': storeProducts.length - publishedProducts,
      'totalOrders': storeOrders.length,
      'pendingOrders': pendingOrders,
      'totalRevenue': totalRevenue,
      'totalViews': totalViews,
      'averageRating': avgRating,
      'totalSales': totalSales,
      'totalFollowers': store?.totalFollowers ?? 0,
    };
  }

  // ─── SEED DATA ────────────────────────────────────────────────────────────

  void _seedData() {
    // Artisan profiles
    final profiles = [
      ArtisanProfile(
        id: 'ap_1', userId: 'u_1', name: 'Ramesh Kumar',
        bio: 'Traditional wood carver with 25+ years of experience',
        craftSpecialization: 'Wood Carving', location: 'Jaipur', state: 'Rajasthan',
        yearsOfExperience: 25, isVerified: true, createdAt: DateTime(2023, 1, 15),
        followersCount: 342, productsCount: 48, averageRating: 4.8, totalReviews: 156,
        craftStory: 'Born into a family of master woodcarvers, I learned the art from my grandfather at age 7. Each piece I create carries centuries of tradition and my personal touch. My workshop in the heart of Jaipur has been a center of craftsmanship for over three generations.',
      ),
      ArtisanProfile(
        id: 'ap_2', userId: 'u_2', name: 'Meera Devi',
        bio: 'Master weaver preserving Rajasthani textile traditions',
        craftSpecialization: 'Handloom Weaving', location: 'Bhilwara', state: 'Rajasthan',
        yearsOfExperience: 18, isVerified: true, createdAt: DateTime(2023, 3, 20),
        followersCount: 218, productsCount: 35, averageRating: 4.7, totalReviews: 98,
        craftStory: 'I weave stories into every thread. My handloom has been in our family for four generations, and each dupatta, sari, and shawl tells a tale of Rajasthani heritage. I train young women in my village to keep this art alive.',
      ),
      ArtisanProfile(
        id: 'ap_3', userId: 'u_3', name: 'Suresh Patel',
        bio: 'Creating exquisite blue pottery using ancient techniques',
        craftSpecialization: 'Blue Pottery', location: 'Jaipur', state: 'Rajasthan',
        yearsOfExperience: 15, isVerified: true, createdAt: DateTime(2023, 5, 10),
        followersCount: 189, productsCount: 28, averageRating: 4.6, totalReviews: 72,
        craftStory: 'Blue pottery is not just my craft, it is my meditation. Each piece takes weeks to complete, from shaping the dough to the final firing. I am proud to keep this Persian-origin art form alive in Jaipur.',
      ),
      ArtisanProfile(
        id: 'ap_4', userId: 'u_4', name: 'Lakshmi Nair',
        bio: 'Kerala handloom artisan specializing in Kasavu sarees',
        craftSpecialization: 'Kasavu Weaving', location: 'Kozhikode', state: 'Kerala',
        yearsOfExperience: 20, isVerified: true, createdAt: DateTime(2023, 7, 5),
        followersCount: 156, productsCount: 22, averageRating: 4.9, totalReviews: 64,
        craftStory: 'The golden border of a Kasavu saree represents the prosperity of Kerala. I weave each saree with pure cotton and real gold zari, preserving the timeless elegance of my homeland.',
      ),
      ArtisanProfile(
        id: 'ap_5', userId: 'u_5', name: 'Arjun Singh',
        bio: 'Brass and copper artisan from Moradabad',
        craftSpecialization: 'Brass Work', location: 'Moradabad', state: 'Uttar Pradesh',
        yearsOfExperience: 12, isVerified: false, createdAt: DateTime(2024, 1, 8),
        followersCount: 87, productsCount: 19, averageRating: 4.5, totalReviews: 34,
        craftStory: 'Moradabad is the brass city of India, and I am proud to carry forward this legacy. My pieces blend traditional motifs with contemporary design for modern homes.',
      ),
      ArtisanProfile(
        id: 'ap_6', userId: 'u_6', name: 'Priya Sharma',
        bio: 'Madhubani artist bringing folk art to everyday products',
        craftSpecialization: 'Madhubani Painting', location: 'Madhubani', state: 'Bihar',
        yearsOfExperience: 10, isVerified: true, createdAt: DateTime(2024, 2, 14),
        followersCount: 203, productsCount: 31, averageRating: 4.7, totalReviews: 89,
        craftStory: 'Madhubani art has been in my family for generations. I paint the myths, nature, and daily life of my village on canvas, fabric, and paper. Every line tells a story of Mithila.',
      ),
    ];
    _artisanProfiles.addAll(profiles);

    // Stores
    final stores = [
      ArtisanStore(
        id: 'st_1', artisanId: 'ap_1', name: 'Ramesh Woodcraft', slug: 'ramesh-woodcraft',
        description: 'Handcrafted wooden art made using traditional techniques passed through generations.',
        craftCategory: 'Wood Carving', location: 'Jaipur', state: 'Rajasthan',
        averageRating: 4.8, totalReviews: 156, totalProducts: 12, totalSales: 234,
        totalFollowers: 342, isVerified: true, createdAt: DateTime(2023, 1, 15), updatedAt: DateTime.now(),
      ),
      ArtisanStore(
        id: 'st_2', artisanId: 'ap_2', name: 'Meera Handloom', slug: 'meera-handloom',
        description: 'Authentic Rajasthani handloom textiles woven with love and tradition.',
        craftCategory: 'Handloom Weaving', location: 'Bhilwara', state: 'Rajasthan',
        averageRating: 4.7, totalReviews: 98, totalProducts: 10, totalSales: 178,
        totalFollowers: 218, isVerified: true, createdAt: DateTime(2023, 3, 20), updatedAt: DateTime.now(),
      ),
      ArtisanStore(
        id: 'st_3', artisanId: 'ap_3', name: 'Jaipur Blue Pottery', slug: 'jaipur-blue-pottery',
        description: 'Exquisite blue pottery created using centuries-old techniques.',
        craftCategory: 'Blue Pottery', location: 'Jaipur', state: 'Rajasthan',
        averageRating: 4.6, totalReviews: 72, totalProducts: 8, totalSales: 145,
        totalFollowers: 189, isVerified: true, createdAt: DateTime(2023, 5, 10), updatedAt: DateTime.now(),
      ),
      ArtisanStore(
        id: 'st_4', artisanId: 'ap_4', name: 'Kasavu Heritage', slug: 'kasavu-heritage',
        description: 'Traditional Kerala Kasavu sarees and textiles with real gold zari.',
        craftCategory: 'Kasavu Weaving', location: 'Kozhikode', state: 'Kerala',
        averageRating: 4.9, totalReviews: 64, totalProducts: 7, totalSales: 112,
        totalFollowers: 156, isVerified: true, createdAt: DateTime(2023, 7, 5), updatedAt: DateTime.now(),
      ),
      ArtisanStore(
        id: 'st_5', artisanId: 'ap_5', name: 'Arjun Brass Works', slug: 'arjun-brass-works',
        description: 'Premium brass and copper home decor with traditional Indian motifs.',
        craftCategory: 'Brass Work', location: 'Moradabad', state: 'Uttar Pradesh',
        averageRating: 4.5, totalReviews: 34, totalProducts: 6, totalSales: 67,
        totalFollowers: 87, isVerified: false, createdAt: DateTime(2024, 1, 8), updatedAt: DateTime.now(),
      ),
      ArtisanStore(
        id: 'st_6', artisanId: 'ap_6', name: 'Madhubani Art Studio', slug: 'madhubani-art-studio',
        description: 'Authentic Madhubani paintings and art products from Mithila.',
        craftCategory: 'Madhubani Painting', location: 'Madhubani', state: 'Bihar',
        averageRating: 4.7, totalReviews: 89, totalProducts: 9, totalSales: 156,
        totalFollowers: 203, isVerified: true, createdAt: DateTime(2024, 2, 14), updatedAt: DateTime.now(),
      ),
    ];
    _stores.addAll(stores);

    // Products
    final products = [
      MarketplaceProduct(
        id: 'p_1', storeId: 'st_1', artisanId: 'ap_1', name: 'Wooden Jewelry Box',
        description: 'Hand-carved wooden jewelry box with intricate floral patterns. Made from premium sheesham wood.',
        price: 1299, discountPrice: 1099, category: 'Home Decor', subcategory: 'Storage',
        imageUrls: ['assets/onboarding1.png'], stockQuantity: 25, isFeatured: true,
        craftType: 'Hand Carved', material: 'Sheesham Wood', weight: '800g', dimensions: '20x15x10 cm',
        tags: ['wooden', 'jewelry', 'handcarved', 'gift'], averageRating: 4.8, totalReviews: 45,
        totalSales: 89, views: 1240, createdAt: DateTime(2023, 6, 1), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_2', storeId: 'st_1', artisanId: 'ap_1', name: 'Carved Wooden Tray',
        description: 'Elegant serving tray with traditional Rajasthani motifs. Perfect for tea time.',
        price: 899, category: 'Home Decor', subcategory: 'Kitchen',
        imageUrls: ['assets/onboarding1.png'], stockQuantity: 40, isFeatured: true,
        craftType: 'Hand Carved', material: 'Mango Wood', weight: '600g', dimensions: '35x25x3 cm',
        tags: ['tray', 'serving', 'kitchen', 'wooden'], averageRating: 4.6, totalReviews: 32,
        totalSales: 67, views: 890, createdAt: DateTime(2023, 7, 15), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_3', storeId: 'st_1', artisanId: 'ap_1', name: 'Wooden Wall Clock',
        description: 'Hand-painted wooden wall clock with Rajasthani miniature art design.',
        price: 1599, discountPrice: 1399, category: 'Home Decor', subcategory: 'Clocks',
        imageUrls: ['assets/onboarding1.png'], stockQuantity: 15, isFeatured: false,
        craftType: 'Hand Painted', material: 'Sheesham Wood', weight: '500g', dimensions: '30x30x3 cm',
        tags: ['clock', 'wall', 'painted', 'rajasthani'], averageRating: 4.7, totalReviews: 28,
        totalSales: 45, views: 670, createdAt: DateTime(2023, 9, 20), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_4', storeId: 'st_2', artisanId: 'ap_2', name: 'Handwoven Dupatta',
        description: 'Pure cotton handwoven dupatta with traditional Rajasthani bandhani print.',
        price: 799, category: 'Textiles', subcategory: 'Dupatta',
        imageUrls: ['assets/onboarding2.png'], stockQuantity: 50, isFeatured: true,
        craftType: 'Handwoven', material: 'Pure Cotton', weight: '200g', dimensions: '2.5m x 0.7m',
        tags: ['dupatta', 'cotton', 'bandhani', 'handwoven'], averageRating: 4.9, totalReviews: 56,
        totalSales: 123, views: 1560, createdAt: DateTime(2023, 4, 10), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_5', storeId: 'st_2', artisanId: 'ap_2', name: 'Block Print Saree',
        description: 'Hand block printed cotton saree with natural dyes. Lightweight and elegant.',
        price: 2199, discountPrice: 1899, category: 'Textiles', subcategory: 'Saree',
        imageUrls: ['assets/onboarding2.png'], stockQuantity: 30, isFeatured: true,
        craftType: 'Block Print', material: 'Pure Cotton', weight: '400g', dimensions: '5.5m x 1.2m',
        tags: ['saree', 'blockprint', 'cotton', 'traditional'], averageRating: 4.7, totalReviews: 38,
        totalSales: 78, views: 980, createdAt: DateTime(2023, 8, 5), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_6', storeId: 'st_3', artisanId: 'ap_3', name: 'Blue Pottery Vase',
        description: 'Classic blue pottery flower vase with Persian-inspired floral design.',
        price: 1499, category: 'Pottery', subcategory: 'Vase',
        imageUrls: ['assets/onboarding3.png'], stockQuantity: 20, isFeatured: true,
        craftType: 'Blue Pottery', material: 'Multi-glaze Ceramic', weight: '1.2kg', dimensions: '25cm height',
        tags: ['vase', 'pottery', 'blue', 'jaipur'], averageRating: 4.6, totalReviews: 34,
        totalSales: 56, views: 780, createdAt: DateTime(2023, 6, 20), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_7', storeId: 'st_3', artisanId: 'ap_3', name: 'Blue Pottery Plate Set',
        description: 'Set of 4 blue pottery dinner plates with matching design.',
        price: 2499, discountPrice: 2199, category: 'Pottery', subcategory: 'Dinnerware',
        imageUrls: ['assets/onboarding3.png'], stockQuantity: 15, isFeatured: false,
        craftType: 'Blue Pottery', material: 'Multi-glaze Ceramic', weight: '3kg', dimensions: '25cm diameter each',
        tags: ['plates', 'dinnerware', 'set', 'blue'], averageRating: 4.5, totalReviews: 22,
        totalSales: 34, views: 560, createdAt: DateTime(2023, 10, 1), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_8', storeId: 'st_4', artisanId: 'ap_4', name: 'Kasavu Saree',
        description: 'Traditional Kerala Kasavu saree with real gold zari border. Pure handloom cotton.',
        price: 3499, category: 'Textiles', subcategory: 'Saree',
        imageUrls: ['assets/onboarding2.png'], stockQuantity: 12, isFeatured: true,
        craftType: 'Handloom', material: 'Pure Cotton with Gold Zari', weight: '500g', dimensions: '6m x 1.2m',
        tags: ['kasavu', 'saree', 'kerala', 'gold', 'handloom'], averageRating: 4.9, totalReviews: 42,
        totalSales: 67, views: 1120, createdAt: DateTime(2023, 8, 15), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_9', storeId: 'st_5', artisanId: 'ap_5', name: 'Brass Ganesha Idol',
        description: 'Handcrafted brass Ganesha idol with fine detailing. Perfect for puja room.',
        price: 1899, category: 'Brass', subcategory: 'Idol',
        imageUrls: ['assets/onboarding1.png'], stockQuantity: 18, isFeatured: true,
        craftType: 'Hand Cast', material: 'Pure Brass', weight: '1.5kg', dimensions: '20cm height',
        tags: ['ganesha', 'brass', 'idol', 'puja', 'handmade'], averageRating: 4.5, totalReviews: 28,
        totalSales: 45, views: 670, createdAt: DateTime(2024, 2, 1), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_10', storeId: 'st_6', artisanId: 'ap_6', name: 'Madhubani Canvas Painting',
        description: 'Authentic Madhubani painting on canvas depicting fish motif (fertility symbol).',
        price: 2799, discountPrice: 2499, category: 'Art', subcategory: 'Painting',
        imageUrls: ['assets/onboarding3.png'], stockQuantity: 10, isFeatured: true,
        craftType: 'Hand Painted', material: 'Canvas & Natural Dyes', weight: '300g', dimensions: '60x45 cm',
        tags: ['madhubani', 'painting', 'canvas', 'folkart', 'bihar'], averageRating: 4.8, totalReviews: 36,
        totalSales: 58, views: 890, createdAt: DateTime(2024, 3, 10), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_11', storeId: 'st_1', artisanId: 'ap_1', name: 'Wooden Spice Box',
        description: 'Traditional Indian spice box (masala dabba) with 7 compartments. Hand-carved.',
        price: 1199, category: 'Home Decor', subcategory: 'Kitchen',
        imageUrls: ['assets/onboarding1.png'], stockQuantity: 30, isFeatured: false,
        craftType: 'Hand Carved', material: 'Neem Wood', weight: '700g', dimensions: '22x22x8 cm',
        tags: ['spice', 'box', 'kitchen', 'masala', 'wooden'], averageRating: 4.4, totalReviews: 19,
        totalSales: 38, views: 450, createdAt: DateTime(2024, 1, 20), updatedAt: DateTime.now(),
      ),
      MarketplaceProduct(
        id: 'p_12', storeId: 'st_2', artisanId: 'ap_2', name: 'Handwoven Table Runner',
        description: 'Elegant handwoven table runner with geometric Rajasthani patterns.',
        price: 599, category: 'Textiles', subcategory: 'Home Textile',
        imageUrls: ['assets/onboarding2.png'], stockQuantity: 45, isFeatured: false,
        craftType: 'Handwoven', material: 'Cotton Blend', weight: '150g', dimensions: '1.8m x 0.35m',
        tags: ['runner', 'table', 'handwoven', 'decor'], averageRating: 4.6, totalReviews: 24,
        totalSales: 52, views: 380, createdAt: DateTime(2024, 4, 5), updatedAt: DateTime.now(),
      ),
    ];
    _products.addAll(products);

    // Collections
    final collectionData = [
      StoreCollection(
        id: 'col_1', storeId: 'st_1', name: 'Best Sellers', description: 'Our most loved wooden crafts',
        productIds: ['p_1', 'p_2'], sortOrder: 0, isFeatured: true, createdAt: DateTime(2023, 6, 1),
      ),
      StoreCollection(
        id: 'col_2', storeId: 'st_1', name: 'Home Decor', description: 'Transform your space with handcrafted wood',
        productIds: ['p_2', 'p_3', 'p_11'], sortOrder: 1, createdAt: DateTime(2023, 8, 1),
      ),
      StoreCollection(
        id: 'col_3', storeId: 'st_2', name: 'New Arrivals', description: 'Fresh from the loom',
        productIds: ['p_4', 'p_5', 'p_12'], sortOrder: 0, isFeatured: true, createdAt: DateTime(2023, 4, 1),
      ),
      StoreCollection(
        id: 'col_4', storeId: 'st_2', name: 'Festive Collection', description: 'Special pieces for Indian festivals',
        productIds: ['p_5'], sortOrder: 1, createdAt: DateTime(2023, 9, 1),
      ),
    ];
    _collections.addAll(collectionData);

    // Orders
    final now = DateTime.now();
    final orderData = [
      MarketplaceOrder(
        id: 'o_1', orderNumber: 'HK10231', buyerId: 'b_1', storeId: 'st_1', artisanId: 'ap_1',
        items: [OrderItem(id: 'oi_1', productId: 'p_1', productName: 'Wooden Jewelry Box', price: 1099, quantity: 1)],
        subtotal: 1099, shippingCost: 99, total: 1198, status: OrderStatus.delivered,
        paymentMethod: 'UPI', isPaid: true, createdAt: now.subtract(const Duration(days: 5)), updatedAt: now.subtract(const Duration(days: 2)),
      ),
      MarketplaceOrder(
        id: 'o_2', orderNumber: 'HK10232', buyerId: 'b_2', storeId: 'st_1', artisanId: 'ap_1',
        items: [OrderItem(id: 'oi_2', productId: 'p_2', productName: 'Carved Wooden Tray', price: 899, quantity: 2)],
        subtotal: 1798, shippingCost: 0, total: 1798, status: OrderStatus.processing,
        paymentMethod: 'Card', isPaid: true, createdAt: now.subtract(const Duration(days: 2)), updatedAt: now.subtract(const Duration(days: 1)),
      ),
      MarketplaceOrder(
        id: 'o_3', orderNumber: 'HK10233', buyerId: 'b_1', storeId: 'st_2', artisanId: 'ap_2',
        items: [OrderItem(id: 'oi_3', productId: 'p_4', productName: 'Handwoven Dupatta', price: 799, quantity: 1)],
        subtotal: 799, shippingCost: 79, total: 878, status: OrderStatus.shipped,
        paymentMethod: 'UPI', isPaid: true, createdAt: now.subtract(const Duration(days: 3)), updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      MarketplaceOrder(
        id: 'o_4', orderNumber: 'HK10234', buyerId: 'b_3', storeId: 'st_1', artisanId: 'ap_1',
        items: [
          OrderItem(id: 'oi_4', productId: 'p_1', productName: 'Wooden Jewelry Box', price: 1099, quantity: 1),
          OrderItem(id: 'oi_5', productId: 'p_3', productName: 'Wooden Wall Clock', price: 1399, quantity: 1),
        ],
        subtotal: 2498, shippingCost: 0, total: 2498, status: OrderStatus.pending,
        paymentMethod: 'COD', isPaid: false, createdAt: now.subtract(const Duration(hours: 6)), updatedAt: now,
      ),
    ];
    _orders.addAll(orderData);

    // Reviews
    final reviewData = [
      Review(id: 'r_1', buyerId: 'b_1', buyerName: 'Rahul Sharma', storeId: 'st_1', productId: 'p_1',
        rating: 5, comment: 'Absolutely beautiful craftsmanship! The jewelry box is even more stunning in person.',
        createdAt: now.subtract(const Duration(days: 4)), sellerReply: 'Thank you Rahul! Glad you love it.'),
      Review(id: 'r_2', buyerId: 'b_2', buyerName: 'Anita Patel', storeId: 'st_1', productId: 'p_2',
        rating: 4, comment: 'Great quality tray. The carving is intricate and well-finished.',
        createdAt: now.subtract(const Duration(days: 3))),
      Review(id: 'r_3', buyerId: 'b_3', buyerName: 'Vikram Reddy', storeId: 'st_2', productId: 'p_4',
        rating: 5, comment: 'The dupatta is gorgeous! Love the bandhani pattern and the cotton quality.',
        createdAt: now.subtract(const Duration(days: 2))),
      Review(id: 'r_4', buyerId: 'b_1', buyerName: 'Rahul Sharma', storeId: 'st_3', productId: 'p_6',
        rating: 5, comment: 'Stunning blue pottery vase. The color is rich and the design is authentic.',
        createdAt: now.subtract(const Duration(days: 1))),
      Review(id: 'r_5', buyerId: 'b_4', buyerName: 'Deepa Menon', storeId: 'st_4', productId: 'p_8',
        rating: 5, comment: 'The Kasavu saree is breathtaking. Real gold zari and perfect weaving.',
        createdAt: now.subtract(const Duration(hours: 18))),
    ];
    _reviews.addAll(reviewData);
  }
}
