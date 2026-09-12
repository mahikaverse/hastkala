import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../models/b2b_models.dart';
import '../services/b2b_service.dart';

class B2BOrdersScreen extends StatefulWidget {
  const B2BOrdersScreen({super.key});

  @override
  State<B2BOrdersScreen> createState() => _B2BOrdersScreenState();
}

class _B2BOrdersScreenState extends State<B2BOrdersScreen> {
  final B2BService _service = B2BService();
  List<B2BOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final orders = await _service.getOrders(buyerId: userId);
    setState(() {
      _orders = orders;
      _isLoading = false;
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
          'My Orders',
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.brown.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: AppColors.terracotta,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
    );
  }

  Widget _buildOrderCard(B2BOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: order.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${order.quantity} pcs × ₹${order.pricePerPiece.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppColors.brown.withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.terracotta,
                ),
              ),
            ],
          ),
          if (order.deliveryLocation != null) ...[
            const SizedBox(height: 8),
            Text(
              '📍 ${order.deliveryLocation}',
              style: TextStyle(fontSize: 12, color: AppColors.brown.withValues(alpha: 0.5)),
            ),
          ],
        ],
      ),
    );
  }
}
