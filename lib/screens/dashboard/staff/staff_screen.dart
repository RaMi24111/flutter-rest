import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';
import 'package:restaurant_admin/services/staff_service.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<StaffMember> _staff = [];
  bool _isLoading = true;
  String? _error;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _selectedRole = 'server';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final list = await StaffService.getStaff();
      setState(() => _staff = list);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStaff(String id) async {
    try {
      await StaffService.toggleStaff(id);
      setState(() {
        final idx = _staff.indexWhere((s) => s.id == id);
        if (idx != -1) {
          final s = _staff[idx];
          _staff[idx] = StaffMember(
            id: s.id,
            name: s.name,
            email: s.email,
            role: s.role,
            isActive: !s.isActive,
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
    _nameCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();
    _selectedRole = 'server';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Staff Member',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
              TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 12),
              TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['server', 'cashier']
                    .map((r) => DropdownMenuItem(
                        value: r, child: Text(r.toUpperCase())))
                    .toList(),
                onChanged: (v) => setDlg(() => _selectedRole = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.rubyRed),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await StaffService.createStaff({
                    'name': _nameCtrl.text,
                    'email': _emailCtrl.text,
                    'password': _passCtrl.text,
                    'role': _selectedRole,
                  });
                  _loadStaff();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: AppColors.rubyRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStaff,
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
        label: Text('Add Staff',
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
                      onPressed: _loadStaff, child: const Text('Retry')),
                ]))
              : _staff.isEmpty
                  ? Center(
                      child: Text('No staff members found',
                          style: GoogleFonts.inter(color: AppColors.textMuted)))
                  : LayoutBuilder(builder: (ctx, c) {
                      final cols = c.maxWidth > 700
                          ? 3
                          : c.maxWidth > 480
                              ? 2
                              : 1;
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: _staff.length,
                        itemBuilder: (ctx, i) => _buildCard(_staff[i], i)
                            .animate()
                            .fadeIn(delay: (i * 60).ms),
                      );
                    }),
    );
  }

  Widget _buildCard(StaffMember s, int i) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.rubyRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rubyRed,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(s.name,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(s.email,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ])),
          Switch(
            value: s.isActive,
            onChanged: (_) => _toggleStaff(s.id),
            activeThumbColor: AppColors.success,
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.rubyRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(s.role.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.rubyRed,
                  letterSpacing: 1,
                )),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: s.isActive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(s.isActive ? 'ACTIVE' : 'INACTIVE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: s.isActive ? AppColors.success : AppColors.danger,
                  letterSpacing: 1,
                )),
          ),
        ]),
      ]),
    );
  }
}


