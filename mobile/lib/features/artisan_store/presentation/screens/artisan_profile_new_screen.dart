import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/data_service.dart';
import 'edit_profile_screen.dart';

class ArtisanProfileNewScreen extends StatefulWidget {
  const ArtisanProfileNewScreen({super.key});

  @override
  State<ArtisanProfileNewScreen> createState() => _ArtisanProfileNewScreenState();
}

class _ArtisanProfileNewScreenState extends State<ArtisanProfileNewScreen> {
  final DataService _data = DataService();

  ArtisanProfile? get _profile =>
      _data.artisanProfiles.isNotEmpty ? _data.artisanProfiles.first : null;

  ArtisanStore? get _store =>
      _data.stores.isNotEmpty ? _data.stores.first : null;

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final store = _store;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text('My Profile', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: profile == null
          ? _buildNoProfileState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                _buildProfileHeader(profile, store),
                if (profile.craftStory.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _buildStorySection(profile),
                ],
                if (profile.craftSpecialization.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _buildCraftSection(profile),
                ],
                _buildProductsPreview(store),
                const SizedBox(height: AppDimensions.lg),
                _buildJourneySection(profile),
                const SizedBox(height: AppDimensions.lg),
                _buildLogoutButton(),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppDimensions.lg),
            Text('Complete Your Profile', style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Tell buyers about yourself, your craft, and your story.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ArtisanProfile profile, ArtisanStore? store) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.terracotta.withValues(alpha: 0.15),
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.terracotta),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.name.isNotEmpty ? profile.name : 'Artisan',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold),
              ),
              if (profile.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, size: 20, color: AppColors.oliveGreen),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (profile.craftSpecialization.isNotEmpty)
            Text(
              '${profile.craftSpecialization} Artisan',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.terracotta),
            ),
          if (profile.location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  profile.state.isNotEmpty ? '${profile.location}, ${profile.state}' : profile.location,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          if (profile.yearsOfExperience > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${profile.yearsOfExperience} years of experience',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('Products', '${store?.totalProducts ?? 0}'),
              _buildDivider(),
              _buildStat('Followers', '${profile.followersCount}'),
              _buildDivider(),
              _buildStat('Rating', profile.averageRating > 0 ? profile.averageRating.toStringAsFixed(1) : '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: AppColors.borderLight);
  }

  Widget _buildStorySection(ArtisanProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_rounded, size: 18, color: AppColors.brown),
              const SizedBox(width: 8),
              Text('My Story', style: AppTextStyles.titleMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.warmBeige.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.15)),
            ),
            child: Text(
              profile.craftStory,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCraftSection(ArtisanProfile profile) {
    final items = <_CraftInfo>[];
    if (profile.craftSpecialization.isNotEmpty) {
      items.add(_CraftInfo('Craft', profile.craftSpecialization));
    }
    if (profile.location.isNotEmpty) {
      items.add(_CraftInfo('Origin', profile.state.isNotEmpty ? '${profile.location}, ${profile.state}' : profile.location));
    }
    if (profile.yearsOfExperience > 0) {
      items.add(_CraftInfo('Experience', '${profile.yearsOfExperience} years'));
    }
    if (profile.bio.isNotEmpty) {
      items.add(_CraftInfo('About', profile.bio));
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined, size: 18, color: AppColors.brown),
              const SizedBox(width: 8),
              Text('My Craft', style: AppTextStyles.titleMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(item.label, style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                    Expanded(
                      child: Text(item.value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsPreview(ArtisanStore? store) {
    if (store == null) return const SizedBox.shrink();
    final products = _data.getPublishedProductsByStore(store.id);
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.brown),
              const SizedBox(width: 8),
              Expanded(
                child: Text('My Products', style: AppTextStyles.titleMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  // Navigate handled by dashboard
                },
                child: const Text('View All', style: TextStyle(color: AppColors.terracotta)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length.clamp(0, 6),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _buildMiniProductCard(products[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProductCard(MarketplaceProduct product) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.warmBeige.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
              ),
              child: product.imageUrls.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
                      child: Image.network(product.imageUrls.first, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textSecondary)),
                    )
                  : const Icon(Icons.image_outlined, color: AppColors.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('₹${product.effectivePrice.toInt()}', style: TextStyle(fontSize: 11, color: AppColors.brown, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneySection(ArtisanProfile profile) {
    final items = <_JourneyItem>[];
    items.add(_JourneyItem(Icons.school_outlined, 'Learned Craft', 'Started learning traditional skills'));
    if (profile.yearsOfExperience > 0) {
      items.add(_JourneyItem(Icons.build_circle_outlined, 'Started Creating', '${profile.yearsOfExperience}+ years of practice'));
    }
    items.add(_JourneyItem(Icons.verified_outlined, 'Experience', '${profile.yearsOfExperience} years of expertise'));
    items.add(_JourneyItem(Icons.store_outlined, 'HastKala Journey', 'Selling on HastKala marketplace'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, size: 18, color: AppColors.brown),
              const SizedBox(width: 8),
              Text('My Craft Journey', style: AppTextStyles.titleMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == items.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(item.icon, size: 18, color: AppColors.terracotta),
                    if (!isLast) ...[
                      const SizedBox(height: 4),
                      Container(width: 2, height: 24, color: AppColors.terracotta.withValues(alpha: 0.2)),
                    ],
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                        Text(item.subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            title: Text('Sign Out', style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal)),
            content: Text('Are you sure you want to sign out?', style: AppTextStyles.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await AuthService().signOut();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Sign Out', style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error, fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}

class _CraftInfo {
  final String label;
  final String value;
  const _CraftInfo(this.label, this.value);
}

class _JourneyItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _JourneyItem(this.icon, this.title, this.subtitle);
}
