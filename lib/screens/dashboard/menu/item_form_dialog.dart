import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/menu_service.dart';

class ItemFormDialog extends StatefulWidget {
  final List<MenuCategory> categories;
  final MenuItem? item;
  final String? initialCategoryId;

  const ItemFormDialog({
    super.key,
    required this.categories,
    this.item,
    this.initialCategoryId,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late String _description;
  late String _price;
  late String _prepTime;
  late String _imageUrl;
  String? _selectedCategoryId;
  late bool _isAvailable;
  bool _isSpecial = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.item?.name ?? '';
    _description = widget.item?.description ?? '';
    _price = widget.item != null ? widget.item!.price.toStringAsFixed(2) : '';
    _prepTime = widget.item?.preparationTime ?? '';
    _imageUrl = widget.item?.imageUrl ?? '';
    _isAvailable = widget.item?.isAvailable ?? true;
    
    if (widget.item != null) {
      _selectedCategoryId = widget.item!.categoryId;
    } else if (widget.initialCategoryId != null && widget.initialCategoryId!.isNotEmpty) {
      _selectedCategoryId = widget.initialCategoryId;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final body = {
        'name': _name,
        'description': _description.isEmpty ? null : _description,
        'price': double.tryParse(_price) ?? 0.0,
        'imageUrl': _imageUrl.isEmpty ? null : _imageUrl,
        'image_url': _imageUrl.isEmpty ? null : _imageUrl,
        'categoryId': _selectedCategoryId,
        'category_id': _selectedCategoryId,
        'isAvailable': _isAvailable,
        'is_available': _isAvailable,
        'isSpecial': _isSpecial,
        'is_special': _isSpecial,
      };

      if (widget.item == null) {
        await MenuService.createItem(body);
      } else {
        await MenuService.updateItem(widget.item!.id, body);
      }
      
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('You must create a category first before adding an item.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.item == null ? 'Add Menu Item' : 'Edit Menu Item',
        style: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.rubyRed,
        ),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: widget.categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _price,
                  decoration: const InputDecoration(labelText: 'Price (₹)', prefixText: '₹ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) => val == null || double.tryParse(val) == null ? 'Valid price required' : null,
                  onSaved: (val) => _price = val!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _imageUrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  onSaved: (val) => _imageUrl = val?.trim() ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onSaved: (val) => _description = val?.trim() ?? '',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Available', style: TextStyle(fontSize: 14)),
                        activeColor: AppColors.success,
                        value: _isAvailable,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Special', style: TextStyle(fontSize: 14)),
                        activeColor: AppColors.rubyRed,
                        value: _isSpecial,
                        onChanged: (val) => setState(() => _isSpecial = val),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(widget.item == null ? 'Add Item' : 'Save Changes'),
        ),
      ],
    );
  }
}
