import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/craft_image_helper.dart';
import '../../../core/models/marketplace_product.dart';
import '../models/b2b_models.dart';
import '../services/b2b_service.dart';

class B2BEnquiryFormScreen extends StatefulWidget {
  final MarketplaceProduct? product;
  final String? artisanId;
  final String? artisanName;
  final String? requirementId;

  const B2BEnquiryFormScreen({
    super.key,
    this.product,
    this.artisanId,
    this.artisanName,
    this.requirementId,
  });

  @override
  State<B2BEnquiryFormScreen> createState() => _B2BEnquiryFormScreenState();
}

class _B2BEnquiryFormScreenState extends State<B2BEnquiryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _quantityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _customizationController = TextEditingController();
  final B2BService _service = B2BService();
  bool _isSubmitting = false;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _quantityController.text = '${widget.product!.stockQuantity}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _quantityController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _customizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productName = widget.product?.name ?? widget.artisanName ?? 'Artisan';
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
          'Send Enquiry',
          style: TextStyle(
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
              // Product / Artisan reference
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brown.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.product?.imageUrls.isNotEmpty == true)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product!.imageUrls.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              CraftImageHelper.getImageForProduct(
                                productId: widget.product!.id,
                                craftType: widget.product!.craftType,
                                category: widget.product!.category,
                                name: widget.product!.name,
                              ),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.product != null
                              ? CraftImageHelper.getImageForProduct(
                                  productId: widget.product!.id,
                                  craftType: widget.product!.craftType,
                                  category: widget.product!.category,
                                  name: widget.product!.name,
                                )
                              : 'assets/default-bg.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.brown,
                              fontSize: 14,
                            ),
                          ),
                          if (widget.product != null)
                            Text(
                              '₹${widget.product!.price.toStringAsFixed(0)}/piece',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.terracotta,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quantity
              Text(
                'Quantity *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown.withValues(alpha: 0.7),
                ),
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
                decoration: _inputDecoration('Enter quantity'),
              ),
              const SizedBox(height: 16),

              // Budget per piece
              Text(
                'Budget per piece (₹)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Your target price'),
              ),
              const SizedBox(height: 16),

              // Delivery location
              Text(
                'Delivery Location',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown.withValues(alpha: 0.7),
                ),
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown.withValues(alpha: 0.7),
                ),
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
                    border: Border.all(
                      color: AppColors.brown.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.brown.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _deadline != null
                            ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                            : 'Select date',
                        style: TextStyle(
                          color: _deadline != null
                              ? AppColors.brown
                              : AppColors.brown.withValues(alpha: 0.4),
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
                'Customization Requirements',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _customizationController,
                maxLines: 2,
                decoration: _inputDecoration('Colors, sizes, branding, packaging...'),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Message *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: _inputDecoration('Describe your requirement in detail...'),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEnquiry,
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send Enquiry',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.brown.withValues(alpha: 0.35),
        fontSize: 14,
      ),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Future<void> _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final userName = Supabase.instance.client.auth.currentUser?.email ?? '';

    final enquiry = B2BEnquiry(
      id: '',
      buyerId: userId,
      buyerName: userName,
      artisanId: widget.artisanId ?? widget.product?.artisanId ?? '',
      productId: widget.product?.id,
      requirementId: widget.requirementId,
      message: _messageController.text.trim(),
      quantity: int.tryParse(_quantityController.text) ?? 0,
      budget: double.tryParse(_budgetController.text),
      deliveryLocation: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      deadline: _deadline,
      customization: _customizationController.text.trim().isEmpty
          ? null
          : _customizationController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _service.createEnquiry(enquiry);
    setState(() => _isSubmitting = false);

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Enquiry sent successfully!'),
            backgroundColor: AppColors.oliveGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send enquiry. Please try again.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
