import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/craft_image_helper.dart';
import '../../../core/models/artisan_profile.dart';
import '../../../core/models/marketplace_product.dart';
import '../services/b2b_service.dart';
import 'b2b_product_detail_screen.dart';
import 'b2b_enquiry_form_screen.dart';

class B2BArtisanProfileScreen extends StatefulWidget {
  final ArtisanProfile artisan;

  const B2BArtisanProfileScreen({super.key, required this.artisan});

  @override
  State<B2BArtisanProfileScreen> createState() => _B2BArtisanProfileScreenState();
}

class _B2BArtisanProfileScreenState extends State<B2BArtisanProfileScreen> {
  final B2BService _service = B2BService();
  bool _isSaved = false;
  List<MarketplaceProduct> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _checkSaved();
    _loadProducts();
  }

  Future<void> _checkSaved() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final saved = await _service.isArtisanSaved(userId, widget.artisan.id);
      setState(() => _isSaved = saved);
    }
  }

  Future<void> _loadProducts() async {
    final products = await _service.exploreProducts();
    final artisanProducts = products.where((p) => p.artisanId == widget.artisan.id).toList();
    setState(() {
      _products = artisanProducts;
      _isLoadingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final artisan = widget.artisan;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          artisan.name,
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppColors.terracotta : AppColors.brown.withValues(alpha: 0.5),
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
                    child: Text(
                      artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    artisan.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  if (artisan.craftSpecialization.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      artisan.craftSpecialization,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.oliveGreen,
                      ),
                    ),
                  ],
                  if (artisan.location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          artisan.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.brown.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _buildStat('Products', '${_products.length}'),
                  const SizedBox(width: 12),
                  _buildStat('Rating', artisan.averageRating > 0 ? artisan.averageRating.toStringAsFixed(1) : '-'),
                  const SizedBox(width: 12),
                  _buildStat('Experience', artisan.yearsOfExperience > 0 ? '${artisan.yearsOfExperience}yr' : '-'),
                ],
              ),
            ),

            // Bio
            if (artisan.bio.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      artisan.bio,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.brown.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Specialization
            if (artisan.craftSpecialization.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Specialization',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.oliveGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            artisan.craftSpecialization,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.oliveGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Products
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Products (${_products.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown,
                ),
              ),
            ),

            if (_isLoadingProducts)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.terracotta),
                ),
              )
            else if (_products.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No products listed yet',
                    style: TextStyle(
                      color: AppColors.brown.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = _products[index];
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
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.brown.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.cream,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: product.imageUrls.isNotEmpty
                                      ? Image.network(
                                          product.imageUrls.first,
                                          fit: BoxFit.cover,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brown,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${product.price.toStringAsFixed(0)}/pc',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.terracotta,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => B2BEnquiryFormScreen(
                        artisanId: artisan.id,
                        artisanName: artisan.name,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Enquiry',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.terracotta,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.brown.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSave() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    if (_isSaved) {
      await _service.unsaveArtisan(userId, widget.artisan.id);
    } else {
      await _service.saveArtisan(userId, widget.artisan.id);
    }
    setState(() => _isSaved = !_isSaved);
  }
}
