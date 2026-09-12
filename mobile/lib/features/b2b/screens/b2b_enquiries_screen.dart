import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../models/b2b_models.dart';
import '../services/b2b_service.dart';

class B2BEnquiriesScreen extends StatefulWidget {
  const B2BEnquiriesScreen({super.key});

  @override
  State<B2BEnquiriesScreen> createState() => _B2BEnquiriesScreenState();
}

class _B2BEnquiriesScreenState extends State<B2BEnquiriesScreen> {
  final B2BService _service = B2BService();
  List<B2BEnquiry> _enquiries = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadEnquiries();
  }

  Future<void> _loadEnquiries() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final enquiries = await _service.getEnquiries(buyerId: userId);
    setState(() {
      _enquiries = enquiries;
      _isLoading = false;
    });
  }

  List<B2BEnquiry> get _filteredEnquiries {
    if (_filter == 'all') return _enquiries;
    return _enquiries.where((e) => e.status.name == _filter).toList();
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
              child: Text(
                'My Enquiries',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown,
                ),
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilter('all', 'All'),
                    _buildFilter('pending', 'Pending'),
                    _buildFilter('replied', 'Replied'),
                    _buildFilter('accepted', 'Accepted'),
                    _buildFilter('rejected', 'Rejected'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
                  : _filteredEnquiries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined, size: 64, color: AppColors.brown.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              Text(
                                'No enquiries found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brown.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadEnquiries,
                          color: AppColors.terracotta,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredEnquiries.length,
                            itemBuilder: (context, index) {
                              return _buildEnquiryCard(_filteredEnquiries[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.terracotta : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.terracotta : AppColors.brown.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.brown.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(B2BEnquiry enquiry) {
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
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
                child: Text(
                  enquiry.buyerName.isNotEmpty ? enquiry.buyerName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.terracotta,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enquiry.buyerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                    Text(
                      _timeAgo(enquiry.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.brown.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: enquiry.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  enquiry.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: enquiry.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            enquiry.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.brown.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              if (enquiry.quantity > 0)
                Text(
                  'Qty: ${enquiry.quantity}',
                  style: TextStyle(fontSize: 11, color: AppColors.brown.withValues(alpha: 0.5)),
                ),
              if (enquiry.budget != null)
                Text(
                  'Budget: ₹${enquiry.budget!.toInt()}/pc',
                  style: TextStyle(fontSize: 11, color: AppColors.terracotta.withValues(alpha: 0.7)),
                ),
              if (enquiry.deliveryLocation != null)
                Text(
                  '📍 ${enquiry.deliveryLocation}',
                  style: TextStyle(fontSize: 11, color: AppColors.brown.withValues(alpha: 0.5)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
