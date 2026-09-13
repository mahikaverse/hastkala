import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../models/b2b_models.dart';
import '../services/b2b_service.dart';
import 'b2b_artisan_profile_screen.dart';
import 'b2b_enquiry_form_screen.dart';

class B2BAIMatchesScreen extends StatefulWidget {
  final B2BRequirement requirement;
  final B2BMatchResult? initialResult;

  const B2BAIMatchesScreen({
    super.key,
    required this.requirement,
    this.initialResult,
  });

  @override
  State<B2BAIMatchesScreen> createState() => _B2BAIMatchesScreenState();
}

class _B2BAIMatchesScreenState extends State<B2BAIMatchesScreen> {
  final B2BService _service = B2BService();
  late bool _isLoading;
  B2BMatchResult? _matchResult;
  String _selectedFilter = 'All';
  Set<String> _enquiredArtisanIds = {};

  @override
  void initState() {
    super.initState();
    _loadSentEnquiries();
    if (widget.initialResult != null) {
      _matchResult = widget.initialResult;
      _isLoading = false;
    } else {
      _isLoading = true;
      _fetchMatches();
    }
  }

  Future<void> _loadSentEnquiries() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isEmpty || widget.requirement.id.isEmpty) return;
    final enquiries = await _service.getEnquiries(
      buyerId: userId,
      requirementId: widget.requirement.id,
    );
    if (mounted) {
      setState(() {
        _enquiredArtisanIds = enquiries.map((e) => e.artisanId).toSet();
      });
    }
  }

  Future<void> _fetchMatches() async {
    setState(() => _isLoading = true);
    final req = widget.requirement;
    final res = await _service.matchArtisansWithAI(
      title: req.title,
      category: req.category,
      craftType: req.craftType,
      material: req.material,
      quantity: req.quantity > 0 ? req.quantity : null,
      budgetMin: req.budgetMin,
      budgetMax: req.budgetMax,
      deliveryLocation: req.deliveryLocation,
      deadline: req.deadline,
      customization: req.customization,
      description: req.description,
      requirementId: req.id.isNotEmpty ? req.id : null,
    );
    if (mounted) {
      setState(() {
        _matchResult = res;
        _isLoading = false;
      });
    }
  }

  List<B2BMatchedArtisan> get _filteredMatches {
    final matches = _matchResult?.matches ?? [];
    if (_selectedFilter == '90%+') {
      return matches.where((m) => m.matchScore >= 90).toList();
    }
    if (_selectedFilter == 'Verified') {
      return matches.where((m) => m.isVerified).toList();
    }
    return matches;
  }

  String _cleanLocation(String location, String state) {
    if (location.isEmpty && state.isEmpty) return '';
    if (state.isEmpty) return location;
    if (location.isEmpty) return state;
    if (location.endsWith(', $state') || location == state) return location;
    return '$location, $state';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDF8F0),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.brown),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          title: Row(
            children: [
              const Text(
                'AI Artisan Matches',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.terracotta, AppColors.mustardGold],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 11),
                    SizedBox(width: 3),
                    Text(
                      'GROQ AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.terracotta),
              onPressed: _fetchMatches,
              tooltip: 'Re-analyze with AI',
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingState()
            : RefreshIndicator(
                onRefresh: _fetchMatches,
                color: AppColors.terracotta,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                        child: Text(
                          'AI-powered matches based on your requirement',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.brown.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildRequirementCard(widget.requirement),
                      ),
                      const SizedBox(height: 14),
                      if (_matchResult != null &&
                          _matchResult!.aiAnalysis.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _buildAIAnalysisCard(_matchResult!),
                        ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildSectionHeader(),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildFilterChips(),
                      ),
                      const SizedBox(height: 14),
                      if (_filteredMatches.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: _buildEmptyMatches(),
                        )
                      else
                        ..._filteredMatches.map(
                          (m) => Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                            child: _buildArtisanCard(m),
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppColors.terracotta,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Groq AI Analyzing Requirement...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Evaluating craft specializations, workshop capacity, and geographic proximity across registered Indian artisans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.brown.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(B2BRequirement req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.terracotta,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    if (req.category.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        req.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.terracotta.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (req.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              req.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.brown.withValues(alpha: 0.65),
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (req.quantity > 0)
                _reqChip(Icons.inventory_2_outlined, '${req.quantity} pieces'),
              if (req.deadline != null)
                _reqChip(
                  Icons.calendar_today_outlined,
                  'By ${req.deadline!.day}/${req.deadline!.month}/${req.deadline!.year}',
                ),
              if (req.budgetMin != null || req.budgetMax != null)
                _reqChip(
                  Icons.currency_rupee,
                  req.budgetMin != null && req.budgetMax != null
                      ? '₹${req.budgetMin!.toInt()} - ₹${req.budgetMax!.toInt()}/pc'
                      : req.budgetMin != null
                          ? '₹${req.budgetMin!.toInt()}+'
                          : 'Up to ₹${req.budgetMax!.toInt()}',
                ),
              if (req.deliveryLocation != null &&
                  req.deliveryLocation!.isNotEmpty)
                _reqChip(Icons.location_on_outlined, req.deliveryLocation!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reqChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.brown.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.brown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard(B2BMatchResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.oliveGreen.withValues(alpha: 0.08),
            AppColors.mustardGold.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.oliveGreen.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.oliveGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppColors.oliveGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AI Craft & Capacity Analysis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.oliveGreen,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.oliveGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.modelUsed != null
                      ? 'Model: ${result.modelUsed}'
                      : 'Groq AI',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.oliveGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.aiAnalysis,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.brown,
              height: 1.4,
            ),
          ),
          if (result.estimatedProductionTime != null &&
              result.estimatedProductionTime!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: AppColors.oliveGreen,
                ),
                const SizedBox(width: 5),
                Text(
                  'Est. Production Time: ${result.estimatedProductionTime}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.oliveGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    final count = _filteredMatches.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Matching Artisans',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.terracotta,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Ranked by AI',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.brown.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', '90%+', 'Verified'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              selectedColor: AppColors.terracotta,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.brown.withValues(alpha: 0.7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.terracotta
                      : AppColors.brown.withValues(alpha: 0.15),
                ),
              ),
              onSelected: (_) => setState(() => _selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyMatches() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.brown.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'No matching artisans found for filter',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try switching filter to "All" or updating the requirement details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.brown.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanCard(B2BMatchedArtisan m) {
    final scoreColor = m.matchScore >= 90
        ? AppColors.oliveGreen
        : m.matchScore >= 75
            ? AppColors.terracotta
            : AppColors.mustardGold;

    final cleanLoc = _cleanLocation(m.location, m.state);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: m.matchScore >= 90
              ? AppColors.oliveGreen.withValues(alpha: 0.3)
              : AppColors.brown.withValues(alpha: 0.08),
          width: m.matchScore >= 90 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Large photo + Identity + Match score ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large profile image
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.terracotta.withValues(alpha: 0.25),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.terracotta.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 53,
                  backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
                  backgroundImage: m.avatarUrl.isNotEmpty
                      ? NetworkImage(m.avatarUrl)
                      : null,
                  child: m.avatarUrl.isEmpty
                      ? Text(
                          m.artisanName.isNotEmpty
                              ? m.artisanName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracotta,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 14),

              // Identity info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.artisanName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brown,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (m.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified,
                            size: 17,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      m.craftSpecialization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.terracotta,
                      ),
                    ),
                    if (cleanLoc.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.brown.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              cleanLoc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.brown.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Match score badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: scoreColor, size: 16),
                        Text(
                          '${m.matchScore}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI MATCH',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Row 2: Exactly 3 metric pills ──
          Row(
            children: [
              if (m.averageRating > 0)
                _metricPill(
                  Icons.star_rounded,
                  '${m.averageRating.toStringAsFixed(1)} (${m.totalReviews})',
                  AppColors.mustardGold,
                ),
              if (m.averageRating > 0) const SizedBox(width: 8),
              if (m.yearsOfExperience > 0)
                _metricPill(
                  Icons.history_edu_outlined,
                  '${m.yearsOfExperience} yrs exp',
                  AppColors.brown,
                ),
              if (m.yearsOfExperience > 0) const SizedBox(width: 8),
              _metricPill(
                Icons.check_circle_outline_rounded,
                '${m.feasibility} Feasibility',
                AppColors.oliveGreen,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Row 3: Why this matches ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF4EB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.terracotta.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.terracotta,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Why this matches?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  m.matchReason,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.brown.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Row 4: Action buttons ──
          Row(
            children: [
              Expanded(
                child: _enquiredArtisanIds.contains(m.artisanId)
                    ? ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check_circle_outline, size: 15),
                        label: const Text(
                          'Enquiry Sent',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.oliveGreen.withValues(alpha: 0.15),
                          foregroundColor: AppColors.oliveGreen,
                          disabledBackgroundColor: AppColors.oliveGreen.withValues(alpha: 0.15),
                          disabledForegroundColor: AppColors.oliveGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => B2BEnquiryFormScreen(
                                artisanId: m.artisanId,
                                artisanName: m.artisanName,
                                requirementId: widget.requirement.id.isNotEmpty
                                    ? widget.requirement.id
                                    : null,
                                requirement: widget.requirement,
                              ),
                            ),
                          );
                          if (result == true && mounted) {
                            _loadSentEnquiries();
                          }
                        },
                        icon: const Icon(Icons.send_outlined, size: 15),
                        label: const Text(
                          'Send Enquiry',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => B2BArtisanProfileScreen(
                          artisan: m.toArtisanProfile(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_outline_rounded, size: 15),
                  label: const Text(
                    'View Profile',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brown,
                    side: BorderSide(
                      color: AppColors.brown.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
