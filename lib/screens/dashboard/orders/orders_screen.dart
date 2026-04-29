import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/orders_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  
  // Filters
  String _statusFilter = 'All Status';
  String _paymentFilter = 'All Payments';
  String _typeFilter = 'All Types';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final list = await OrdersService.getOrders();
      setState(() => _orders = list);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<OrderModel> get _filtered {
    return _orders.where((o) {
      final matchSearch = _searchQuery.isEmpty || o.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus = _statusFilter == 'All Status' || o.status.toUpperCase() == _statusFilter.toUpperCase();
      final matchPayment = _paymentFilter == 'All Payments' || o.paymentStatus.toUpperCase() == _paymentFilter.toUpperCase();
      final matchType = _typeFilter == 'All Types' || o.orderType.toUpperCase().replaceAll('-', '_') == _typeFilter.toUpperCase().replaceAll(' ', '_');
      
      return matchSearch && matchStatus && matchPayment && matchType;
    }).toList();
  }

  double get _totalRevenue => _orders
      .where((o) => o.paymentStatus.toUpperCase() == 'PAID')
      .fold(0, (sum, o) => sum + o.totalAmount);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.rubyRed))
                : _error != null
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsGrid(),
                            const SizedBox(height: 24),
                            _buildFilterSection(),
                            const SizedBox(height: 24),
                            Text('Showing ${filtered.length} orders', 
                              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                            _buildOrdersTable(filtered),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      decoration: const BoxDecoration(
        color: AppColors.rubyDark,
      ),
      child: Column(
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/admin/dashboard'),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                label: const Text('Back to Dashboard', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text('Orders Management', 
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display')),
                      Text('View and track all customer orders', 
                        style: TextStyle(color: AppColors.gold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 160), // Spacer to balance the back button
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _statCard('Total Orders', _orders.length.toString(), AppColors.textDark),
        const SizedBox(width: 16),
        _statCard('Pending', _orders.where((o) => o.status == 'PLACED').length.toString(), AppColors.warning),
        const SizedBox(width: 16),
        _statCard('Completed', _orders.where((o) => o.status == 'SERVED').length.toString(), AppColors.success),
        const SizedBox(width: 16),
        _statCard('Total Revenue', '₹${_totalRevenue.toStringAsFixed(2)}', AppColors.rubyRed),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text('Filters', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by Order ID...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown(_statusFilter, ['All Status', 'PLACED', 'CONFIRMED', 'PREPARING', 'READY', 'SERVED', 'CANCELLED'], (v) => setState(() => _statusFilter = v!))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown(_paymentFilter, ['All Payments', 'PAID', 'PENDING'], (v) => setState(() => _paymentFilter = v!))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown(_typeFilter, ['All Types', 'Dine In', 'Takeaway'], (v) => setState(() => _typeFilter = v!))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOrdersTable(List<OrderModel> orders) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          dataRowMaxHeight: 70,
          columns: const [
            DataColumn(label: Text('ORDER ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('ORDER TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('TOTAL AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PAYMENT STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('CREATED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: orders.map((o) => DataRow(cells: [
            DataCell(Text('#${o.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.rubyDark))),
            DataCell(_badge(o.orderType.replaceAll('_', ' '), const Color(0xFFE0F2FE), const Color(0xFF0284C7))),
            DataCell(_statusIcon(o.status)),
            DataCell(Text('₹${o.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(_badge(o.paymentStatus, o.paymentStatus == 'PAID' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3), o.paymentStatus == 'PAID' ? const Color(0xFF16A34A) : const Color(0xFFCA8A04))),
            DataCell(Text(DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.tryParse(o.createdAt) ?? DateTime.now()), style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
            DataCell(ElevatedButton.icon(
              onPressed: () => _showOrderDetails(o),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )),
          ])).toList(),
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(text.toUpperCase(), style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusIcon(String status) {
    // Matches the small rectangle in user's screenshot if status is not SERVED? 
    // Actually, let's use a nice outlined rectangle/status bar.
    return Container(
      width: 24,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => _OrderDetailsDialog(order: order),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(_error!, style: GoogleFonts.inter(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailsDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy at hh:mm a');
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 750,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Details', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.rubyDark)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          _summaryItem('Order ID', '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}', isBold: true),
                          _summaryItem('Order Type', order.orderType.replaceAll('_', ' ').toUpperCase(), isBold: true),
                          _summaryItem('Status', order.status.toUpperCase(), isBadge: true, badgeCol: const Color(0xFFFEF9C3), textCol: const Color(0xFFCA8A04)),
                          _summaryItem('Payment', order.paymentStatus.toUpperCase(), isBadge: true, badgeCol: const Color(0xFFFEF9C3), textCol: const Color(0xFFCA8A04)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.rubyDark),
                        const SizedBox(width: 8),
                        Text('Order Items', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.rubyDark)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Items Table
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            color: Colors.grey.shade50,
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(child: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                                Expanded(child: Center(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                                Expanded(child: Center(child: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                              ],
                            ),
                          ),
                          ...order.items.map((item) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(item.name, style: const TextStyle(fontSize: 14))),
                                Expanded(child: Center(child: Text(item.quantity.toString(), style: const TextStyle(fontSize: 14)))),
                                Expanded(child: Center(child: Text(item.price.toStringAsFixed(2), style: const TextStyle(fontSize: 14)))),
                                Expanded(child: Center(child: Text((item.price * item.quantity).toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.rubyDark)))),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Price Breakdown
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _priceRow('Subtotal', order.calculatedSubtotal.toStringAsFixed(2)),
                          const SizedBox(height: 8),
                          _priceRow('Tax', '0.00'),
                          const Divider(height: 24),
                          _priceRow('Total', (order.totalAmount > 0 ? order.totalAmount : order.calculatedSubtotal).toStringAsFixed(2), isTotal: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _infoBox(
                            Icons.payment,
                            'Payment Information',
                            [
                              'Method: ${order.paymentMethod ?? "N/A"}',
                              'Status: ${order.paymentStatus.toUpperCase()}',
                            ],
                            const Color(0xFFEFF6FF),
                            const Color(0xFF1E40AF),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _infoBox(
                            Icons.access_time,
                            'Timestamps',
                            [
                              'Created: ${dateFormat.format(DateTime.tryParse(order.createdAt) ?? DateTime.now())}',
                              'Updated: ${order.updatedAt != null ? dateFormat.format(DateTime.tryParse(order.updatedAt!) ?? DateTime.now()) : dateFormat.format(DateTime.tryParse(order.createdAt) ?? DateTime.now())}',
                            ],
                            const Color(0xFFFAF5FF),
                            const Color(0xFF6B21A8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, {bool isBold = false, bool isBadge = false, Color? badgeCol, Color? textCol}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: badgeCol, borderRadius: BorderRadius.circular(100)),
              child: Text(value, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          else
            Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14, color: AppColors.rubyDark)),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text('₹$value', style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.bold, color: isTotal ? AppColors.rubyDark : AppColors.textDark)),
      ],
    );
  }

  Widget _infoBox(IconData icon, String title, List<String> lines, Color bg, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accent)),
            ],
          ),
          const SizedBox(height: 8),
          ...lines.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(l, style: TextStyle(fontSize: 12, color: accent.withOpacity(0.8), fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    );
  }
}
