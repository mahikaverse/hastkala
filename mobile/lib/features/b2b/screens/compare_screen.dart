import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/marketplace_product.dart';

class CompareScreen extends StatefulWidget {
  final MarketplaceProduct? initialProduct;

  const CompareScreen({super.key, this.initialProduct});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<MarketplaceProduct> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _selectedProducts.add(widget.initialProduct!);
    }
  }


  void _removeProduct(String id) {
    setState(() {
      _selectedProducts.removeWhere((p) => p.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Compare Products',
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _selectedProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 64,
                    color: AppColors.brown.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products to compare',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select products from Explore to compare',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.brown.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Product headers
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _selectedProducts[index];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.brown.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brown,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeProduct(product.id),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.brown.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}/pc',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.terracotta,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Comparison table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Table(
                      columnWidths: {
                        0: const FlexColumnWidth(1.5),
                        for (var i = 0; i < _selectedProducts.length; i++)
                          i + 1: const FlexColumnWidth(1),
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: AppColors.brown.withValues(alpha: 0.08),
                        ),
                      ),
                      children: [
                        _buildRow('Price', (p) => '₹${p.price.toStringAsFixed(0)}'),
                        _buildRow('Category', (p) => p.category.isNotEmpty ? p.category : '-'),
                        _buildRow('Craft Type', (p) => (p.craftType ?? '').isNotEmpty ? (p.craftType ?? '') : '-'),
                        _buildRow('Material', (p) => (p.material ?? '').isNotEmpty ? (p.material ?? '') : '-'),
                        _buildRow('Stock', (p) => '${p.stockQuantity} pcs'),
                        _buildRow('Description', (p) {
                          final desc = p.description;
                          return desc.length > 80 ? '${desc.substring(0, 80)}...' : desc;
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  TableRow _buildRow(String label, String Function(MarketplaceProduct) extractor) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x0F000000)),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brown.withValues(alpha: 0.6),
            ),
          ),
        ),
        ..._selectedProducts.map((product) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              extractor(product),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.brown,
              ),
            ),
          );
        }),
      ],
    );
  }
}
