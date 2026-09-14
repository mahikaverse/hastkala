import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/product_card.dart';
import 'product_details_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _selectedCategory = 0;
  String _selectedSort = 'Recommended';
  final Set<int> _wishlist = {};

  final List<String> _categories = ['All', 'Pottery', 'Textiles', 'Woodwork', 'Jewellery', 'Home Decor'];

  List<Product> get _filteredProducts {
    var list = MockProducts.byCategory(_categories[_selectedCategory]);
    switch (_selectedSort) {
      case 'Price: Low to High':
        list = List.from(list)..sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        list = List.from(list)..sort((a, b) => b.price.compareTo(a.price));
      case 'Newest':
        list = list.reversed.toList();
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lang.t('buyerAllProducts'), style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune, size: 20)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(lang),
          _buildCategoryChips(lang),
          _buildSortBar(lang),
          Expanded(child: _buildProductGrid(lang)),
        ],
      ),
    );
  }

  Widget _buildSearchField(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: TextField(
        decoration: InputDecoration(
          hintText: lang.t('buyerSearchProducts'),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            borderSide: const BorderSide(color: AppColors.terracotta),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(LanguageProvider lang) {
    final categoryLabels = [lang.t('buyerAll'), lang.t('buyerPottery'), lang.t('buyerTextiles'), lang.t('buyerWoodwork'), lang.t('buyerJewellery'), lang.t('buyerHomeDecor')];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.terracotta : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: isSelected ? AppColors.terracotta : AppColors.border),
              ),
              child: Text(
                categoryLabels[index],
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.cream : AppColors.charcoal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBar(LanguageProvider lang) {
    String sortDisplayName(String key) {
      switch (key) {
        case 'Recommended': return lang.t('buyerRecommended');
        case 'Price: Low to High': return lang.t('buyerPriceLowHigh');
        case 'Price: High to Low': return lang.t('buyerPriceHighLow');
        case 'Newest': return lang.t('buyerNewest');
        case 'Popular': return lang.t('buyerPopular');
        default: return key;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
      child: Row(
        children: [
          Text(lang.t('buyerSort'), style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppDimensions.sm),
          GestureDetector(
            onTap: () => _showSortSheet(lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sortDisplayName(_selectedSort), style: AppTextStyles.labelMedium),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.charcoal),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('${_filteredProducts.length}${lang.t('buyerItems')}', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  void _showSortSheet(LanguageProvider lang) {
    final sortKeys = ['Recommended', 'Price: Low to High', 'Price: High to Low', 'Newest', 'Popular'];
    final sortLabels = [lang.t('buyerRecommended'), lang.t('buyerPriceLowHigh'), lang.t('buyerPriceHighLow'), lang.t('buyerNewest'), lang.t('buyerPopular')];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.md),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: AppDimensions.lg),
              Text(lang.t('buyerSortBy'), style: AppTextStyles.titleMedium),
              ...List.generate(sortKeys.length, (index) => RadioListTile<String>(
                    title: Text(sortLabels[index], style: AppTextStyles.bodyMedium),
                    value: sortKeys[index],
                    groupValue: _selectedSort,
                    activeColor: AppColors.terracotta,
                    onChanged: (v) {
                      setState(() => _selectedSort = v!);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(LanguageProvider lang) {
    final products = _filteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.warmBeige),
              const SizedBox(height: AppDimensions.lg),
              Text(lang.t('buyerNoProducts'), style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppDimensions.sm),
              Text(lang.t('buyerTryDifferent'), style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.md,
        crossAxisSpacing: AppDimensions.md,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          isWished: _wishlist.contains(product.id),
          onWishlistTap: () => setState(() {
            _wishlist.contains(product.id)
                ? _wishlist.remove(product.id)
                : _wishlist.add(product.id);
          }),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
