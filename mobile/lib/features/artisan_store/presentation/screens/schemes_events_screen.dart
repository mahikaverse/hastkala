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
      padding: const EdgeInsets.all(AppDimensions.lg),
      children: [
        _buildInfoBanner(),
        const SizedBox(height: AppDimensions.md),
        ...schemes.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: _buildSchemeCard(
            icon: s['icon'] as IconData,
            color: s['color'] as Color,
            title: s['title'] as String,
            subtitle: s['subtitle'] as String,
            benefit: s['benefit'] as String,
            status: s['status'] as String,
          ),
        )),
      ],
    );
  }

  Widget _buildExhibitionsTab() {
    final events = [
      {
        'name': 'India Handmade Expo 2026',
        'location': 'Pragati Maidan, New Delhi',
        'date': '15–18 November 2026',
        'description': 'National exhibition showcasing handloom, handicrafts and artisanal products from across India.',
      },
      {
        'name': 'Rajasthan Haat – Craft Mela',
        'location': 'Jawahar Kala Kendra, Jaipur',
        'date': '3–7 December 2026',
        'description': 'Annual craft fair bringing together artisans from Rajasthan for direct buyer interactions.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      children: [
        _buildInfoBanner(),
        const SizedBox(height: AppDimensions.md),
        ...events.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: _buildEventCard(
            name: e['name'] as String,
            location: e['location'] as String,
            date: e['date'] as String,
            description: e['description'] as String,
          ),
        )),
      ],
    );
  }

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

  Widget _buildEventCard({
    required String name,
    required String location,
    required String date,
    required String description,
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
          Text(name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
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
          Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal)),
          const SizedBox(height: AppDimensions.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('View Details', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

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
}
