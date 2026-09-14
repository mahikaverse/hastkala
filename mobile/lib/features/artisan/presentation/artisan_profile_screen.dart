import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/artisan_profile.dart';
import '../../../core/services/artisan_profile_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/hastkala_bottom_nav.dart';

class ArtisanProfileScreen extends StatefulWidget {
  const ArtisanProfileScreen({super.key});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  final ArtisanProfileService _profileService = ArtisanProfileService();
  ArtisanProfile? _profile;
  bool _isUploadingPhoto = false;

  String _selectedLanguage = 'English';
  bool _notificationsOn = true;
  bool _isEditingStory = false;
  final TextEditingController _storyController = TextEditingController(
    text: 'I have been working with terracotta for over 12 years, creating traditional decorative pieces using locally sourced natural clay.',
  );

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _profileService.getProfile();
    if (mounted) {
      setState(() {
        _profile = p;
        if (p != null && p.craftStory.isNotEmpty) {
          _storyController.text = p.craftStory;
        }
      });
    }
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    _buildIdentityHero(),
                    _buildBusinessStats(),
                    _buildCraftStory(),
                    _buildMyCraft(),
                    _buildBusinessProfile(),
                    _buildAIInsights(),
                    _buildBusinessSnapshot(),
                    _buildProfileCompletion(),
                    _buildQuickActions(),
                    _buildAccountSettings(),
                    _buildLogout(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: 'Go back',
          ),
          Expanded(
            child: Text('Profile', style: AppTextStyles.titleLarge.copyWith(color: AppColors.charcoal)),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings_outlined, color: AppColors.charcoal, size: 22),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  // ─── 3. ARTISAN IDENTITY HERO ──────────────────────────────────────────────

