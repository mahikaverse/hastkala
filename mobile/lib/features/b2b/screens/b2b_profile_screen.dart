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
  final AuthService _auth = AuthService();
  Map<String, int> _stats = {};
  bool _isLoggingOut = false;

  User? get _user => Supabase.instance.client.auth.currentUser;

  String get _displayName {
    final metaName = _user?.userMetadata?['name'] as String?;
    if (metaName != null && metaName.isNotEmpty) return metaName;
    return _user?.email?.split('@').first ?? 'B2B Buyer';
  }

  String get _businessName {
    final bizName = _user?.userMetadata?['business_name'] as String?;
    if (bizName != null && bizName.isNotEmpty) return bizName;
    return _displayName;
  }

  String get _businessType {
    final role = _user?.userMetadata?['role'] as String?;
    if (role == 'b2b_seller' || role == 'b2bSeller') return 'B2B Buyer';
    return 'B2B Buyer';
  }

  String? get _location {
    final loc = _user?.userMetadata?['location'] as String?;
    if (loc != null && loc.isNotEmpty) return loc;
    final state = _user?.userMetadata?['state'] as String?;
    if (state != null && state.isNotEmpty) return state;
    return null;
  }

  String? get _phone {
    final phone = _user?.phone;
    if (phone != null && phone.isNotEmpty) return phone;
    final metaPhone = _user?.userMetadata?['phone'] as String?;
    if (metaPhone != null && metaPhone.isNotEmpty) return metaPhone;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = _user?.id ?? '';
    if (userId.isEmpty) return;
    final stats = await _service.getBuyerStats(userId);
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure you want to logout?'),
        content: const Text('You will be redirected to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    await _auth.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Avatar + Name ──
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
                      child: Text(
                        _displayName.isNotEmpty
                            ? _displayName[0].toUpperCase()
                            : 'B',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracotta,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _businessName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.mustardGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _businessType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mustardGold,
                        ),
                      ),
                    ),
                    if (_location != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.brown.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            _location!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.brown.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Contact Info ──
              _buildInfoCard([
                _buildInfoRow(Icons.email_outlined, 'Email', _user?.email ?? 'Not provided'),
                if (_phone != null)
                  _buildInfoRow(Icons.phone_outlined, 'Phone', _phone!),
              ]),
              const SizedBox(height: 16),

              // ── Stats ──
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

              // ── Menu Items ──
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

              // ── Logout ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoggingOut ? null : _logout,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                      : Icon(Icons.logout, color: Colors.red.shade700),
                  label: Text(
                    _isLoggingOut ? 'Logging out...' : 'Logout',
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

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.brown.withValues(alpha: 0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.brown.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brown,
                  ),
                ),
              ],
            ),
          ),
        ],
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
