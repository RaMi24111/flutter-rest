import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/staff_service.dart';

class StaffScreen extends StatefulWidget {
  /// 'server' for Serving Staff, 'cashier' for Billing Staff
  final String role;
  const StaffScreen({super.key, required this.role});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<StaffMember> _allStaff = [];
  List<StaffMember> _filteredStaff = [];
  bool _isLoading = true;
  String? _error;

  final _searchController = TextEditingController();
  String _statusFilter = 'All Status';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String get _roleLabel => widget.role == 'server' ? 'Serving Staff' : 'Billing Staff';
  String get _roleSubtitle => widget.role == 'server' 
      ? 'Manage floor staff and service assignments' 
      : 'Manage cashier terminals and transaction logs';

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final list = await StaffService.getStaff();
      
      setState(() {
        _allStaff = list.where((s) {
          final r = s.role.toLowerCase().trim();
          if (widget.role == 'server') {
            return r == 'serving_staff' || r == 'server' || r.contains('serv') || r == 'waiter';
          } else {
            return r == 'billing_staff' || r == 'cashier' || r.contains('bill') || r.contains('cash');
          }
        }).toList();
        _applyFilters();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStaff = _allStaff.where((s) {
        final matchesSearch = s.name.toLowerCase().contains(query) || 
                             s.email.toLowerCase().contains(query);
        final matchesStatus = _statusFilter == 'All Status' ||
            (_statusFilter == 'Active' && s.isActive) ||
            (_statusFilter == 'Inactive' && !s.isActive);
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _toggleStaff(String id) async {
    try {
      await StaffService.toggleStaff(id);
      _loadStaff();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _deleteStaff(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Staff Member'),
        content: const Text('Are you sure you want to delete this staff member?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await StaffService.deleteStaff(id);
        _loadStaff();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }

  void _showAddDialog() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();
    _phoneCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $_roleLabel', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 12),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              const SizedBox(height: 12),
              TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rubyRed),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await StaffService.createStaff({
                  'name': _nameCtrl.text,
                  'email': _emailCtrl.text,
                  'password': _passCtrl.text,
                  'phone': _phoneCtrl.text,
                  'role': widget.role == 'server' ? 'SERVING_STAFF' : 'BILLING_STAFF',
                });
                _loadStaff();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
      backgroundColor: const Color(0xFFF8F5F2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rubyRed))
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(),
                        const SizedBox(height: 24),
                        _buildFiltersBar(),
                        const SizedBox(height: 24),
                        Text('Showing ${_filteredStaff.length} ${widget.role == 'server' ? 'serving' : 'billing'} staff members',
                            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 16),
                        _buildStaffList(),
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
      color: AppColors.rubyDark,
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.go('/admin/dashboard/staff'),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, color: AppColors.gold, size: 14),
                      const SizedBox(width: 8),
                      Text('Back to Staff Management',
                          style: GoogleFonts.inter(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(_roleLabel,
                    style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_roleSubtitle,
                    style: GoogleFonts.inter(color: AppColors.gold.withOpacity(0.8), fontSize: 14)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.rubyDark, size: 18),
              label: Text('Add $_roleLabel', style: GoogleFonts.inter(color: AppColors.rubyDark, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _allStaff.length;
    final active = _allStaff.where((s) => s.isActive).length;
    final inactive = total - active;

    return Row(
      children: [
        _buildStatCard('Total $_roleLabel', total.toString(), Colors.black),
        const SizedBox(width: 20),
        _buildStatCard('Active', active.toString(), Colors.green),
        const SizedBox(width: 20),
        _buildStatCard('Inactive', inactive.toString(), Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                items: ['All Status', 'Active', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 14)))).toList(),
                onChanged: (v) {
                  setState(() {
                    _statusFilter = v!;
                    _applyFilters();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              children: [
                _headerCell('NAME', 2),
                _headerCell('EMAIL', 2),
                _headerCell('ROLE', 2),
                _headerCell('PHONE', 2),
                _headerCell('STATUS', 1),
                _headerCell('ACTIONS', 1),
              ],
            ),
          ),
          // List Items
          ..._filteredStaff.asMap().entries.map((entry) => _buildStaffRow(entry.value, entry.key)),
        ],
      ),
    );
  }

  Widget _headerCell(String label, int flex) {
    return Expanded(flex: flex, child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)));
  }

  Widget _buildStaffRow(StaffMember s, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: index == _filteredStaff.length - 1 ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textMuted),
                ),
                const SizedBox(width: 12),
                Text(s.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.rubyDark)),
              ],
            ),
          ),
          // Email
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.mail_outline_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(s.email, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
          // Role
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(100)),
                child: Text(_roleLabel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
              ),
            ),
          ),
          // Phone
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(s.phone ?? '—', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
          // Status Toggle
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Switch(
                value: s.isActive,
                onChanged: (v) => _toggleStaff(s.id),
                activeColor: Colors.green,
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              children: [
                _actionIcon(Icons.edit_outlined, Colors.blue.shade400, () {}),
                const SizedBox(width: 12),
                _actionIcon(Icons.delete_outline_rounded, Colors.red.shade400, () => _deleteStaff(s.id)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: color),
    );
  }
}