  Widget _buildIdentityHero() {
    final profile = _profile;
    final name = profile?.name.isNotEmpty == true ? profile!.name : 'Artisan';
    final craft = profile?.craftSpecialization.isNotEmpty == true
        ? profile!.craftSpecialization
        : 'Traditional Crafts';
    final location = profile?.location.isNotEmpty == true
        ? (profile!.state.isNotEmpty
            ? '${profile.location}, ${profile.state}'
            : profile.location)
        : '';
    final years = profile?.yearsOfExperience ?? 0;
    final avatarUrl = profile?.avatarUrl ?? '';
    final hasPhoto = avatarUrl.isNotEmpty;
    final isVerified = profile?.isVerified ?? false;

    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth < 360 ? 50.0 : 58.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xxl, AppDimensions.lg, AppDimensions.xxl, AppDimensions.xxl,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.terracotta, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.terracotta.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: const Color(0xFFFDF8F0),
                  backgroundImage: hasPhoto
                      ? (avatarUrl.startsWith('http')
                          ? NetworkImage(avatarUrl)
                          : FileImage(File(avatarUrl)) as ImageProvider)
                      : null,
                  child: _isUploadingPhoto
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppColors.terracotta,
                            strokeWidth: 2.5,
                          ),
                        )
                      : (!hasPhoto
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'A',
                              style: TextStyle(
                                fontSize: avatarRadius * 0.8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.terracotta,
                              ),
                            )
                          : null),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.brown,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified_rounded,
                  size: 20,
                  color: AppColors.oliveGreen,
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              craft,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.terracotta,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          if (location.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 15,
                  color: AppColors.brown.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.brown.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (years > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: AppColors.mustardGold.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  '$years+ years of master craftsmanship',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.brown.withValues(alpha: 0.55),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.terracotta,
                  ),
                ),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.terracotta,
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    final uploadedUrl = await _profileService.uploadAvatar(File(picked.path));

    if (mounted) {
      setState(() {
        _isUploadingPhoto = false;
        if (uploadedUrl != null && _profile != null) {
          _profile = _profile!.copyWith(avatarUrl: uploadedUrl);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated!'),
          backgroundColor: AppColors.oliveGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── 4. BUSINESS STATS ─────────────────────────────────────────────────────

  Widget _buildBusinessStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem('12', 'Products'),
            _statDivider(),
            _statItem('356', 'Views'),
            _statDivider(),
            _statItem('48', 'Orders'),
            _statDivider(),
            _statItem('4.8', 'Rating', suffix: ' ★'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, {String? suffix}) {
    return Column(
      children: [
        Text(
          '$value${suffix ?? ''}',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.brown),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 32, color: AppColors.borderLight);
  }

  // ─── 5. CRAFT STORY ────────────────────────────────────────────────────────

  Widget _buildCraftStory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Craft Story', style: AppTextStyles.titleMedium),
              GestureDetector(
                onTap: () => setState(() => _isEditingStory = !_isEditingStory),
                child: Text(
                  _isEditingStory ? 'Done' : 'Edit Story',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta),
                ),
              ),
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
            child: _isEditingStory
                ? TextField(
                    controller: _storyController,
                    maxLines: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tell your craft story...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  )
                : Text(
                    _storyController.text,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── 6. MY CRAFT ───────────────────────────────────────────────────────────

  Widget _buildMyCraft() {
    final crafts = ['Terracotta', 'Pottery', 'Handmade', 'Home Decor', 'Traditional Craft', 'Rajasthani Art'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Craft', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [
              ...crafts.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.warmBeige,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(c, style: AppTextStyles.labelMedium),
              )),
              GestureDetector(
                onTap: _showAddCraftSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: AppColors.terracotta, style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppColors.terracotta),
                      const SizedBox(width: 4),
                      Text('Add Craft', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 7. BUSINESS PROFILE ───────────────────────────────────────────────────

  Widget _buildBusinessProfile() {
    final rows = [
      _BizRow(Icons.store_outlined, 'Business Name', 'Sita Handicrafts'),
      _BizRow(Icons.location_on_outlined, 'Location', 'Jaipur, Rajasthan'),
      _BizRow(Icons.palette_outlined, 'Craft Category', 'Terracotta & Pottery'),
      _BizRow(Icons.inventory_2_outlined, 'Products', '12 active products'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Information', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: List.generate(rows.length, (i) {
                final row = rows[i];
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(row.icon, color: AppColors.charcoal, size: 20),
                      title: Text(row.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      subtitle: Text(row.value, style: AppTextStyles.bodyMedium),
                      trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                      onTap: () {},
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                    ),
                    if (i < rows.length - 1) const Divider(height: 1, indent: 56),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 8. AI BUSINESS INSIGHTS ───────────────────────────────────────────────

  Widget _buildAIInsights() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.warmBeige.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: AppColors.mustardGold),
                const SizedBox(width: AppDimensions.sm),
                Text('AI BUSINESS INSIGHTS', style: AppTextStyles.labelSmall.copyWith(color: AppColors.brown, letterSpacing: 0.8)),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Text('Your craft is getting noticed', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Your products received 18% more views this week.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                'AI suggests adding 2\u20133 more terracotta home-decor products because demand is currently high.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.brown, height: 1.5),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text('View Insights', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.terracotta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 9. BUSINESS SNAPSHOT ──────────────────────────────────────────────────

  Widget _buildBusinessSnapshot() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Snapshot', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text('This Month', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppDimensions.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹24,850', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.terracotta)),
                      const SizedBox(height: 2),
                      Text('Sales', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _snapshotDivider(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('48', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.brown)),
                      const SizedBox(height: 2),
                      Text('Orders', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _snapshotDivider(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹518', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.mustardGold)),
                      const SizedBox(height: 2),
                      Text('Avg. Order', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.artisanOrders),
            child: Row(
              children: [
                Text('View Orders', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: AppColors.terracotta),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _snapshotDivider() {
    return Container(width: 1, height: 40, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md));
  }

  // ─── 10. PROFILE COMPLETION ────────────────────────────────────────────────

  Widget _buildProfileCompletion() {
    final items = [
      _CompletionItem('Profile photo', true),
      _CompletionItem('Craft category', true),
      _CompletionItem('Craft story', true),
      _CompletionItem('Product catalog', true),
      _CompletionItem('Business details', false),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Complete Your Profile', style: AppTextStyles.titleMedium),
              Text('80%', style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.8,
              backgroundColor: AppColors.warmBeige,
              valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: Row(
              children: [
                Icon(
                  item.done ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: item.done ? AppColors.oliveGreen : AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  item.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: item.done ? AppColors.charcoal : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: AppDimensions.md),
          GestureDetector(
            onTap: () {},
            child: Text('Complete Profile', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
          ),
        ],
      ),
    );
  }

  // ─── 11. QUICK ACTIONS ─────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      _ActionData(Icons.add_circle_outline, 'Add New Product', 'List a new craft item', AppRoutes.artisanAddProduct),
      _ActionData(Icons.inventory_2_outlined, 'Manage Products', 'View and edit listings', AppRoutes.manageProducts),
      _ActionData(Icons.receipt_long_outlined, 'My Orders', 'Track sales and orders', AppRoutes.artisanOrders),
      _ActionData(Icons.attach_money, 'Smart Pricing', 'Find the right price for your craft', AppRoutes.aiPricing),
      _ActionData(Icons.public, 'Market Opportunities', 'Discover new buyers', AppRoutes.marketLinkage),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: List.generate(actions.length, (i) {
                final a = actions[i];
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(a.icon, color: AppColors.terracotta, size: 22),
                      title: Text(a.title, style: AppTextStyles.bodyMedium),
                      subtitle: Text(a.subtitle, style: AppTextStyles.bodySmall),
                      trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                      onTap: () => Navigator.pushNamed(context, a.route),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                    ),
                    if (i < actions.length - 1) const Divider(height: 1, indent: 56),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 12. ACCOUNT SETTINGS ──────────────────────────────────────────────────

  Widget _buildAccountSettings() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _settingsRow(Icons.language_outlined, 'Language', _selectedLanguage, () => _showLanguageSheet()),
                const Divider(height: 1, indent: 56),
                _settingsRow(
                  Icons.notifications_outlined,
                  'Notifications',
                  _notificationsOn ? 'On' : 'Off',
                  () => setState(() => _notificationsOn = !_notificationsOn),
                ),
                const Divider(height: 1, indent: 56),
                _settingsRow(Icons.lock_outline, 'Privacy & Security', '', () {}),
                const Divider(height: 1, indent: 56),
                _settingsRow(Icons.help_outline, 'Help & Support', '', () {}),
                const Divider(height: 1, indent: 56),
                _settingsRow(Icons.info_outline, 'About HastKala', '', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(IconData icon, String title, String trailing, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.charcoal, size: 20),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty)
            Text(trailing, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
    );
  }

  // ─── 14. LOGOUT ────────────────────────────────────────────────────────────

  Widget _buildLogout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xxl),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _showLogoutDialog,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.terracotta),
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
          ),
          child: Text('Log Out', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return HastKalaBottomNavigation(
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
      items: HastKalaNavItems.artisanLegacy(context),
    );
  }

  // ─── DIALOGS & SHEETS ──────────────────────────────────────────────────────

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLG)),
        title: Text('Log out of HastKala?', style: AppTextStyles.titleMedium),
        content: Text('Are you sure you want to log out?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
            child: Text('Log Out', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet() {
    final languages = {
      'English': 'English',
      'हिन्दी': 'Hindi',
      'मराठी': 'Marathi',
      'বাংলা': 'Bengali',
      'தமிழ்': 'Tamil',
      'తెలుగు': 'Telugu',
      'ગુજરાતી': 'Gujarati',
      'ಕನ್ನಡ': 'Kannada',
      'ਪੰਜਾਬੀ': 'Punjabi',
    };
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.md),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: AppDimensions.lg),
              Text('Choose Language', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.md),
              ...languages.entries.map((e) {
                final isSelected = _selectedLanguage == e.value;
                return ListTile(
                  title: Text(e.key, style: AppTextStyles.bodyMedium.copyWith(color: isSelected ? AppColors.terracotta : AppColors.charcoal)),
                  subtitle: Text(e.value, style: AppTextStyles.bodySmall),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.terracotta) : null,
                  onTap: () {
                    setState(() => _selectedLanguage = e.value);
                    Navigator.pop(ctx);
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
                );
              }),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        );
      },
    );
  }

  void _showAddCraftSheet() {
    final crafts = ['Terracotta', 'Pottery', 'Textiles', 'Woodwork', 'Jewelry', 'Home Decor', 'Block Print', 'Madhubani Art'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.md),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: AppDimensions.lg),
              Text('Add Craft', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.md),
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.sm,
                alignment: WrapAlignment.center,
                children: crafts.map((c) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warmBeige,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(c, style: AppTextStyles.labelMedium),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        );
      },
    );
  }
}

class _BizRow {
  final IconData icon;
  final String label;
  final String value;
  const _BizRow(this.icon, this.label, this.value);
}

class _ActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  const _ActionData(this.icon, this.title, this.subtitle, this.route);
}

class _CompletionItem {
  final String label;
  final bool done;
  const _CompletionItem(this.label, this.done);
}
