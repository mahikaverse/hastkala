import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final DataService _data = DataService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _craftCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _experienceCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _storyCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  ArtisanProfile? get _profile =>
      _data.artisanProfiles.isNotEmpty ? _data.artisanProfiles.first : null;

  @override
  void initState() {
    super.initState();
    final p = _profile;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _craftCtrl = TextEditingController(text: p?.craftSpecialization ?? '');
    _locationCtrl = TextEditingController(text: p?.location ?? '');
    _stateCtrl = TextEditingController(text: p?.state ?? '');
    _experienceCtrl = TextEditingController(text: p?.yearsOfExperience.toString() ?? '');
    _bioCtrl = TextEditingController(text: p?.bio ?? '');
    _storyCtrl = TextEditingController(text: p?.craftStory ?? '');
    _emailCtrl = TextEditingController(text: p?.contactEmail ?? '');
    _phoneCtrl = TextEditingController(text: p?.contactPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _craftCtrl.dispose();
    _locationCtrl.dispose();
    _stateCtrl.dispose();
    _experienceCtrl.dispose();
    _bioCtrl.dispose();
    _storyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final p = _profile;
    if (p == null) return;

    final updated = p.copyWith(
      name: _nameCtrl.text.trim(),
      craftSpecialization: _craftCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      yearsOfExperience: int.tryParse(_experienceCtrl.text.trim()) ?? 0,
      bio: _bioCtrl.text.trim(),
      craftStory: _storyCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      contactPhone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
    );

    _data.updateArtisanProfile(p.id, updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved!'), backgroundColor: AppColors.oliveGreen),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text('Edit Profile', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppColors.cream, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            _buildAvatarSection(),
            const SizedBox(height: AppDimensions.xl),
            _buildSection('Basic Information', [
              _buildField('Name', _nameCtrl, Icons.person_outline),
              const SizedBox(height: AppDimensions.md),
              _buildField('Craft / Specialization', _craftCtrl, Icons.palette_outlined),
              const SizedBox(height: AppDimensions.md),
              _buildField('Location / City', _locationCtrl, Icons.location_on_outlined),
              const SizedBox(height: AppDimensions.md),
              _buildField('State', _stateCtrl, Icons.map_outlined),
              const SizedBox(height: AppDimensions.md),
              _buildField('Years of Experience', _experienceCtrl, Icons.timer_outlined, keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: AppDimensions.xl),
            _buildSection('About You', [
              _buildField('Short Bio', _bioCtrl, Icons.short_text, maxLines: 2),
            ]),
            const SizedBox(height: AppDimensions.xl),
            _buildSection('My Story', [
              _buildField(
                'Tell buyers about yourself, how you learned your craft, and what your craft means to you.',
                _storyCtrl,
                Icons.auto_stories_outlined,
                maxLines: 6,
                hint: 'I learned wood carving from my father and have been creating wooden products for more than 15 years...',
              ),
            ]),
            const SizedBox(height: AppDimensions.xl),
            _buildSection('Contact (Optional)', [
              _buildField('Email', _emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppDimensions.md),
              _buildField('Phone', _phoneCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: AppDimensions.xxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final name = _nameCtrl.text;
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.terracotta.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'A',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.terracotta),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.brown,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        )),
        const SizedBox(height: AppDimensions.md),
        ...children,
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
