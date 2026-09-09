import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';

class ArtisanProfileScreen extends StatelessWidget {
  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildCraftStory(),
            _buildSpecialities(),
            _buildBusinessDetails(),
            _buildAIAssistant(context),
            _buildSettingsMenu(context),
            _buildLogout(context),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xxl),
      color: AppColors.surface,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.warmBeige,
            child: Icon(Icons.person, size: 40, color: AppColors.brown),
          ),
          const SizedBox(height: AppDimensions.md),
          Text('Sita Devi', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text('Madhubani, Bihar', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, size: 16, color: AppColors.oliveGreen),
              const SizedBox(width: 4),
              Text('Verified Artisan', style: AppTextStyles.labelMedium.copyWith(color: AppColors.oliveGreen)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.terracotta),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Edit Profile', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
          ),
        ],
      ),
    );
  }

  Widget _buildCraftStory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Craft Story', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Text(
              'I create traditional handmade products inspired by the cultural heritage of Bihar.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text('Edit Story', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialities() {
    final specialties = ['Madhubani Art', 'Handloom', 'Natural Dyes', 'Handmade Textiles'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Specialities', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: specialties.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.warmBeige,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(s, style: AppTextStyles.labelMedium),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Row(
        children: [
          _bizStat('12', 'Products'),
          const SizedBox(width: AppDimensions.md),
          _bizStat('48', 'Orders'),
          const SizedBox(width: AppDimensions.md),
          _bizStat('36', 'Customers'),
          const SizedBox(width: AppDimensions.md),
          _bizStat('4.8', 'Rating'),
        ],
      ),
    );
  }

  Widget _bizStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistant(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.mustardGold.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 20),
                const SizedBox(width: AppDimensions.sm),
                Text('AI Business Assistant', style: AppTextStyles.titleMedium.copyWith(color: AppColors.mustardGold)),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text('Ask me how to improve your sales.', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.md),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: [
                _aiChip('Improve Listing', AppRoutes.smartCatalog, context),
                _aiChip('Find Markets', AppRoutes.marketLinkage, context),
                _aiChip('Suggest Price', AppRoutes.aiPricing, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiChip(String label, String route, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.mustardGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.mustardGold.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.mustardGold)),
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    final items = [
      Icons.settings_outlined,
      Icons.help_outline,
      Icons.language_outlined,
    ];
    final titles = ['Settings', 'Help & Support', 'Language'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            return Column(
              children: [
                ListTile(
                  leading: Icon(items[i], color: AppColors.charcoal),
                  title: Text(titles[i], style: AppTextStyles.bodyMedium),
                  trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {},
                ),
                if (i < items.length - 1) const Divider(height: 1, indent: 56),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Logout', style: AppTextStyles.titleMedium),
                content: Text('Are you sure you want to logout?', style: AppTextStyles.bodyMedium),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary))),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    },
                    child: Text('Logout', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
                  ),
                ],
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.terracotta),
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
          ),
          child: Text('Logout', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      onTap: (i) {
        final routes = [
          AppRoutes.artisanHome,
          AppRoutes.manageProducts,
          AppRoutes.artisanAddProduct,
          AppRoutes.artisanOrders,
          null,
        ];
        if (routes[i] != null) {
          Navigator.pushNamed(context, routes[i]!);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.terracotta,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add Product'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
