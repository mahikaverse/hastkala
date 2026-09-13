import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../models/b2b_models.dart';
import '../services/b2b_service.dart';
import 'b2b_ai_matches_screen.dart';

class B2BRequirementFormScreen extends StatefulWidget {
  final B2BRequirement? requirement;

  const B2BRequirementFormScreen({super.key, this.requirement});

  @override
  State<B2BRequirementFormScreen> createState() => _B2BRequirementFormScreenState();
}

class _B2BRequirementFormScreenState extends State<B2BRequirementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _locationController = TextEditingController();
  final _customizationController = TextEditingController();
  final B2BService _service = B2BService();
  bool _isSubmitting = false;
  String? _selectedCategory;
  DateTime? _deadline;
  static const List<String> _defaultCategories = [
    'Pottery & Ceramics',
    'Textiles & Handloom',
    'Woodwork',
    'Bamboo & Cane',
    'Metal Craft',
    'Leather Craft',
    'Stone Craft',
    'Jewelry & Accessories',
    'Home Decor',
    'Paintings & Art',
    'Other',
  ];
  late List<String> _categories = List.from(_defaultCategories);

  String get _currentUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.requirement != null) {
      final r = widget.requirement!;
      _titleController.text = r.title;
      _descriptionController.text = r.description;
      _quantityController.text = r.quantity > 0 ? '${r.quantity}' : '';
      _budgetMinController.text = r.budgetMin != null ? '${r.budgetMin!.toInt()}' : '';
      _budgetMaxController.text = r.budgetMax != null ? '${r.budgetMax!.toInt()}' : '';
      _locationController.text = r.deliveryLocation ?? '';
      _customizationController.text = r.customization ?? '';
      if (r.category.isNotEmpty) {
        _selectedCategory = r.category;
        if (!_categories.contains(r.category)) {
          _categories.add(r.category);
        }
      } else {
        _selectedCategory = null;
      }
      _deadline = r.deadline;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _service.getCategories();
      if (cats.isNotEmpty && mounted) {
        setState(() {
          final set = {..._categories, ...cats}.toList()..sort();
          _categories = set;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _locationController.dispose();
    _customizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.requirement != null;
    final uniqueCategories = _categories.toSet().toList();
    final validCategory = (_selectedCategory != null &&
                           _selectedCategory!.isNotEmpty &&
                           uniqueCategories.contains(_selectedCategory))
        ? _selectedCategory
        : null;

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
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          title: Text(
            isEdit ? 'Edit Requirement' : 'Post Requirement',
            style: const TextStyle(
              color: AppColors.brown,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Title *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  decoration: _inputDecoration('e.g. Handwoven cotton dupattas'),
                ),
                const SizedBox(height: 16),

                // Category
                Text(
                  'Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.brown.withValues(alpha: 0.15)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: validCategory,
                      isExpanded: true,
                      hint: Text(
                        'Select category',
                        style: TextStyle(color: AppColors.brown.withValues(alpha: 0.4), fontSize: 14),
                      ),
                      items: uniqueCategories.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(color: AppColors.brown)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

              // Quantity
              Text(
                'Quantity *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Enter valid quantity';
                  return null;
                },
                decoration: _inputDecoration('Number of pieces'),
              ),
              const SizedBox(height: 16),

              // Budget range
              Text(
                'Budget Range (₹/piece)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetMinController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Min ₹'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('-', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetMaxController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Max ₹'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Delivery location
              Text(
                'Delivery Location',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('City / State'),
              ),
              const SizedBox(height: 16),

              // Deadline
              Text(
                'Deadline',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _deadline = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.brown.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: AppColors.brown.withValues(alpha: 0.4)),
                      const SizedBox(width: 10),
                      Text(
                        _deadline != null
                            ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                            : 'Select deadline',
                        style: TextStyle(
                          color: _deadline != null ? AppColors.brown : AppColors.brown.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customization
              Text(
                'Customization Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _customizationController,
                maxLines: 2,
                decoration: _inputDecoration('Colors, sizes, branding, packaging...'),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Description *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: _inputDecoration('Describe your full requirement in detail...'),
              ),
              const SizedBox(height: 20),

              // AI Matcher Quick Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.terracotta.withValues(alpha: 0.08),
                      AppColors.mustardGold.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.terracotta, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Artisan Matcher',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brown,
                            ),
                          ),
                          Text(
                            'Analyze with Groq & find artisans who can make this',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.brown.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _previewAIMatches,
                      icon: const Icon(Icons.bolt, size: 14),
                      label: const Text('Match AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.terracotta.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'Update Requirement' : 'Post & Find Matching Artisans',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.brown.withValues(alpha: 0.35), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.brown.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.brown.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
      ),
    );
  }

  void _previewAIMatches() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter what you need (Title) first!'),
          backgroundColor: AppColors.terracotta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final userId = _currentUserId;
    final requirement = B2BRequirement(
      id: widget.requirement?.id ?? '',
      buyerId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory ?? '',
      quantity: int.tryParse(_quantityController.text) ?? 0,
      budgetMin: double.tryParse(_budgetMinController.text),
      budgetMax: double.tryParse(_budgetMaxController.text),
      deliveryLocation: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      deadline: _deadline,
      customization: _customizationController.text.trim().isEmpty ? null : _customizationController.text.trim(),
      createdAt: widget.requirement?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => B2BAIMatchesScreen(requirement: requirement),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final userId = _currentUserId;
    final requirement = B2BRequirement(
      id: widget.requirement?.id ?? '',
      buyerId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory ?? '',
      quantity: int.tryParse(_quantityController.text) ?? 0,
      budgetMin: double.tryParse(_budgetMinController.text),
      budgetMax: double.tryParse(_budgetMaxController.text),
      deliveryLocation: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      deadline: _deadline,
      customization: _customizationController.text.trim().isEmpty ? null : _customizationController.text.trim(),
      createdAt: widget.requirement?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = widget.requirement != null
        ? await _service.updateRequirement(requirement)
        : await _service.createRequirement(requirement);
    setState(() => _isSubmitting = false);

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.requirement != null ? 'Requirement updated!' : 'Requirement posted! Finding matching artisans...'),
            backgroundColor: AppColors.oliveGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Automatically navigate to AI matched artisans
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BAIMatchesScreen(requirement: result),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed. Please try again.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}

