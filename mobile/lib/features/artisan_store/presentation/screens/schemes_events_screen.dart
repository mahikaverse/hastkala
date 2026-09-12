import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

class SchemesEventsScreen extends StatefulWidget {
  const SchemesEventsScreen({super.key});

  @override
  State<SchemesEventsScreen> createState() => _SchemesEventsScreenState();
}

class _SchemesEventsScreenState extends State<SchemesEventsScreen> {
  int _selectedTab = 0;

  // Exhibition carousel
  final PageController _exhibitionPageController = PageController();
  int _exhibitionPage = 0;
  Timer? _exhibitionTimer;

  // Schemes carousel
  final PageController _schemePageController = PageController();
  int _schemePage = 0;
  Timer? _schemeTimer;

  static const _exhibitionImages = [
    'assets/exibitions-img.png',
    'assets/exibitions2-img.png',
  ];

  static const _schemeImages = [
    'assets/government1-img.png',
    'assets/government2-img.png',
    'assets/government3-img.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startExhibitionTimer();
      _startSchemeTimer();
    });
  }

  @override
  void dispose() {
    _exhibitionTimer?.cancel();
    _schemeTimer?.cancel();
    _exhibitionPageController.dispose();
    _schemePageController.dispose();
    super.dispose();
  }

  void _startExhibitionTimer() {
    _exhibitionTimer?.cancel();
    _exhibitionTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_exhibitionPageController.hasClients) return;
      final total = _exhibitionImages.length;
      final next = (_exhibitionPage + 1) % total;
      _exhibitionPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startSchemeTimer() {
    _schemeTimer?.cancel();
    _schemeTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_schemePageController.hasClients) return;
      final total = _schemeImages.length;
      final next = (_schemePage + 1) % total;
      _schemePageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text(
          'Schemes & Events',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 0
                ? _buildSchemesTab()
                : _buildExhibitionsTab(),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab(
            label: 'Government Schemes',
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          )),
          Expanded(child: _buildTab(
            label: 'Exhibitions',
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          )),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracotta : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.charcoal,
          ),
        ),
      ),
    );
  }

  // ── Schemes tab ─────────────────────────────────────────────────────────

  Widget _buildSchemesTab() {
    final schemes = [
      {
        'icon': Icons.agriculture_rounded,
        'color': AppColors.oliveGreen,
        'title': 'PM Vishwakarma Yojana',
        'subtitle': 'Support for traditional artisans and craftspeople',
        'benefit': 'Training + ₹15,000 tool kit + ₹15,000 working capital loan',
        'status': 'Applications Open',
      },
      {
        'icon': Icons.store_rounded,
        'color': AppColors.terracotta,
        'title': 'PMEGP – Mudra Loan',
        'subtitle': 'Subsidy for starting/upgrading micro enterprises',
        'benefit': '15%–35% capital subsidy on project cost',
        'status': 'Always Available',
      },
      {
        'icon': Icons.public_rounded,
        'color': AppColors.mustardGold,
        'title': 'GI Tag Assistance',
        'subtitle': 'Geographical Indication registration support',
        'benefit': 'Legal protection & premium pricing for regional crafts',
        'status': 'Info Only',
      },
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildCarousel(
          images: _schemeImages,
          controller: _schemePageController,
          currentPage: _schemePage,
          onPageChanged: (i) => setState(() => _schemePage = i),
        ),
        const SizedBox(height: AppDimensions.md),
        ...schemes.map((s) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.xs),
          child: _buildSchemeCard(
            icon: s['icon'] as IconData,
            color: s['color'] as Color,
            title: s['title'] as String,
            subtitle: s['subtitle'] as String,
            benefit: s['benefit'] as String,
            status: s['status'] as String,
          ),
        )),
        const SizedBox(height: AppDimensions.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: _buildInfoBanner(),
        ),
        const SizedBox(height: AppDimensions.xxl),
      ],
    );
  }

  // ── Exhibitions tab ─────────────────────────────────────────────────────

  Widget _buildExhibitionsTab() {
    final events = [
      {
        'name': 'PM Vishwakarma Haat 2026',
        'location': 'Amar Jawan Jyoti, Jaipur',
        'date': '12–15 September 2026',
        'description': 'Government-backed exhibition for PM Vishwakarma beneficiaries to showcase and sell handmade products directly to buyers.',
        'badge': 'Happening Now',
        'badgeColor': AppColors.oliveGreen,
      },
      {
        'name': 'India Handmade Expo 2026',
        'location': 'Pragati Maidan, New Delhi',
        'date': '15–18 November 2026',
        'description': 'National exhibition showcasing handloom, handicrafts and artisanal products from across India.',
        'badge': 'Upcoming',
        'badgeColor': AppColors.mustardGold,
      },
      {
        'name': 'Rajasthan Haat – Craft Mela',
        'location': 'Jawahar Kala Kendra, Jaipur',
        'date': '3–7 December 2026',
        'description': 'Annual craft fair bringing together artisans from Rajasthan for direct buyer interactions.',
        'badge': 'Upcoming',
        'badgeColor': AppColors.mustardGold,
      },
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildCarousel(
          images: _exhibitionImages,
          controller: _exhibitionPageController,
          currentPage: _exhibitionPage,
          onPageChanged: (i) => setState(() => _exhibitionPage = i),
        ),
        const SizedBox(height: AppDimensions.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Text('Upcoming Exhibitions', style: AppTextStyles.headlineSmall),
        ),
        const SizedBox(height: AppDimensions.md),

        ...events.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.xs),
          child: _buildEventCard(
            name: e['name'] as String,
            location: e['location'] as String,
            date: e['date'] as String,
            description: e['description'] as String,
            badge: e['badge'] as String,
            badgeColor: e['badgeColor'] as Color,
          ),
        )),

        const SizedBox(height: AppDimensions.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: _buildInfoBanner(),
        ),
        const SizedBox(height: AppDimensions.xxl),
      ],
    );
  }

  // ── Shared carousel ─────────────────────────────────────────────────────

  Widget _buildCarousel({
    required List<String> images,
    required PageController controller,
    required int currentPage,
    required ValueChanged<int> onPageChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                    child: Image.asset(
                      images[i],
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.terracotta,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppColors.cream.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.terracotta : AppColors.border,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Scheme card ─────────────────────────────────────────────────────────

  Widget _buildSchemeCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String benefit,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(benefit, style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal)),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: color),
              const SizedBox(width: 4),
              Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text('Learn More', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Event card ──────────────────────────────────────────────────────────

  Widget _buildEventCard({
    required String name,
    required String location,
    required String date,
    required String description,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Column(
                  children: [
                    Text(
                      date.split(RegExp(r'[–\s]')).first,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _extractMonth(date).length >= 3 ? _extractMonth(date).substring(0, 3) : _extractMonth(date),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            badge,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(child: Text(location, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(date, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.terracotta,
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 20, color: AppColors.terracotta),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'More schemes and events are being added regularly. Check back often for new opportunities.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  String _extractMonth(String date) {
    final months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    final lower = date.toLowerCase();
    for (final m in months) {
      if (lower.contains(m.toLowerCase())) return m.substring(0, 3);
    }
    return '';
  }
}
