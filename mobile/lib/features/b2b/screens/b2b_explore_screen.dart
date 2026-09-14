import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/craft_image_helper.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/models/marketplace_product.dart';
import '../services/b2b_service.dart';
import 'b2b_product_detail_screen.dart';


class B2BExploreScreen extends StatefulWidget {
  final String? initialSearch;
  final String? initialCategory;

  const B2BExploreScreen({super.key, this.initialSearch, this.initialCategory});

  @override
  State<B2BExploreScreen> createState() => _B2BExploreScreenState();
}

class _B2BExploreScreenState extends State<B2BExploreScreen> {
  final B2BService _service = B2BService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCraftType;
  bool _isLoading = true;
  bool _showFilters = false;
  List<MarketplaceProduct> _products = [];
  List<String> _categories = [];
  List<String> _craftTypes = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
    }
    _selectedCategory = widget.initialCategory;
    _loadFiltersAndProducts();
  }

  Future<void> _loadFiltersAndProducts() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _service.getCategories(),
      _service.getCraftTypes(),
    ]);
    _categories = results[0];
    _craftTypes = results[1];
    await _searchProducts();
  }

  Future<void> _searchProducts() async {
    setState(() => _isLoading = true);
    final products = await _service.exploreProducts(
      category: _selectedCategory,
      craftType: _selectedCraftType,
      minPrice: double.tryParse(_minPriceController.text),
      maxPrice: double.tryParse(_maxPriceController.text),
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: Column(
          children: [
            // Search + filter header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.brown.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _searchProducts(),
                        decoration: InputDecoration(
                          hintText: lang.t('b2bSearchProducts'),
                          hintStyle: TextStyle(
                            color: AppColors.brown.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.terracotta.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: _showFilters
                            ? AppColors.terracotta
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showFilters
                              ? AppColors.terracotta
                              : AppColors.brown.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: _showFilters
                            ? Colors.white
                            : AppColors.brown.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filters panel
            if (_showFilters)
              Flexible(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brown.withValues(alpha: 0.1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Text(
                          lang.t('b2bCategory'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brown.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildFilterChip(
                              lang.t('b2bAll'),
                              _selectedCategory == null,
                              () => setState(() => _selectedCategory = null),
                            ),
                            ..._categories.map((c) => _buildFilterChip(
                              c,
                              _selectedCategory == c,
                              () => setState(() => _selectedCategory = c),
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Craft Type
                        Text(
                          lang.t('b2bCraftType'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brown.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildFilterChip(
                              lang.t('b2bAll'),
                              _selectedCraftType == null,
                              () => setState(() => _selectedCraftType = null),
                            ),
                            ..._craftTypes.map((c) => _buildFilterChip(
                              c,
                              _selectedCraftType == c,
                              () => setState(() => _selectedCraftType = c),
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Price range
                        Text(
                          lang.t('b2bPriceRange'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brown.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: lang.t('b2bMinPrice'),
                                  hintStyle: TextStyle(
                                    color: AppColors.brown.withValues(alpha: 0.4),
                                    fontSize: 13,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.brown.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.brown.withValues(alpha: 0.15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('-', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _maxPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: lang.t('b2bMaxPrice'),
                                  hintStyle: TextStyle(
                                    color: AppColors.brown.withValues(alpha: 0.4),
                                    fontSize: 13,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.brown.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.brown.withValues(alpha: 0.15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Search button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _searchProducts();
                              setState(() => _showFilters = false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.terracotta,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              lang.t('b2bApplyFilters'),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Results count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Text(
                    '${_products.length}${lang.t('b2bProductsFound')}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.brown.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Product grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.terracotta),
                    )
                  : _products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.brown.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                lang.t('b2bNoProducts'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brown.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                lang.t('b2bTryDifferent'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.brown.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _searchProducts,
                          color: AppColors.terracotta,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return _buildProductCard(product);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.terracotta
              : AppColors.cream.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.terracotta
                : AppColors.brown.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.white
                : AppColors.brown.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product) {
    final lang = LanguageProvider.of(context);
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
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7EFE2),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Builder(
                    builder: (context) {
                      final firstImage = product.imageUrls.isNotEmpty ? product.imageUrls.first.trim() : '';
                      final hasNetworkImage = firstImage.isNotEmpty &&
                          (firstImage.startsWith('http://') || firstImage.startsWith('https://'));
                      final fallbackAsset = CraftImageHelper.getImageForProduct(
                        productId: product.id,
                        craftType: product.craftType,
                        category: product.category,
                        name: product.name,
                      );

                      return hasNetworkImage
                          ? Image.network(
                              firstImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xFFF7EFE2),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.terracotta.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Image.asset(
                                fallbackAsset,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFF7EFE2),
                                  child: const Center(
                                    child: Icon(Icons.palette_outlined, size: 32, color: AppColors.terracotta),
                                  ),
                                ),
                              ),
                            )
                          : Image.asset(
                              fallbackAsset,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF7EFE2),
                                child: const Center(
                                  child: Icon(Icons.palette_outlined, size: 32, color: AppColors.terracotta),
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
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
                    const SizedBox(height: 3),
                    if ((product.craftType ?? '').isNotEmpty)
                      Text(
                        product.craftType ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.oliveGreen.withValues(alpha: 0.7),
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracotta,
                          ),
                        ),
                        Text(
                          lang.t('b2bPerPc'),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.brown.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    if (product.stockQuantity > 0)
                      Text(
                        '${lang.t('b2bMoq')}${product.stockQuantity}${lang.t('b2bPcs')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
