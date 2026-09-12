import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../models/b2b_models.dart';
import '../services/b2b_service.dart';
import 'b2b_requirement_form_screen.dart';

class B2BRequirementsScreen extends StatefulWidget {
  const B2BRequirementsScreen({super.key});

  @override
  State<B2BRequirementsScreen> createState() => _B2BRequirementsScreenState();
}

class _B2BRequirementsScreenState extends State<B2BRequirementsScreen> {
  final B2BService _service = B2BService();
  List<B2BRequirement> _requirements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequirements();
  }

  Future<void> _loadRequirements() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final reqs = await _service.getRequirements(buyerId: userId);
    setState(() {
      _requirements = reqs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Requirements',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.terracotta, size: 28),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const B2BRequirementFormScreen()),
                      );
                      if (result == true) _loadRequirements();
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
                  : _requirements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list_alt, size: 64, color: AppColors.brown.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              Text(
                                'No requirements yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brown.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to post your first requirement',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.brown.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRequirements,
                          color: AppColors.terracotta,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _requirements.length,
                            itemBuilder: (context, index) {
                              final req = _requirements[index];
                              return _buildRequirementCard(req);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementCard(B2BRequirement req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  req.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: req.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: req.statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (req.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              req.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.brown.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (req.quantity > 0)
                _infoChip(Icons.inventory_2_outlined, '${req.quantity} pcs'),
              if (req.budgetMin != null || req.budgetMax != null)
                _infoChip(
                  Icons.currency_rupee,
                  req.budgetMin != null && req.budgetMax != null
                      ? '₹${req.budgetMin!.toInt()} - ₹${req.budgetMax!.toInt()}'
                      : req.budgetMin != null
                          ? '₹${req.budgetMin!.toInt()}+'
                          : 'Up to ₹${req.budgetMax!.toInt()}',
                ),
              if (req.deliveryLocation != null)
                _infoChip(Icons.location_on_outlined, req.deliveryLocation!),
              if (req.deadline != null)
                _infoChip(Icons.calendar_today, '${req.deadline!.day}/${req.deadline!.month}/${req.deadline!.year}'),
              if (req.enquiriesCount > 0)
                _infoChip(Icons.forum_outlined, '${req.enquiriesCount} enquiries'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _timeAgo(req.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.brown.withValues(alpha: 0.4),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.brown.withValues(alpha: 0.5)),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => B2BRequirementFormScreen(requirement: req),
                    ),
                  );
                  if (result == true) _loadRequirements();
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.withValues(alpha: 0.5)),
                onPressed: () => _deleteRequirement(req.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.brown.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.brown.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  Future<void> _deleteRequirement(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Requirement?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteRequirement(id);
      _loadRequirements();
    }
  }
}
