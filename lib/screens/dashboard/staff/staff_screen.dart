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
      backgroundColor: AppColors.rubyDark,
      body: Stack(
        children: [
          // ── Royal Background ───────────────────────────────────────
          Positioned.fill(
            child: Container(
              color: AppColors.rubyDark,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.2,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=2070&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.rubyDark.withOpacity(0.8),
                        ],
                        radius: 1.2,
                      ),
                    ),
                  ),
                  // Animated Golden Circles
                  const _AnimatedGoldenCircles(),
                ],
              ),
            ),
          ),

          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsRow(),
                                const SizedBox(height: 40),
                                
                                // ── Main Content Card (Ivory) ────────────────
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.ivory,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(32),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildFiltersBar(),
                                            const SizedBox(height: 32),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Showing ${_filteredStaff.length} ${widget.role == 'server' ? 'serving' : 'billing'} staff members',
                                                  style: GoogleFonts.inter(
                                                    color: AppColors.rubyDark.withOpacity(0.6),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                _StatusBadge(isActive: true), // Using local widget
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildStaffList(),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.rubyDark.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: AppColors.gold, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/admin/dashboard/staff'),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 14),
                            const SizedBox(width: 8),
                            Text('Back to Selection',
                                style: GoogleFonts.inter(
                                  color: AppColors.gold, 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_roleLabel,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white, 
                          fontSize: 44, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        )),
                    const SizedBox(height: 4),
                    Text(_roleSubtitle,
                        style: GoogleFonts.inter(
                          color: AppColors.gold.withOpacity(0.7), 
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        )),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.rubyDark, size: 20),
                  label: Text('NEW MEMBER', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.rubyDark,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    shadowColor: AppColors.gold.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
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
        _buildStatCard('TOTAL STAFF', total.toString(), AppColors.gold, Icons.group_rounded),
        const SizedBox(width: 24),
        _buildStatCard('ACTIVE NOW', active.toString(), Colors.greenAccent, Icons.check_circle_outline_rounded),
        const SizedBox(width: 24),
        _buildStatCard('INACTIVE', inactive.toString(), Colors.redAccent, Icons.pause_circle_outline_rounded),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.gold, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(color: AppColors.rubyDark, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Find a member...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 16)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.gold),
              items: ['All Status', 'Active', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
              onChanged: (v) {
                setState(() {
                  _statusFilter = v!;
                  _applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.rubyDark.withOpacity(0.03),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              _headerCell('MEMBER', 3),
              _headerCell('CONTACT INFO', 3),
              _headerCell('PERMISSION', 2),
              _headerCell('STATUS', 1),
              _headerCell('ACTIONS', 1),
            ],
          ),
        ),
        // List Items
        if (_filteredStaff.isEmpty)
           Padding(
             padding: const EdgeInsets.all(60),
             child: Center(
               child: Column(
                 children: [
                   Icon(Icons.person_search_rounded, size: 64, color: AppColors.gold.withOpacity(0.3)),
                   const SizedBox(height: 16),
                   Text('No staff members found', style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
                 ],
               ),
             ),
           )
        else
          ..._filteredStaff.asMap().entries.map((entry) => _buildStaffRow(entry.value, entry.key)),
      ],
    );
  }

  Widget _headerCell(String label, int flex) {
    return Expanded(
      flex: flex, 
      child: Text(label, 
        style: GoogleFonts.inter(
          fontSize: 11, 
          fontWeight: FontWeight.w900, 
          color: AppColors.rubyDark.withOpacity(0.4),
          letterSpacing: 1.5,
        )
      )
    );
  }

  Widget _buildStaffRow(StaffMember s, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        border: index == _filteredStaff.length - 1 ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, size: 24, color: AppColors.gold),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.rubyDark)),
                    Text('Restaurant Staff', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          // Email & Phone
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.email, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.rubyDark.withOpacity(0.8))),
                const SizedBox(height: 4),
                Text(s.phone ?? 'No phone provided', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),
          // Role Badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.rubyDark.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.rubyDark.withOpacity(0.1)),
                ),
                child: Text(_roleLabel.toUpperCase(), 
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.rubyDark, letterSpacing: 1)),
              ),
            ),
          ),
          // Status Toggle
          Expanded(
            flex: 1,
            child: Switch(
              value: s.isActive,
              onChanged: (v) => _toggleStaff(s.id),
              activeColor: Colors.green,
              activeTrackColor: Colors.green.withOpacity(0.2),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionIcon(Icons.edit_note_rounded, AppColors.gold, () {}),
                const SizedBox(width: 16),
                _actionIcon(Icons.delete_sweep_rounded, Colors.redAccent.withOpacity(0.7), () => _deleteStaff(s.id)),
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('LIVE SYSTEM', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _AnimatedGoldenCircles extends StatelessWidget {
  const _AnimatedGoldenCircles();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: List.generate(4, (index) {
          final delay = index * 1.5;
          return Align(
            alignment: Alignment.center,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.15), // Thin, hollow, golden, subtle
                  width: 1.5,
                ),
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).scale(
              duration: 6.seconds, 
              delay: delay.seconds,
              begin: const Offset(1, 1), 
              end: const Offset(15, 15), // Expands outward
              curve: Curves.easeOutCubic,
            ).fade(
              duration: 6.seconds,
              delay: delay.seconds,
              begin: 1.0,
              end: 0.0,
              curve: Curves.easeOutCubic,
            ),
          );
        }),
      ),
    );
  }
}
