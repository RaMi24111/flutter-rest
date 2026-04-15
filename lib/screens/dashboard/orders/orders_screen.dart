import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  String _statusFilter = 'ALL';
  String _searchQuery = '';
  final String _dateFilter = '';

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
      final matchSearch = _searchQuery.isEmpty ||
          o.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus =
          _statusFilter == 'ALL' || o.status.toUpperCase() == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
  }

  double get _totalRevenue => _orders
      .where((o) => o.paymentStatus.toUpperCase() == 'PAID')
      .fold(0, (sum, o) => sum + o.totalAmount);

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'PLACED':
        return AppColors.info;
      case 'CONFIRMED':
        return AppColors.warning;
      case 'PREPARING':
        return const Color(0xFF8B5CF6);
      case 'READY':
        return AppColors.gold;
      case 'SERVED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.danger;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: const Text('Orders Management'),
        backgroundColor: AppColors.rubyRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: AppColors.gold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.rubyRed))
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!,
                      style: GoogleFonts.inter(color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _loadOrders, child: const Text('Retry')),
                ]))
              : Column(
                  children: [
                    _buildStats(isWide),
                    _buildFilters(),
                    Expanded(child: _buildOrdersList(filtered)),
                  ],
                ),
    );
  }

  Widget _buildStats(bool isWide) {
    final stats = [
      ['Total', _orders.length.toString(), AppColors.info],
      [
        'Placed',
        _orders
            .where((o) => o.status.toUpperCase() == 'PLACED')
            .length
            .toString(),
        AppColors.warning
      ],
      [
        'Served',
        _orders
            .where((o) => o.status.toUpperCase() == 'SERVED')
            .length
            .toString(),
        AppColors.success
      ],
      ['Revenue', '₹${_totalRevenue.toStringAsFixed(0)}', AppColors.rubyRed],
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: stats.map((s) {
          final color = s[2] as Color;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s[0] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 4),
                  Text(s[1] as String,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilters() {
    const statuses = [
      'ALL',
      'PLACED',
      'CONFIRMED',
      'PREPARING',
      'READY',
      'SERVED',
      'CANCELLED'
    ];
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by Order ID...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
          ),
          // Status tabs
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              children: statuses.map((s) {
                final isSelected = _statusFilter == s;
                return GestureDetector(
                  onTap: () => setState(() => _statusFilter = s),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.rubyRed : AppColors.ivory,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.rubyRed
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Center(
                      child: Text(s,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? Colors.white : AppColors.textMuted,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.receipt_long_outlined,
            size: 48, color: AppColors.borderLight),
        const SizedBox(height: 12),
        Text('No orders found',
            style: GoogleFonts.inter(color: AppColors.textMuted)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) =>
          _buildOrderRow(orders[i], i).animate().fadeIn(delay: (i * 30).ms),
    );
  }

  Widget _buildOrderRow(OrderModel o, int i) {
    final sc = _statusColor(o.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: sc.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.receipt_outlined, color: sc, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${o.id.length > 8 ? o.id.substring(0, 8) : o.id}',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text('${o.orderType} • ${o.tableNumber ?? "–"}',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${o.totalAmount.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100)),
            child: Text(o.status.toUpperCase(),
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: sc,
                    letterSpacing: 0.5)),
          ),
        ]),
      ]),
    );
  }
}


