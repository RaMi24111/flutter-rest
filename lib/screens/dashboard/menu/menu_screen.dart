import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/menu_service.dart';
import 'category_form_dialog.dart';
import 'item_form_dialog.dart';
import 'manual_order_dialog.dart';

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
        if (!cats.any((c) => c.id == _selectedCategoryId)) {
          _selectedCategoryId = '';
        }
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
            preparationTime: item.preparationTime,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete')
          ),
        ],
      )
    );
    
    if (confirm != true) return;
    
    try {
      await MenuService.deleteItem(id);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
    }
  }

  Future<void> _deleteCategory(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete')
          ),
        ],
      )
    );
    
    if (confirm != true) return;
    
    try {
      await MenuService.deleteCategory(id);
      if (_selectedCategoryId == id) {
        setState(() => _selectedCategoryId = '');
      }
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
    }
  }

  void _showCategoryForm([MenuCategory? cat]) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => CategoryFormDialog(category: cat),
    );
    if (result == true) _loadData();
  }

  void _showItemForm([MenuItem? item]) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => ItemFormDialog(
        categories: _categories,
        item: item,
        initialCategoryId: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
      ),
    );
    if (result == true) _loadData();
  }

  void _showManualOrderForm() async {
    await showDialog(
      context: context,
      builder: (ctx) => ManualOrderDialog(menuItems: _items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCustomHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.rubyRed))
                : _error != null
                    ? _buildError()
                    : Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: isDesktop 
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 280, child: _buildSidebar()),
                                const SizedBox(width: 24),
                                Expanded(child: _buildMainContent()),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 300, child: _buildSidebar()),
                                const SizedBox(height: 24),
                                SizedBox(height: MediaQuery.of(context).size.height - 300, child: _buildMainContent()),
                              ],
                            ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      color: AppColors.rubyDark,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/admin/dashboard'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back, color: AppColors.gold, size: 16),
                        const SizedBox(width: 8),
                        Text('Back to Dashboard', style: GoogleFonts.inter(color: AppColors.gold, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Menu Management', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Manage your restaurant menu items and categories', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showManualOrderForm(),
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  label: Text('Create Order', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showItemForm(),
                  icon: const Icon(Icons.add, color: AppColors.rubyDark),
                  label: Text('Add Menu Item', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.rubyDark)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.rubyDark.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.folder_open, color: AppColors.rubyRed),
                const SizedBox(width: 8),
                Text('Categories', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showCategoryForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rubyDark,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text('Add\nCategory', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildSidebarItem(
            id: '',
            name: 'All Items',
            description: 'View all',
            isSelected: _selectedCategoryId.isEmpty,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                return _buildSidebarItem(
                  id: cat.id,
                  name: cat.name,
                  description: cat.description ?? '',
                  isSelected: _selectedCategoryId == cat.id,
                  category: cat,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({required String id, required String name, required String description, required bool isSelected, MenuCategory? category}) {
    return InkWell(
      onTap: () => setState(() => _selectedCategoryId = id),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rubyDark : Colors.transparent,
          border: Border(bottom: BorderSide(color: AppColors.rubyDark.withValues(alpha: 0.1), width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  )),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(description, style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : AppColors.textMuted,
                    ), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]
                ],
              ),
            ),
            if (category != null && isSelected) ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                onPressed: () => _showCategoryForm(category),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              if (_items.where((i) => i.categoryId == category.id).isEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                  onPressed: () => _deleteCategory(category.id),
                  padding: const EdgeInsets.only(left: 8),
                  constraints: const BoxConstraints(),
                )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: false,
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Showing ${_filteredItems.length} items', style: GoogleFonts.inter(color: AppColors.textMuted)),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildItemsGrid()),
      ],
    );
  }

  Widget _buildItemsGrid() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Center(
        child: Text('No items found.', style: GoogleFonts.inter(color: AppColors.textMuted)),
      );
    }
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 900 ? 3 : c.maxWidth > 600 ? 2 : 1;
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.60, // Much taller cards to prevent overflow
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) => _buildItemCard(items[i], i).animate().fadeIn(delay: (i * 30).ms, duration: 400.ms),
      );
    });
  }

  Widget _buildItemCard(MenuItem item, int i) {
    String categoryName = 'General';
    try {
      categoryName = _categories.firstWhere((c) => c.id == item.categoryId).name;
    } catch (_) {}

    return HoverableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: AppColors.ivoryDark,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.restaurant, color: AppColors.textMuted, size: 64)),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.name, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Text('₹${item.price.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.rubyRed)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(categoryName, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(item.description ?? 'No description provided.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Availability', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                      Switch(
                        value: item.isAvailable,
                        onChanged: (_) => _toggleItem(item.id),
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isAvailable ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: item.isAvailable ? AppColors.success.withValues(alpha: 0.3) : AppColors.danger.withValues(alpha: 0.3))
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: item.isAvailable ? AppColors.success : AppColors.danger),
                        const SizedBox(width: 6),
                        Text(item.isAvailable ? 'Available' : 'Unavailable', style: GoogleFonts.inter(fontSize: 10, color: item.isAvailable ? AppColors.success : AppColors.danger)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showItemForm(item),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteItem(item.id),
                          icon: const Icon(Icons.delete, size: 14),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
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
}

class HoverableCard extends StatefulWidget {
  final Widget child;
  const HoverableCard({Key? key, required this.child}) : super(key: key);

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.rubyDark.withValues(alpha: 0.5), width: 1),
          boxShadow: _isHovered ? AppShadows.glow : AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: widget.child,
      ),
    );
  }
}
