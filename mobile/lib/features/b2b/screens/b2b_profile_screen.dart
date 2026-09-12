import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../services/b2b_service.dart';
import 'b2b_saved_artisans_screen.dart';
import 'b2b_orders_screen.dart';
import 'b2b_requirements_screen.dart';
import 'b2b_enquiries_screen.dart';

class B2BProfileScreen extends StatefulWidget {
  const B2BProfileScreen({super.key});

  @override
  State<B2BProfileScreen> createState() => _B2BProfileScreenState();
}

class _B2BProfileScreenState extends State<B2BProfileScreen> {
  final B2BService _service = B2BService();
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;
    final stats = await _service.getBuyerStats(userId);
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
                      child: Text(
                        (user?.email ?? 'B')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracotta,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.email ?? 'B2B Buyer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mustardGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'B2B Buyer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mustardGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 36) / 4;
                  final effectiveWidth = cardWidth < 60 ? 60.0 : cardWidth;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: effectiveWidth,
                        child: _buildStatCard('Req', _stats['requirements'] ?? 0, AppColors.terracotta),
                      ),
                      SizedBox(
                        width: effectiveWidth,
                        child: _buildStatCard('Enq', _stats['enquiries'] ?? 0, AppColors.oliveGreen),
                      ),
                      SizedBox(
                        width: effectiveWidth,
                        child: _buildStatCard('Orders', _stats['orders'] ?? 0, AppColors.mustardGold),
                      ),
                      SizedBox(
                        width: effectiveWidth,
                        child: _buildStatCard('Saved', _stats['saved'] ?? 0, AppColors.brown),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Menu items
              _buildMenuItem(
                Icons.bookmark_outline,
                'Saved Artisans',
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const B2BSavedArtisansScreen()));
                },
              ),
              _buildMenuItem(
                Icons.shopping_bag_outlined,
                'My Orders',
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const B2BOrdersScreen()));
                },
              ),
              _buildMenuItem(
                Icons.list_alt_outlined,
                'My Requirements',
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const B2BRequirementsScreen()));
                },
              ),
              _buildMenuItem(
                Icons.forum_outlined,
                'My Enquiries',
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const B2BEnquiriesScreen()));
                },
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout?'),
                        content: const Text('You will be redirected to login.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Logout', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                      }
                    }
                  },
                  icon: Icon(Icons.logout, color: Colors.red.shade700),
                  label: Text(
                    'Logout',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brown.withValues(alpha: 0.7)),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.brown,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.brown.withValues(alpha: 0.3),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    );
  }
}
