import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/localization/language_provider.dart';
import '../services/b2b_service.dart';

class B2BSavedArtisansScreen extends StatefulWidget {
  const B2BSavedArtisansScreen({super.key});

  @override
  State<B2BSavedArtisansScreen> createState() => _B2BSavedArtisansScreenState();
}

class _B2BSavedArtisansScreenState extends State<B2BSavedArtisansScreen> {
  final B2BService _service = B2BService();
  List<Map<String, dynamic>> _savedArtisans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final saved = await _service.getSavedArtisans(userId);
    setState(() {
      _savedArtisans = saved;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.t('b2bSavedArtisans'),
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
          : _savedArtisans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: AppColors.brown.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        lang.t('b2bNoSavedArtisans'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedArtisans.length,
                  itemBuilder: (context, index) {
                    final saved = _savedArtisans[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.brown.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, color: AppColors.terracotta),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  saved['name'] ?? lang.t('b2bArtisan'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brown,
                                  ),
                                ),
                                Text(
                                  saved['craft_type'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.brown.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: AppColors.terracotta,
                            ),
                            onPressed: () async {
                              final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
                              await _service.unsaveArtisan(userId, saved['id'] ?? '');
                              _loadSaved();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
