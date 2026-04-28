import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/orders_service.dart';
import 'package:restaurant_admin/services/tables_service.dart';

class ManualOrderDialog extends StatefulWidget {
  final List<MenuItem> menuItems;

  const ManualOrderDialog({super.key, required this.menuItems});

  @override
  State<ManualOrderDialog> createState() => _ManualOrderDialogState();
}

class _ManualOrderDialogState extends State<ManualOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Walk-in Customer');
  final _phoneCtrl = TextEditingController();

  List<TableModel> _tables = [];
  String? _selectedTableId;
  bool _isLoadingTables = true;
  bool _isSubmitting = false;

  final Map<String, int> _selectedItems = {}; // menuItemId -> quantity

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      final tables = await TablesService.getTables();
      setState(() {
        _tables = tables;
        _isLoadingTables = false;
      });
    } catch (e) {
      setState(() => _isLoadingTables = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tables: $e')),
        );
      }
    }
  }

  double get _totalAmount {
    double total = 0;
    _selectedItems.forEach((itemId, qty) {
      final item = widget.menuItems.firstWhere((i) => i.id == itemId);
      total += item.price * qty;
    });
    return total;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a table')),
      );
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final itemsList = _selectedItems.entries.map((e) {
        return {
          "menu_item_id": e.key,
          "quantity": e.value,
        };
      }).toList();

      final payload = {
        "table_id": _selectedTableId,
        "customer_name": _nameCtrl.text.trim(),
        "customer_phone": _phoneCtrl.text.trim(),
        "items": itemsList,
      };

      await OrdersService.createOrder(payload);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create order: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isDesktop ? 800 : size.width * 0.9,
        height: size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.rubyDark,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Create Manual Order', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: isDesktop ? _buildDesktopBody() : _buildMobileBody(),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹${_totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.rubyRed),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rubyRed,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Submit Order', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Details
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.borderLight)),
            ),
            child: _buildOrderDetailsForm(),
          ),
        ),
        // Right side: Menu selection
        Expanded(
          flex: 6,
          child: Container(
            color: AppColors.ivory,
            child: _buildMenuSelection(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildOrderDetailsForm(),
          ),
        ),
        Container(height: 1, color: AppColors.borderLight),
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.ivory,
            child: _buildMenuSelection(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Details', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          // Table selection
          const Text('Table', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          _isLoadingTables
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  value: _selectedTableId,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
                  hint: const Text('Select a table'),
                  items: _tables.map((t) => DropdownMenuItem(value: t.id, child: Text('Table ${t.tableNumber}'))).toList(),
                  onChanged: (v) => setState(() => _selectedTableId = v),
                  validator: (v) => v == null ? 'Please select a table' : null,
                ),
          
          const SizedBox(height: 20),

          const Text('Customer Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          
          const SizedBox(height: 20),

          const Text('Customer Phone (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSelection() {
    // Filter out unavailable items
    final availableItems = widget.menuItems.where((i) => i.isAvailable).toList();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.restaurant_menu),
              const SizedBox(width: 8),
              Text('Menu Items', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: availableItems.isEmpty 
          ? const Center(child: Text('No available items.'))
          : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: availableItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final item = availableItems[i];
              final qty = _selectedItems[item.id] ?? 0;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.card,
                  border: Border.all(color: qty > 0 ? AppColors.rubyRed.withValues(alpha: 0.3) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(item.imageUrl!, width: 60, height: 60, fit: BoxFit.cover),
                      )
                    else
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: AppColors.ivoryDark, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.fastfood, color: AppColors.textMuted),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('₹${item.price.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (qty > 0) ...[
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.rubyRed),
                            onPressed: () {
                              setState(() {
                                if (qty == 1) {
                                  _selectedItems.remove(item.id);
                                } else {
                                  _selectedItems[item.id] = qty - 1;
                                }
                              });
                            },
                          ),
                          Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.success),
                          onPressed: () {
                            setState(() {
                              _selectedItems[item.id] = qty + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
