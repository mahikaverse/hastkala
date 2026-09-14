import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/models/product_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<_CartItem> _items = [
    _CartItem(product: MockProducts.all[0], quantity: 1),
    _CartItem(product: MockProducts.all[1], quantity: 1),
    _CartItem(product: MockProducts.all[2], quantity: 1),
  ];

  int get _subtotal => _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  int get _shipping => _items.isEmpty ? 0 : 100;
  int get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${lang.t('myCart')} (${_items.length})', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _items.clear()),
              child: Text(lang.t('clearAll'), style: AppTextStyles.labelMedium.copyWith(color: AppColors.cream)),
            ),
        ],
      ),
      body: _items.isEmpty ? _buildEmptyState() : _buildCartContent(),
      bottomNavigationBar: _items.isEmpty ? null : _buildCheckoutButton(),
    );
  }

  Widget _buildEmptyState() {
    final lang = LanguageProvider.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.warmBeige),
            const SizedBox(height: AppDimensions.xl),
            Text(lang.t('cartEmpty'), textAlign: TextAlign.center, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppDimensions.xxl),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.productListing),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: AppColors.cream,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl, vertical: AppDimensions.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              ),
              child: Text(lang.t('exploreCrafts'), style: AppTextStyles.buttonMedium.copyWith(color: AppColors.cream)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(_items.length, (i) => _buildCartItem(i)),
          const SizedBox(height: AppDimensions.xxl),
          _buildPriceDetails(),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: Image.network(
              item.product.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              cacheWidth: 200,
              cacheHeight: 200,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: AppColors.warmBeige,
                child: Icon(Icons.handyman_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('\u20B9${item.product.price * item.quantity}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _qtyButton(Icons.remove, () {
                      setState(() {
                        if (item.quantity > 1) {
                          item.quantity--;
                        } else {
                          _items.removeAt(index);
                        }
                      });
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                      child: Text('${item.quantity}', style: AppTextStyles.titleSmall),
                    ),
                    _qtyButton(Icons.add, () => setState(() => item.quantity++)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _items.removeAt(index)),
                      icon: Icon(Icons.delete_outline, size: 20, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.warmBeige,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Icon(icon, size: 16, color: AppColors.charcoal),
      ),
    );
  }

  Widget _buildPriceDetails() {
    final lang = LanguageProvider.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('priceDetails'), style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          _priceRow(lang.t('subtotal'), '\u20B9$_subtotal'),
          const SizedBox(height: AppDimensions.sm),
          _priceRow(lang.t('shipping'), '\u20B9$_shipping'),
          const Divider(color: AppColors.divider, height: AppDimensions.xxl),
          _priceRow(lang.t('total'), '\u20B9$_total', isBold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium),
        Text(value, style: (isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium).copyWith(color: isBold ? AppColors.terracotta : null)),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    final lang = LanguageProvider.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.terracotta,
            foregroundColor: AppColors.cream,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
          ),
          child: Text('${lang.t('proceedToCheckout')} (\u20B9$_total)', style: AppTextStyles.buttonLarge.copyWith(color: AppColors.cream)),
        ),
      ),
    );
  }
}

class _CartItem {
  final Product product;
  int quantity;
  _CartItem({required this.product, required this.quantity});
}
