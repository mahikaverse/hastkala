import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';

class SellerEditProductScreen extends StatefulWidget {
  final String productId;
  final String? newImagePath;
  const SellerEditProductScreen({super.key, required this.productId, this.newImagePath});

  @override
  State<SellerEditProductScreen> createState() => _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
  final DataService _data = DataService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _materialCtrl;
  late TextEditingController _craftTypeCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _discountPriceCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _shippingCtrl;

  MarketplaceProduct? _product;
  String? _pendingImagePath;
  bool _hasUnsavedChanges = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _product = _data.getProduct(widget.productId);
    _pendingImagePath = widget.newImagePath;

    final p = _product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _materialCtrl = TextEditingController(text: p?.material ?? '');
    _craftTypeCtrl = TextEditingController(text: p?.craftType ?? '');
    _sizeCtrl = TextEditingController(text: p?.dimensions ?? '');
    _weightCtrl = TextEditingController(text: p?.weight ?? '');
    _stockCtrl = TextEditingController(text: '${p?.stockQuantity ?? 0}');
    _priceCtrl = TextEditingController(text: p != null ? '${p.price.toInt()}' : '');
    _discountPriceCtrl = TextEditingController(text: p?.discountPrice != null ? '${p!.discountPrice!.toInt()}' : '');
    _tagsCtrl = TextEditingController(text: p?.tags.join(', ') ?? '');
    _shippingCtrl = TextEditingController(text: p?.shippingInfo ?? '');

    _nameCtrl.addListener(_markDirty);
    _descCtrl.addListener(_markDirty);
    _categoryCtrl.addListener(_markDirty);
    _materialCtrl.addListener(_markDirty);
    _craftTypeCtrl.addListener(_markDirty);
    _sizeCtrl.addListener(_markDirty);
    _weightCtrl.addListener(_markDirty);
    _stockCtrl.addListener(_markDirty);
    _priceCtrl.addListener(_markDirty);
    _discountPriceCtrl.addListener(_markDirty);
    _tagsCtrl.addListener(_markDirty);
    _shippingCtrl.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _materialCtrl.dispose();
    _craftTypeCtrl.dispose();
    _sizeCtrl.dispose();
    _weightCtrl.dispose();
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    _discountPriceCtrl.dispose();
    _tagsCtrl.dispose();
    _shippingCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes that will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'keep'), child: const Text('Keep Editing')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: const Text('Discard', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result == 'discard';
  }

  void _changeImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Change Product Image', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pendingImagePath = picked.path;
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price'), backgroundColor: AppColors.error),
      );
      return;
    }

    final stock = int.tryParse(_stockCtrl.text.trim());
    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock cannot be negative'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final p = _product;
      if (p == null) return;

      List<String> newImageUrls = List.from(p.imageUrls);
      if (_pendingImagePath != null) {
        newImageUrls = [_pendingImagePath!];
      }

      final discountPrice = double.tryParse(_discountPriceCtrl.text.trim());

      final tagsRaw = _tagsCtrl.text.trim();
      final tags = tagsRaw.isEmpty ? <String>[] : tagsRaw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      final updated = p.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        material: _materialCtrl.text.trim().isNotEmpty ? _materialCtrl.text.trim() : null,
        craftType: _craftTypeCtrl.text.trim().isNotEmpty ? _craftTypeCtrl.text.trim() : null,
        dimensions: _sizeCtrl.text.trim().isNotEmpty ? _sizeCtrl.text.trim() : null,
        weight: _weightCtrl.text.trim().isNotEmpty ? _weightCtrl.text.trim() : null,
        stockQuantity: stock,
        price: price,
        discountPrice: discountPrice,
        tags: tags,
        shippingInfo: _shippingCtrl.text.trim().isNotEmpty ? _shippingCtrl.text.trim() : null,
        imageUrls: newImageUrls,
        updatedAt: DateTime.now(),
      );

      _data.updateProduct(p.id, updated);
      _hasUnsavedChanges = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully'), backgroundColor: AppColors.oliveGreen),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't update product. Please try again."), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.cream,
          title: Text('Edit Product', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        ),
        body: const Center(child: Text('Product not found.')),
      );
    }

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _hasUnsavedChanges) {
          final discard = await _onWillPop();
          if (discard && mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.cream,
          title: Text('Edit Product', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              _buildImageEditor(product),
              const SizedBox(height: AppDimensions.lg),
              _buildTextField(_nameCtrl, 'Product Name', required: true),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_categoryCtrl, 'Category', required: true),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_materialCtrl, 'Material'),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_craftTypeCtrl, 'Craft Technique'),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_sizeCtrl, 'Size / Dimensions'),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_weightCtrl, 'Weight'),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_stockCtrl, 'Stock / Quantity', keyboardType: TextInputType.number),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceCtrl, 'Price (₹)', required: true, keyboardType: TextInputType.number)),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(child: _buildTextField(_discountPriceCtrl, 'Discount Price (₹)', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_shippingCtrl, 'Shipping Info'),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_tagsCtrl, 'Tags (comma separated)'),
              const SizedBox(height: AppDimensions.md),
              _buildTextField(_descCtrl, 'Description', maxLines: 4),
              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        ),
        bottomNavigationBar: _buildSaveBar(),
      ),
    );
  }

  Widget _buildImageEditor(MarketplaceProduct product) {
    final hasNewImage = _pendingImagePath != null;
    final hasExistingImage = product.imageUrls.isNotEmpty && !product.imageUrls.first.startsWith('assets/');

    return GestureDetector(
      onTap: _changeImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.warmBeige.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasNewImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                child: Image.file(File(_pendingImagePath!), width: double.infinity, height: 200, fit: BoxFit.cover),
              )
            else if (hasExistingImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                child: AdaptiveProductImage(imageUrl: product.imageUrls.first, fit: BoxFit.cover),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('Add Product Image', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 8, AppDimensions.lg, AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
