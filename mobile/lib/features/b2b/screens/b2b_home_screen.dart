import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/craft_image_helper.dart';
import '../../../core/models/marketplace_product.dart';
import '../../../core/models/artisan_profile.dart';
import '../services/b2b_service.dart';
import 'b2b_explore_screen.dart';
import 'b2b_requirement_form_screen.dart';
import 'b2b_product_detail_screen.dart';
import 'b2b_artisan_profile_screen.dart';

class B2BHomeScreen extends StatefulWidget {
  const B2BHomeScreen({super.key});

  @override
  State<B2BHomeScreen> createState() => _B2BHomeScreenState();
}

class _B2BHomeScreenState extends State<B2BHomeScreen> {
  final B2BService _service = B2BService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<MarketplaceProduct> _featuredProducts = [];
  List<ArtisanProfile> _topArtisans = [];
  Map<String, int> _stats = {};
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final results = await Future.wait([
        _service.exploreProducts(),
        _service.getArtisans(),
        userId.isNotEmpty ? _service.getBuyerStats(userId) : Future.value(<String, int>{}),
        _service.getCategories(),
      ]);
      setState(() {
        _featuredProducts = results[0] as List<MarketplaceProduct>;
        _topArtisans = results[1] as List<ArtisanProfile>;
        _stats = results[2] as Map<String, int>;
        _categories = results[3] as List<String>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with logo
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/horizontal-logo.png',
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(
                              'HastKala B2B',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brown,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Connect with artisan manufacturers',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.brown.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.brown.withValues(alpha: 0.7),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brown.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => B2BExploreScreen(initialSearch: value.trim()),
                          ),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products, artisans, crafts...',
                      hintStyle: TextStyle(
                        color: AppColors.brown.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.terracotta.withValues(alpha: 0.6),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: AppColors.terracotta.withValues(alpha: 0.6),
                        ),
                        onPressed: () {},
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard('Req', _stats['requirements'] ?? 3, AppColors.terracotta)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Enq', _stats['enquiries'] ?? 7, AppColors.oliveGreen)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Orders', _stats['orders'] ?? 5, AppColors.mustardGold)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Saved', _stats['saved'] ?? 12, AppColors.brown)),
                  ],
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const B2BExploreScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: _categories.isNotEmpty
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => B2BExploreScreen(initialCategory: cat),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.brown.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: AppColors.brown,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        children: [
                          _buildDefaultCategory('Home Decor'),
                          const SizedBox(width: 10),
                          _buildDefaultCategory('Kitchen & Dining'),
                          const SizedBox(width: 10),
                          _buildDefaultCategory('Pottery & Ceramics'),
                          const SizedBox(width: 10),
                          _buildDefaultCategory('Textiles'),
                          const SizedBox(width: 10),
                          _buildDefaultCategory('Jewelry'),
                        ],
                      ),
              ),
            ),

            // Quick Post Requirement
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const B2BRequirementFormScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.terracotta,
                          AppColors.terracotta.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.terracotta.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_task,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Post a Requirement',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tell artisans what you need, get quotes fast',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Featured Products
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const B2BExploreScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.terracotta),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: _featuredProducts.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _featuredProducts.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final product = _featuredProducts[index];
                            return _buildProductCard(product);
                          },
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _buildDemoProductCard('Handcrafted Artwork', 100, 'Handicraft'),
                            const SizedBox(width: 14),
                            _buildDemoProductCard('Handcrafted Craft', 50, 'Handicraft'),
                            const SizedBox(width: 14),
                            _buildDemoProductCard('Handpainted Vase', 450, 'Ceramics'),
                            const SizedBox(width: 14),
                            _buildDemoProductBlock('Terracotta Pot', 350, 'Pottery'),
                          ],
                        ),
                ),
              ),

            // Top Artisans
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Top Artisans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 190,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
                    : _topArtisans.isNotEmpty
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _topArtisans.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final artisan = _topArtisans[index];
                              return _buildArtisanCard(artisan);
                            },
                          )
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildDemoArtisanCard('Ramesh Kumar', 'Blue Pottery', 'Jaipur, Rajasthan', 'R'),
                              const SizedBox(width: 14),
                              _buildDemoArtisanCard('Sita Nair', 'Woodcarving', 'Thrissur, Kerala', 'S'),
                              const SizedBox(width: 14),
                              _buildDemoArtisanCard('Arjun Boro', 'Bamboo & Cane', 'Guwahati, Assam', 'A'),
                              const SizedBox(width: 14),
                              _buildDemoArtisanCard('Meera Sharma', 'Block Printing', 'Jaipur, Rajasthan', 'M'),
                            ],
                          ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCategory(String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BExploreScreen(initialCategory: label),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.brown,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoProductCard(String name, int price, String craft) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.asset(
                  'assets/default-bg.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/piece',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    craft,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.oliveGreen.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoProductBlock(String name, int price, String craft) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.asset(
                  'assets/default-bg.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/piece',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    craft,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.oliveGreen.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product, {double width = 160}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: (product.imageUrls.isNotEmpty)
                    ? Image.network(
                        product.imageUrls.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Image.asset(
                          CraftImageHelper.getImageForProduct(
                            productId: product.id,
                            craftType: product.craftType,
                            category: product.category,
                            name: product.name,
                          ),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Image.asset(
                        CraftImageHelper.getImageForProduct(
                          productId: product.id,
                          craftType: product.craftType,
                          category: product.category,
                          name: product.name,
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/piece',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  if ((product.craftType ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.craftType ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.oliveGreen.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisanCard(ArtisanProfile artisan, {double width = 130}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BArtisanProfileScreen(artisan: artisan),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
              child: Text(
                artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.terracotta,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                artisan.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            if (artisan.craftSpecialization.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  artisan.craftSpecialization,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.oliveGreen.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (artisan.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: AppColors.brown.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        artisan.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoArtisanCard(String name, String craft, String location, String initial) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.terracotta,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                craft,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.oliveGreen.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 10,
                    color: AppColors.brown.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.brown.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
