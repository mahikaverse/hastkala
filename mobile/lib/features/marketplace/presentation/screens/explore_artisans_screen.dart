import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';

class ExploreArtisansScreen extends StatefulWidget {
  const ExploreArtisansScreen({super.key});

  @override
  State<ExploreArtisansScreen> createState() => _ExploreArtisansScreenState();
}

class _ExploreArtisansScreenState extends State<ExploreArtisansScreen> {
  final DataService _data = DataService();
  final TextEditingController _searchController = TextEditingController();
  List<ArtisanStore> _stores = [];
  String _selectedCategory = 'All';
  String _selectedState = 'All';

  final List<String> _categories = [
    'All', 'Wood Carving', 'Handloom Weaving', 'Blue Pottery',
    'Kasavu Weaving', 'Brass Work', 'Madhubani Painting',
  ];

  @override
  void initState() {
    super.initState();
    _stores = _data.stores;
  }

  void _filterStores() {
    setState(() {
      _stores = _data.stores.where((s) {
        final matchesSearch = _searchController.text.isEmpty ||
            s.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            s.craftCategory.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            s.location.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' || s.craftCategory == _selectedCategory;
        final matchesState = _selectedState == 'All' || s.state == _selectedState;
        return matchesSearch && matchesCategory && matchesState;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildArtisanList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xxl, 16, AppDimensions.xxl, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Text(
              'Explore Artisans',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brown),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xxl, 16, AppDimensions.xxl, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _filterStores(),
        decoration: InputDecoration(
          hintText: 'Search artisans, crafts, locations...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl, vertical: 10),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat, style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.cream : AppColors.charcoal)),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedCategory = cat);
              _filterStores();
            },
            selectedColor: AppColors.terracotta,
            backgroundColor: AppColors.surface,
            side: BorderSide(color: isSelected ? AppColors.terracotta : AppColors.borderLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildArtisanList() {
    if (_stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: AppColors.warmBeige),
            const SizedBox(height: 16),
            Text('No artisans found', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Try adjusting your search or filters', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      itemCount: _stores.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.md),
      itemBuilder: (context, index) => _buildArtisanCard(_stores[index]),
    );
  }

  Widget _buildArtisanCard(ArtisanStore store) {
    final profile = _data.getArtisanProfile(store.artisanId);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/artisan-store', arguments: store.slug),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Profile image
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                color: AppColors.warmBeige,
              ),
              child: profile?.avatarUrl.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      child: Image.asset(profile!.avatarUrl, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person, size: 36, color: AppColors.brown),
            ),
            const SizedBox(width: AppDimensions.lg),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(store.name,
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brown, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (store.isVerified)
                        const Icon(Icons.verified, size: 16, color: AppColors.oliveGreen),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(store.craftCategory,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text('${store.location}, ${store.state}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.mustardGold),
                      const SizedBox(width: 2),
                      Text(store.averageRating.toStringAsFixed(1),
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.brown)),
                      const SizedBox(width: 8),
                      Text('${store.totalProducts} products',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
