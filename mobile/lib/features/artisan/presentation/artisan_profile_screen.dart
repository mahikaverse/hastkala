import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';

class ArtisanProfileScreen extends StatefulWidget {
  const ArtisanProfileScreen({super.key});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  String _selectedLanguage = 'English';
  bool _notificationsOn = true;
  bool _isEditingStory = false;
  final TextEditingController _storyController = TextEditingController(
    text: 'I have been working with terracotta for over 12 years, creating traditional decorative pieces using locally sourced natural clay.',
  );

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
                padding: const EdgeInsets.only(bottom: 32),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppDimensions.xxl, AppDimensions.lg, AppDimensions.xxl, AppDimensions.xxl),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warmBeige, width: 4),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&crop=face',
                fit: BoxFit.cover,
                cacheWidth: 200,
                cacheHeight: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.warmBeige,
                    child: Icon(Icons.person, size: 48, color: AppColors.brown),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text('Sita Devi', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.brown)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, size: 16, color: AppColors.oliveGreen),
              const SizedBox(width: 4),
              Text('Verified Artisan', style: AppTextStyles.labelMedium.copyWith(color: AppColors.oliveGreen)),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text('Terracotta & Handcrafted Pottery', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text('Jaipur, Rajasthan', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Crafting traditional terracotta pieces inspired by Rajasthan\'s heritage.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.lg),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.terracotta),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.sm),
            ),
            child: Text('Edit Profile', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
          ),
        ],
      ),
    );
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
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta),
      unselectedLabelStyle: AppTextStyles.labelSmall,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Products'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Add Product'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
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
              if (context.mounted) {
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
