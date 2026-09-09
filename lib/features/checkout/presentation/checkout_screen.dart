import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'UPI';

  final List<_CheckoutItem> _items = [
    _CheckoutItem(product: MockProducts.all[0], quantity: 1),
    _CheckoutItem(product: MockProducts.all[1], quantity: 1),
  ];

  int get _subtotal => _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  int get _shipping => 100;
  int get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: AppDimensions.xxl),
            _buildDeliveryAddress(),
            const SizedBox(height: AppDimensions.xxl),
            _buildPaymentMethod(),
            const SizedBox(height: AppDimensions.xxl),
            _buildOrderSummary(),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _step(0, 'Address'),
        _stepLine(),
        _step(1, 'Payment'),
        _stepLine(),
        _step(2, 'Review'),
      ],
    );
  }

  Widget _step(int index, String label) {
    final isActive = index <= 1;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.terracotta : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: isActive ? AppColors.terracotta : AppColors.border),
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check, size: 16, color: AppColors.cream)
                : Text('${index + 1}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: isActive ? AppColors.terracotta : AppColors.textSecondary)),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: AppColors.divider,
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Address', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Icon(Icons.home_outlined, color: AppColors.terracotta, size: 22),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ananya Sharma', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text('123, Green Park, Near City Mall\nMumbai, Maharashtra - 400001', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 2),
                    Text('+91 98765 43210', style: AppTextStyles.bodySmall.copyWith(color: AppColors.terracotta)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Change', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    final methods = [
      _PaymentOption('UPI', 'GPay, PhonePe, Paytm', Icons.account_balance_wallet_outlined),
      _PaymentOption('Credit / Debit Card', 'Visa, Mastercard, RuPay', Icons.credit_card_outlined),
      _PaymentOption('Net Banking', 'All major banks', Icons.account_balance_outlined),
      _PaymentOption('Cash on Delivery', 'Pay when delivered', Icons.money_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        ...methods.map((m) => _paymentOption(m)),
      ],
    );
  }

  Widget _paymentOption(_PaymentOption option) {
    final isSelected = _selectedPayment == option.title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = option.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: isSelected ? AppColors.terracotta : AppColors.borderLight, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: option.title,
              groupValue: _selectedPayment,
              activeColor: AppColors.terracotta,
              onChanged: (v) => setState(() => _selectedPayment = v!),
            ),
            Icon(option.icon, color: isSelected ? AppColors.terracotta : AppColors.textSecondary, size: 24),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: AppTextStyles.titleSmall),
                  Text(option.subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        ..._items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item.product.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  cacheWidth: 100,
                  cacheHeight: 100,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    color: AppColors.warmBeige,
                    child: Icon(Icons.handyman_outlined, size: 20, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: Text('${item.product.name} x${item.quantity}', style: AppTextStyles.bodyMedium)),
              Text('\u20B9${item.product.price * item.quantity}', style: AppTextStyles.bodyMedium),
            ],
          ),
        )),
        const Divider(color: AppColors.divider, height: AppDimensions.xxl),
        _priceRow('Subtotal', '\u20B9$_subtotal'),
        const SizedBox(height: AppDimensions.sm),
        _priceRow('Shipping', '\u20B9$_shipping'),
        const Divider(color: AppColors.divider, height: AppDimensions.xxl),
        _priceRow('Total', '\u20B9$_total', isBold: true),
      ],
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

  Widget _buildBottomButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.buyerHome, (route) => false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.terracotta,
            foregroundColor: AppColors.cream,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
          ),
          child: Text('Continue to Payment', style: AppTextStyles.buttonLarge.copyWith(color: AppColors.cream)),
        ),
      ),
    );
  }
}

class _CheckoutItem {
  final Product product;
  final int quantity;
  const _CheckoutItem({required this.product, required this.quantity});
}

class _PaymentOption {
  final String title;
  final String subtitle;
  final IconData icon;
  const _PaymentOption(this.title, this.subtitle, this.icon);
}
