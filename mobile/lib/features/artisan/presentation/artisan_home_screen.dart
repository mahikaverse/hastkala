import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/hastkala_bottom_nav.dart';

class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  final PageController _schemePageController = PageController();
  int _schemePage = 0;
  Timer? _schemeTimer;

  static const _schemeImages = [
    'assets/government1-img.png',
    'assets/government2-img.png',
    'assets/government3-img.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSchemeTimer());
  }

  @override
  void dispose() {
    _schemeTimer?.cancel();
    _schemePageController.dispose();
    super.dispose();
  }

  void _startSchemeTimer() {
    _schemeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_schemePageController.hasClients) return;
      final next = (_schemePage + 1) % _schemeImages.length;
      _schemePageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenWidth * 0.03),
              _buildHeader(),
              SizedBox(height: screenWidth * 0.04),
              _buildWelcomeSection(),
              SizedBox(height: screenWidth * 0.05),
              _buildAICraftAssistant(),
              SizedBox(height: screenWidth * 0.05),
              _buildStatsRow(),
              SizedBox(height: screenWidth * 0.05),
              _buildOpportunities(),
              SizedBox(height: screenWidth * 0.05),
              _buildMyProducts(),
              SizedBox(height: screenWidth * 0.06),
              _buildSchemesAndExhibitions(),
              SizedBox(height: screenWidth * 0.06),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── 1. HEADER ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '\u0939\u0938\u094D\u0924',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.terracotta),
              ),
              TextSpan(
                text: 'Kala',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.brown),
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildHeaderIcon(Icons.notifications_outlined, hasNotification: true),
        const SizedBox(width: 12),
        _buildHeaderIcon(Icons.person, isProfile: true),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool hasNotification = false, bool isProfile = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isProfile ? AppColors.brown.withValues(alpha: 0.15) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: isProfile ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: isProfile ? AppColors.brown : AppColors.brown, size: 22),
          if (hasNotification)
            Positioned(
              top: 8,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  // ─── 2. WELCOME SECTION ────────────────────────────────────────────────────

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back,', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                'Sita Devi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.brown),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text('\u{1F44B}', style: const TextStyle(fontSize: 22)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Your craft. Your story. Your market.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.oliveGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, size: 14, color: AppColors.oliveGreen),
              const SizedBox(width: 4),
              Text('Verified Artisan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.oliveGreen)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 3. AI CRAFT ASSISTANT ─────────────────────────────────────────────────

  Widget _buildAICraftAssistant() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: isSmallScreen ? _buildAISmallLayout() : _buildAILargeLayout(),
        );
      },
    );
  }

  Widget _buildAILargeLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 18),
                  const SizedBox(width: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('AI Craft Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Turn your craft into a ready-to-sell product listing.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _featureChip(Icons.mic, 'Speak in Hindi or English'),
                  _featureChip(Icons.camera_alt_outlined, 'Add a photo'),
                  _featureChip(Icons.auto_awesome, 'AI does the rest'),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(25)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text('Add Product', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.warmBeige.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset('assets/app-logo.png', fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.park_rounded, size: 50, color: AppColors.brown.withValues(alpha: 0.4)),
          ),
        ),
      ],
    );
  }

  Widget _buildAISmallLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 16),
            const SizedBox(width: 6),
            Text('AI Craft Assistant', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          ],
        ),
        const SizedBox(height: 6),
        Text('Turn your craft into a ready-to-sell product listing.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _featureChip(Icons.mic, 'Speak in Hindi or English'),
            _featureChip(Icons.camera_alt_outlined, 'Add a photo'),
            _featureChip(Icons.auto_awesome, 'AI does the rest'),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(25)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Add Product', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _featureChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.terracotta),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
      ],
    );
  }

  // ─── 4. STATS ROW ──────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 30) / 4;
        final iconPadding = cardWidth * 0.18;
        final iconSize = cardWidth * 0.38;
        return Row(
          children: [
            _statCard(Icons.inventory_2_outlined, '9', 'Products', AppColors.terracotta, iconPadding, iconSize),
            SizedBox(width: constraints.maxWidth * 0.03),
            _statCard(Icons.shopping_bag_outlined, '3', 'Orders', AppColors.oliveGreen, iconPadding, iconSize),
            SizedBox(width: constraints.maxWidth * 0.03),
            _statCard(Icons.currency_rupee_rounded, '\u20B911,980', 'Revenue', AppColors.mustardGold, iconPadding, iconSize),
            SizedBox(width: constraints.maxWidth * 0.03),
            _statCard(Icons.visibility_outlined, '3,250', 'Views', Colors.blue.shade600, iconPadding, iconSize),
          ],
        );
      },
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color, double padding, double iconSize) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding * 0.8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(padding * 0.5),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: iconSize, color: color),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 5. OPPORTUNITIES ─────────────────────────────────────────────────────

  Widget _buildOpportunities() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmall ? 10 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work_outline_rounded, color: AppColors.oliveGreen, size: isSmall ? 18 : 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('Opportunities for You', style: TextStyle(fontSize: isSmall ? 14 : 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    ),
                  ),
                  Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.terracotta)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 8 : 12),
                decoration: BoxDecoration(color: AppColors.warmBeige.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                child: isSmall ? _buildOpportunitySmall() : _buildOpportunityLarge(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View Request', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpportunityLarge() {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.terracotta.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.handshake_rounded, color: AppColors.terracotta, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(4)),
                    child: Text('B2B', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Bulk Order Request', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('50 Handcrafted Wooden Boxes', style: TextStyle(fontSize: 12, color: AppColors.charcoal)),
              const SizedBox(height: 2),
              Text('Buyer: Delhi, India', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text('\u20B9450 - \u20B9550 / piece', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brown)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: AppColors.oliveGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: FittedBox(child: Text('AI Match: 92%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.oliveGreen))),
            ),
            const SizedBox(height: 6),
            Container(
              width: 50, height: 40,
              decoration: BoxDecoration(color: AppColors.warmBeige, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.inventory_2_outlined, color: AppColors.brown.withValues(alpha: 0.5), size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpportunitySmall() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.terracotta.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.handshake_rounded, color: AppColors.terracotta, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(4)),
                        child: Text('B2B', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      const SizedBox(width: 4),
                      Text('Bulk Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('\u20B9450 - \u20B9550 / piece', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brown)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('50 Handcrafted Wooden Boxes', style: TextStyle(fontSize: 11, color: AppColors.charcoal)),
        Text('Buyer: Delhi, India', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  // ─── 6. MY PRODUCTS ────────────────────────────────────────────────────────

  Widget _buildMyProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.terracotta, size: 20),
            const SizedBox(width: 8),
            Text('My Products', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.manageProducts),
              child: Row(
                children: [
                  Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.terracotta)),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.terracotta),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockProducts.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _productCard(MockProducts.all[index]),
          ),
        ),
      ],
    );
  }

  Widget _productCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.manageProducts),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(product.imageUrl, width: 160, height: 110, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(width: 160, height: 110, color: AppColors.warmBeige, child: Icon(Icons.image_outlined, color: AppColors.textSecondary)),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                    child: Icon(Icons.more_vert, size: 14, color: AppColors.charcoal),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('\u20B9${product.price}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.brown)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.oliveGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('In Stock', style: TextStyle(fontSize: 11, color: AppColors.oliveGreen)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 7. SCHEMES AND EXHIBITIONS ────────────────────────────────────────────

  Widget _buildSchemesAndExhibitions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildGovernmentSchemesCard(isSmall)),
            SizedBox(width: constraints.maxWidth * 0.03),
            Expanded(child: _buildExhibitionsCard(isSmall)),
          ],
        );
      },
    );
  }

  Widget _buildGovernmentSchemesCard(bool isSmall) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.schemesEvents),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_rounded, color: AppColors.terracotta, size: isSmall ? 16 : 18),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('Government Schemes', style: TextStyle(fontSize: isSmall ? 12 : 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmall ? 8 : 10),
            SizedBox(
              height: isSmall ? 60 : 80,
              child: PageView.builder(
                controller: _schemePageController,
                itemCount: _schemeImages.length,
                onPageChanged: (i) => setState(() => _schemePage = i),
                itemBuilder: (_, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(_schemeImages[i], fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.terracotta.withValues(alpha: 0.1), child: Icon(Icons.account_balance, color: AppColors.terracotta, size: 24)),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: isSmall ? 8 : 10),
            Row(
              children: [
                Text('View All', style: TextStyle(fontSize: isSmall ? 10 : 12, fontWeight: FontWeight.w600, color: AppColors.terracotta)),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.terracotta),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExhibitionsCard(bool isSmall) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.schemesEvents),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_rounded, color: AppColors.mustardGold, size: isSmall ? 16 : 18),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('Exhibitions', style: TextStyle(fontSize: isSmall ? 12 : 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmall ? 8 : 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/exibitions-img.png', height: isSmall ? 60 : 80, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: isSmall ? 60 : 80, width: double.infinity,
                  color: AppColors.mustardGold.withValues(alpha: 0.1),
                  child: Icon(Icons.event, color: AppColors.mustardGold, size: 24),
                ),
              ),
            ),
            SizedBox(height: isSmall ? 8 : 10),
            Row(
              children: [
                Text('View All', style: TextStyle(fontSize: isSmall ? 10 : 12, fontWeight: FontWeight.w600, color: AppColors.mustardGold)),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.mustardGold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── 8. BOTTOM NAV ────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return HastKalaBottomNavigation(
      currentIndex: 0,
      onTap: (i) {
        final routes = [null, AppRoutes.manageProducts, AppRoutes.artisanAddProduct, AppRoutes.artisanOrders, AppRoutes.artisanProfile];
        if (routes[i] != null) Navigator.pushNamed(context, routes[i]!);
      },
      items: HastKalaNavItems.artisanLegacy,
    );
  }
}
