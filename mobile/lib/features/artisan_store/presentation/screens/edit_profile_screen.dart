import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/artisan_profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ArtisanProfileService _profileService = ArtisanProfileService();
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

  ArtisanProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _craftCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _experienceCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _storyCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _profileService.getProfile();
    if (mounted) {
      setState(() {
        _profile = p;
        _avatarUrl = p?.avatarUrl;
        _nameCtrl.text = p?.name ?? '';
        _craftCtrl.text = p?.craftSpecialization ?? '';
        _locationCtrl.text = p?.location ?? '';
        _stateCtrl.text = p?.state ?? '';
        _experienceCtrl.text = (p?.yearsOfExperience ?? 0) > 0 ? '${p!.yearsOfExperience}' : '';
        _bioCtrl.text = p?.bio ?? '';
        _storyCtrl.text = p?.craftStory ?? '';
        _emailCtrl.text = p?.contactEmail ?? '';
        _phoneCtrl.text = p?.contactPhone ?? '';
        _isLoading = false;
      });
    }
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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brown),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.terracotta),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.terracotta),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 800);
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    final url = await _profileService.uploadAvatar(File(picked.path));
    if (mounted) {
      setState(() {
        _isUploadingPhoto = false;
        if (url != null) {
          _avatarUrl = url;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated!'), backgroundColor: AppColors.oliveGreen),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final current = _profile ??
        ArtisanProfile(
          id: '',
          userId: _profileService.currentUserId ?? '',
          name: _nameCtrl.text.trim(),
          createdAt: DateTime.now(),
        );

    final updated = current.copyWith(
      name: _nameCtrl.text.trim(),
      avatarUrl: _avatarUrl ?? current.avatarUrl,
      craftSpecialization: _craftCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      yearsOfExperience: int.tryParse(_experienceCtrl.text.trim()) ?? 0,
      bio: _bioCtrl.text.trim(),
      craftStory: _storyCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      contactPhone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
    );

    final saved = await _profileService.updateProfile(updated);
    if (mounted) {
      setState(() {
        _isSaving = false;
        if (saved != null) _profile = saved;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved to database successfully!'),
          backgroundColor: AppColors.oliveGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
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
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream),
                  )
                : const Text('Save', style: TextStyle(color: AppColors.cream, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
          : Form(
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
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final hasPhoto = _avatarUrl != null && _avatarUrl!.isNotEmpty;
    return Center(
      child: GestureDetector(
        onTap: _isUploadingPhoto ? null : _pickAvatar,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.terracotta.withValues(alpha: 0.15),
              backgroundImage: hasPhoto
                  ? (_avatarUrl!.startsWith('http')
                      ? NetworkImage(_avatarUrl!)
                      : FileImage(File(_avatarUrl!)) as ImageProvider)
                  : null,
              child: _isUploadingPhoto
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppColors.terracotta, strokeWidth: 2),
                    )
                  : (!hasPhoto
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'A',
                          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.terracotta),
                        )
                      : null),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
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
