import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/menu_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuCategory> _categories = [];
  List<MenuItem> _items = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategoryId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final cats = await MenuService.getCategories();
      final items = await MenuService.getItems();
      setState(() {
        _categories = cats;
        _items = items;
        _selectedCategoryId = cats.isNotEmpty ? cats.first.id : '';
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<MenuItem> get _filteredItems => _selectedCategoryId.isEmpty
      ? _items
      : _items.where((i) => i.categoryId == _selectedCategoryId).toList();

  Future<void> _toggleItem(String id) async {
    try {
      await MenuService.toggleItem(id);
      setState(() {
        final idx = _items.indexWhere((i) => i.id == id);
        if (idx != -1) {
          final item = _items[idx];
          _items[idx] = MenuItem(
            id: item.id,
            name: item.name,
            description: item.description,
            price: item.price,
            isAvailable: !item.isAvailable,
            imageUrl: item.imageUrl,
            categoryId: item.categoryId,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: AppColors.rubyRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(height: 4, color: AppColors.gold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.rubyRed))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildCategoryTabs(),
                    Expanded(child: _buildItemsGrid()),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: AppColors.danger, size: 42),
        const SizedBox(height: 12),
        Text(_error!, style: GoogleFonts.inter(color: AppColors.textMuted)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
      ]),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length + 1,
        itemBuilder: (ctx, i) {
          final isAll = i == 0;
          final catId = isAll ? '' : _categories[i - 1].id;
          final label = isAll ? 'All' : _categories[i - 1].name;
          final isSelected = _selectedCategoryId == catId;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = catId),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.rubyRed : AppColors.ivory,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Center(
        child: Text('No items in this category',
            style: GoogleFonts.inter(color: AppColors.textMuted)),
      );
    }
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 700
          ? 3
          : c.maxWidth > 480
              ? 2
              : 1;
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) =>
            _buildItemCard(items[i], i).animate().fadeIn(delay: (i * 50).ms),
      );
    });
  }

  Widget _buildItemCard(MenuItem item, int i) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.ivory,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant,
                    color: AppColors.rubyRed, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('₹${item.price.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.rubyRed,
                          )),
                    ]),
              ),
              Switch(
                value: item.isAvailable,
                onChanged: (_) => _toggleItem(item.id),
                activeThumbColor: AppColors.success,
              ),
            ],
          ),
          if (item.description != null) ...[
            const SizedBox(height: 8),
            Text(item.description!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.isAvailable
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              item.isAvailable ? '● Available' : '○ Unavailable',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: item.isAvailable ? AppColors.success : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


