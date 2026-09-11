import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/product_draft.dart';

class ReviewDetailsScreen extends StatefulWidget {
  final ProductDraft draft;

  const ReviewDetailsScreen({super.key, required this.draft});

  @override
  State<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends State<ReviewDetailsScreen> {
  late final TextEditingController _productNameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _materialCtrl;
  late final TextEditingController _craftCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _makingTimeCtrl;
  late final TextEditingController _makingProcessCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _craftStoryCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _productNameCtrl = TextEditingController(text: d.productName ?? '');
    _categoryCtrl = TextEditingController(text: d.category ?? '');
    _materialCtrl = TextEditingController(text: d.material ?? '');
    _craftCtrl = TextEditingController(text: d.craft ?? '');
    _colorCtrl = TextEditingController(text: d.color ?? '');
    _sizeCtrl = TextEditingController(text: d.size ?? '');
    _weightCtrl = TextEditingController(text: d.weight ?? '');
    _quantityCtrl = TextEditingController(text: d.quantity?.toString() ?? '');
    _makingTimeCtrl = TextEditingController(text: d.makingTime ?? '');
    _makingProcessCtrl = TextEditingController(text: d.makingProcess ?? '');
    _locationCtrl = TextEditingController(text: d.location ?? '');
    _craftStoryCtrl = TextEditingController(text: d.craftStory ?? '');
  }

  @override
  void dispose() {
    _productNameCtrl.dispose();
    _categoryCtrl.dispose();
    _materialCtrl.dispose();
    _craftCtrl.dispose();
    _colorCtrl.dispose();
    _sizeCtrl.dispose();
    _weightCtrl.dispose();
    _quantityCtrl.dispose();
    _makingTimeCtrl.dispose();
    _makingProcessCtrl.dispose();
    _locationCtrl.dispose();
    _craftStoryCtrl.dispose();
    super.dispose();
  }

  void _saveDraft() {
    final d = widget.draft;
    d.productName = _productNameCtrl.text;
    d.category = _categoryCtrl.text;
    d.material = _materialCtrl.text;
    d.craft = _craftCtrl.text;
    d.color = _colorCtrl.text;
    d.size = _sizeCtrl.text;
    d.weight = _weightCtrl.text;
    d.quantity = int.tryParse(_quantityCtrl.text);
    d.makingTime = _makingTimeCtrl.text;
    d.makingProcess = _makingProcessCtrl.text;
    d.location = _locationCtrl.text;
    d.craftStory = _craftStoryCtrl.text;
  }

  void _onGenerateCatalog() {
    _saveDraft();
    Navigator.pushNamed(context, '/catalog-preview', arguments: widget.draft);
  }

  void _showEditSheet({
    required String title,
    required TextEditingController controller,
    bool multiline = false,
  }) {
    final editCtrl = TextEditingController(text: controller.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
          ),
          padding: EdgeInsets.only(
            left: AppDimensions.xxl,
            right: AppDimensions.xxl,
            top: AppDimensions.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimensions.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(title, style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppDimensions.lg),
              TextField(
                controller: editCtrl,
                maxLines: multiline ? 4 : 1,
                autofocus: true,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Enter $title',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.cream,
                  contentPadding: const EdgeInsets.all(AppDimensions.lg),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    setState(() => controller.text = editCtrl.text);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Check Your Details',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubtitle(),
                  const SizedBox(height: AppDimensions.xxl),
                  _buildGroupLabel('Product Info'),
                  const SizedBox(height: AppDimensions.md),
                  _buildFieldCard(
                    label: 'Product Name',
                    controller: _productNameCtrl,
                    onTap: () => _showEditSheet(title: 'Product Name', controller: _productNameCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Category',
                    controller: _categoryCtrl,
                    onTap: () => _showEditSheet(title: 'Category', controller: _categoryCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Material',
                    controller: _materialCtrl,
                    onTap: () => _showEditSheet(title: 'Material', controller: _materialCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Craft',
                    controller: _craftCtrl,
                    onTap: () => _showEditSheet(title: 'Craft', controller: _craftCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Color',
                    controller: _colorCtrl,
                    onTap: () => _showEditSheet(title: 'Color', controller: _colorCtrl),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  _buildGroupLabel('Details'),
                  const SizedBox(height: AppDimensions.md),
                  _buildFieldCard(
                    label: 'Size',
                    controller: _sizeCtrl,
                    onTap: () => _showEditSheet(title: 'Size', controller: _sizeCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Weight',
                    controller: _weightCtrl,
                    onTap: () => _showEditSheet(title: 'Weight', controller: _weightCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Quantity',
                    controller: _quantityCtrl,
                    onTap: () => _showEditSheet(title: 'Quantity', controller: _quantityCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Making Time',
                    controller: _makingTimeCtrl,
                    onTap: () => _showEditSheet(title: 'Making Time', controller: _makingTimeCtrl),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  _buildGroupLabel('Story'),
                  const SizedBox(height: AppDimensions.md),
                  _buildFieldCard(
                    label: 'Making Process',
                    controller: _makingProcessCtrl,
                    multiline: true,
                    onTap: () => _showEditSheet(
                      title: 'Making Process',
                      controller: _makingProcessCtrl,
                      multiline: true,
                    ),
                  ),
                  _buildFieldCard(
                    label: 'Location',
                    controller: _locationCtrl,
                    onTap: () => _showEditSheet(title: 'Location', controller: _locationCtrl),
                  ),
                  _buildFieldCard(
                    label: 'Craft Story',
                    controller: _craftStoryCtrl,
                    multiline: true,
                    onTap: () => _showEditSheet(
                      title: 'Craft Story',
                      controller: _craftStoryCtrl,
                      multiline: true,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        '✨ We understood this from your voice',
        style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGroupLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.titleLarge.copyWith(color: AppColors.brown),
    );
  }

  Widget _buildFieldCard({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool multiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.brown.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      controller.text.isEmpty ? 'Not specified (Tap to edit)' : controller.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: controller.text.isEmpty ? AppColors.textSecondary.withValues(alpha: 0.6) : AppColors.charcoal,
                        fontStyle: controller.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                      maxLines: multiline ? 3 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              const Icon(
                Icons.edit_outlined,
                size: AppDimensions.iconSM,
                color: AppColors.terracotta,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.xl,
          AppDimensions.sm,
          AppDimensions.xl,
          AppDimensions.lg,
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLG,
          child: GestureDetector(
            onTap: _onGenerateCatalog,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Center(
                child: Text(
                  'Generate My Catalog',
                  style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
