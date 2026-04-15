import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/tables_service.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<TableModel> _tables = [];
  bool _isLoading = true;
  String? _error;
  final _tableNumCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '4');

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _tableNumCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final list = await TablesService.getTables();
      setState(() => _tables = list);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTable(String id) async {
    try {
      await TablesService.toggleTable(id);
      setState(() {
        final idx = _tables.indexWhere((t) => t.id == id);
        if (idx != -1) {
          final t = _tables[idx];
          _tables[idx] = TableModel(
            id: t.id,
            tableNumber: t.tableNumber,
            capacity: t.capacity,
            isActive: !t.isActive,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  void _showAddDialog() {
    _tableNumCtrl.clear();
    _capacityCtrl.text = '4';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Table',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _tableNumCtrl,
            decoration: const InputDecoration(
              labelText: 'Table Number / Name',
              prefixIcon: Icon(Icons.grid_view_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _capacityCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Capacity (seats)',
              prefixIcon: Icon(Icons.people_outline),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rubyRed),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await TablesService.createTable({
                  'table_number': _tableNumCtrl.text,
                  'capacity': int.tryParse(_capacityCtrl.text) ?? 4,
                });
                _loadTables();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: const Text('Table Details'),
        backgroundColor: AppColors.rubyRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTables,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: AppColors.gold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.rubyRed,
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Table',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w700)),
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
                      onPressed: _loadTables, child: const Text('Retry')),
                ]))
              : _tables.isEmpty
                  ? Center(
                      child: Text('No tables configured',
                          style: GoogleFonts.inter(color: AppColors.textMuted)))
                  : LayoutBuilder(builder: (ctx, c) {
                      final cols = c.maxWidth > 700
                          ? 4
                          : c.maxWidth > 480
                              ? 3
                              : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _tables.length,
                        itemBuilder: (ctx, i) => _buildTableCard(_tables[i], i)
                            .animate()
                            .fadeIn(delay: (i * 40).ms),
                      );
                    }),
    );
  }

  Widget _buildTableCard(TableModel t, int i) {
    return GestureDetector(
      onLongPress: () => _toggleTable(t.id),
      child: Container(
        decoration: BoxDecoration(
          color: t.isActive ? Colors.white : AppColors.borderLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: t.isActive ? AppShadows.card : [],
          border: Border.all(
            color: t.isActive
                ? AppColors.gold.withValues(alpha: 0.4)
                : AppColors.borderLight,
            width: t.isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant_rounded,
              size: 36,
              color: t.isActive ? AppColors.rubyRed : AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text('Table',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                )),
            Text(t.tableNumber,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: t.isActive ? AppColors.textDark : AppColors.textMuted,
                )),
            const SizedBox(height: 4),
            Text('${t.capacity} seats',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: t.isActive
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(t.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: t.isActive ? AppColors.success : AppColors.danger,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}


