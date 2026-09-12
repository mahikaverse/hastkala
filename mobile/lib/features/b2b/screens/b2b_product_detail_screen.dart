import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/craft_image_helper.dart';
import '../../../core/models/marketplace_product.dart';
import '../services/b2b_service.dart';
import 'b2b_enquiry_form_screen.dart';
import 'b2b_artisan_profile_screen.dart';
import 'compare_screen.dart';

class B2BProductDetailScreen extends StatefulWidget {
  final MarketplaceProduct product;

  const B2BProductDetailScreen({super.key, required this.product});

  @override
  State<B2BProductDetailScreen> createState() => _B2BProductDetailScreenState();
}

class _B2BProductDetailScreenState extends State<B2BProductDetailScreen> {
  final B2BService _service = B2BService();
  bool _isSaved = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null && widget.product.artisanId.isNotEmpty) {
      final saved = await _service.isArtisanSaved(userId, widget.product.artisanId);
      setState(() => _isSaved = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
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
          product.name,
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.favorite : Icons.favorite_border,
              color: _isSaved ? AppColors.terracotta : AppColors.brown.withValues(alpha: 0.5),
            ),
            onPressed: _toggleSave,
          ),
          IconButton(
            icon: Icon(Icons.share, color: AppColors.brown.withValues(alpha: 0.6)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image gallery
            if (product.imageUrls.isNotEmpty)
              SizedBox(
                height: 280,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        itemCount: product.imageUrls.length,
                        onPageChanged: (i) => setState(() => _selectedImageIndex = i),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                product.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
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
                          );
                        },
                      ),
                    ),
                    if (product.imageUrls.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            product.imageUrls.length,
                            (i) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _selectedImageIndex
                                    ? AppColors.terracotta
                                    : AppColors.brown.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Product info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price + stock
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracotta,
                          ),
                        ),
                      ),
                      Text(
                        ' /piece',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                      const Spacer(),
                      if (product.stockQuantity > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.oliveGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'MOQ: ${product.stockQuantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.oliveGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tags
                    Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if ((product.craftType ?? '').isNotEmpty)
                        _buildTag(product.craftType ?? '', AppColors.oliveGreen),
                      if ((product.material ?? '').isNotEmpty)
                        _buildTag(product.material ?? '', AppColors.mustardGold),
                      if (product.category.isNotEmpty)
                        _buildTag(product.category, AppColors.terracotta),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.brown.withValues(alpha: 0.7),
                    ),
                  ),

                  // Delivery info
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cream.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, color: AppColors.oliveGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Delivery negotiable • Bulk orders welcome',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.brown.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
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
        child: SafeArea(
          child: Row(
            children: [
              // Compare
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompareScreen(
                        initialProduct: product,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mustardGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.compare_arrows,
                    color: AppColors.mustardGold,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Request bulk quote
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => B2BEnquiryFormScreen(
                          product: product,
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
                    'Bulk Quote',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contact
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (product.artisanId.isNotEmpty) {
                      _loadArtisanAndNavigate(product.artisanId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.oliveGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Contact',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Future<void> _toggleSave() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    if (_isSaved) {
      await _service.unsaveArtisan(userId, widget.product.artisanId);
    } else {
      await _service.saveArtisan(userId, widget.product.artisanId);
    }
    setState(() => _isSaved = !_isSaved);
  }

  Future<void> _loadArtisanAndNavigate(String artisanId) async {
    final artisan = await _service.getArtisan(artisanId);
    if (artisan != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => B2BArtisanProfileScreen(artisan: artisan),
        ),
      );
    }
  }
}
