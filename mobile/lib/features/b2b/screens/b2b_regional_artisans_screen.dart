import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/artisan_image_helper.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/models/artisan_profile.dart';
import '../services/b2b_service.dart';
import 'b2b_artisan_profile_screen.dart';

class B2BRegionalArtisansScreen extends StatefulWidget {
  final String? buyerCity;
  final String? buyerState;

  const B2BRegionalArtisansScreen({
    super.key,
    this.buyerCity,
    this.buyerState,
  });

  @override
  State<B2BRegionalArtisansScreen> createState() => _B2BRegionalArtisansScreenState();
}

class _B2BRegionalArtisansScreenState extends State<B2BRegionalArtisansScreen> {
  final B2BService _service = B2BService();
  bool _isLoading = true;
  List<ArtisanProfile> _artisans = [];
  _RegionFilter _selectedFilter = _RegionFilter.city;

  late String _currentCity;
  late String _currentState;

  @override
  void initState() {
    super.initState();
    _currentCity = (widget.buyerCity != null && widget.buyerCity!.isNotEmpty)
        ? widget.buyerCity!
        : 'Jaipur';
    _currentState = (widget.buyerState != null && widget.buyerState!.isNotEmpty)
        ? widget.buyerState!
        : 'Rajasthan';
    _loadArtisans();
  }

  Future<void> _loadArtisans() async {
    setState(() => _isLoading = true);
    try {
      List<ArtisanProfile> results;
      switch (_selectedFilter) {
        case _RegionFilter.city:
          results = await _service.getArtisans(location: _currentCity);
          break;
        case _RegionFilter.nearby:
          results = await _service.getArtisansByRegion(city: null, state: _currentState);
          break;
        case _RegionFilter.state:
          results = await _service.getArtisans();
          break;
      }
      if (mounted) setState(() => _artisans = results);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _switchFilter(_RegionFilter filter) {
    setState(() => _selectedFilter = filter);
    _loadArtisans();
  }

  void _showCityPicker() {
    final controller = TextEditingController(text: _currentCity);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.brown.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select City',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type city name...',
                hintStyle: TextStyle(color: AppColors.brown.withValues(alpha: 0.35)),
                prefixIcon: Icon(Icons.search, color: AppColors.brown.withValues(alpha: 0.5)),
                filled: true,
                fillColor: const Color(0xFFFDF8F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brown.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brown.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.terracotta),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCityChip('Jaipur'),
                _buildCityChip('Mumbai'),
                _buildCityChip('Delhi'),
                _buildCityChip('Bangalore'),
                _buildCityChip('Kolkata'),
                _buildCityChip('Varanasi'),
                _buildCityChip('Ahmedabad'),
                _buildCityChip('Lucknow'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  final city = controller.text.trim();
                  if (city.isNotEmpty) {
                    setState(() => _currentCity = city);
                    Navigator.pop(ctx);
                    _loadArtisans();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityChip(String city) {
    final isSelected = _currentCity == city;
    return GestureDetector(
      onTap: () {
        setState(() => _currentCity = city);
        Navigator.pop(context);
        _loadArtisans();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracotta.withValues(alpha: 0.1) : const Color(0xFFFDF8F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.terracotta : AppColors.brown.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          city,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.terracotta : AppColors.brown.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.brown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.t('b2bRegionalArtisansTitle'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showCityPicker();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedFilter == _RegionFilter.city
                            ? AppColors.terracotta
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFilter == _RegionFilter.city
                              ? AppColors.terracotta
                              : AppColors.brown.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lang.t('b2bFilterCity'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedFilter == _RegionFilter.city
                                      ? Colors.white
                                      : AppColors.brown,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: _selectedFilter == _RegionFilter.city
                                    ? Colors.white
                                    : AppColors.brown.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentCity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: _selectedFilter == _RegionFilter.city
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.brown.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchFilter(_RegionFilter.nearby),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedFilter == _RegionFilter.nearby
                            ? AppColors.terracotta
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFilter == _RegionFilter.nearby
                              ? AppColors.terracotta
                              : AppColors.brown.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang.t('b2bFilterNearby'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _selectedFilter == _RegionFilter.nearby
                                  ? Colors.white
                                  : AppColors.brown,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentState,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: _selectedFilter == _RegionFilter.nearby
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.brown.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchFilter(_RegionFilter.state),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedFilter == _RegionFilter.state
                            ? AppColors.terracotta
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFilter == _RegionFilter.state
                              ? AppColors.terracotta
                              : AppColors.brown.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang.t('b2bFilterState'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _selectedFilter == _RegionFilter.state
                                  ? Colors.white
                                  : AppColors.brown,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: _selectedFilter == _RegionFilter.state
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.brown.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
                : _artisans.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 48,
                                color: AppColors.brown.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                lang.t('b2bNoLocalArtisans'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.brown.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _artisans.length,
                        itemBuilder: (context, index) {
                          return _buildArtisanGridCard(_artisans[index], lang);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanGridCard(ArtisanProfile artisan, LanguageProvider lang) {
    final fallbackAsset = ArtisanImageHelper.getAssetForArtisan(
      name: artisan.name,
      craftType: artisan.craftSpecialization,
      artisanId: artisan.id,
    );
    final useNetwork = !ArtisanImageHelper.isForeignerOrInvalidPhoto(artisan.avatarUrl);

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  child: useNetwork
                      ? Image.network(
                          artisan.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            fallbackAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackAvatar(artisan),
                          ),
                        )
                      : Image.asset(
                          fallbackAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackAvatar(artisan),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artisan.craftSpecialization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.terracotta.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: AppColors.brown.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            _cleanLocation(artisan.location, artisan.state),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.brown.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => B2BArtisanProfileScreen(artisan: artisan),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: AppColors.terracotta.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          lang.t('b2bViewProfile'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.terracotta,
                          ),
                        ),
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

  Widget _buildFallbackAvatar(ArtisanProfile artisan) {
    return Container(
      color: AppColors.terracotta.withValues(alpha: 0.08),
      child: Center(
        child: Text(
          artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : 'A',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.terracotta.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  String _cleanLocation(String location, String state) {
    if (location.isEmpty && state.isEmpty) return '';
    if (state.isEmpty) return location;
    if (location.isEmpty) return state;
    if (location.endsWith(', $state') || location == state) return location;
    return '$location, $state';
  }
}

enum _RegionFilter { city, nearby, state }
