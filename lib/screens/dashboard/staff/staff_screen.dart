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
  List<StaffMember> _staff = [];
  bool _isLoading = true;
  String? _error;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String get _roleLabel => widget.role == 'server' ? 'Serving Staff' : 'Billing Staff';
  Color get _accentColor => widget.role == 'server' ? AppColors.rubyRed : const Color(0xFF1D6B8B);
  IconData get _roleIcon =>
      widget.role == 'server' ? Icons.room_service_rounded : Icons.point_of_sale_rounded;

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

      // Debug: print all roles coming from backend
      for (final s in list) {
        debugPrint('Staff: ${s.name} | role="${s.role}"');
      }

      setState(() {
        _staff = list.where((s) {
          final r = s.role.toLowerCase().trim();
          if (widget.role == 'server') {
            return r == 'serving_staff' || r == 'server' || r.contains('serv') || r == 'waiter';
          } else {
            return r == 'billing_staff' || r == 'cashier' || r.contains('bill') || r.contains('cash');
          }
        }).toList();
      });
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(_roleIcon, color: _accentColor, size: 22),
            const SizedBox(width: 10),
            Text('Add $_roleLabel',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
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
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await StaffService.createStaff({
                  'name': _nameCtrl.text,
                  'email': _emailCtrl.text,
                  'password': _passCtrl.text,
                  'role': widget.role,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          // ── Custom Header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: _accentColor,
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 20),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/admin/dashboard/staff'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back, color: AppColors.gold, size: 16),
                              const SizedBox(width: 8),
                              Text('Back to Staff Types',
                                  style: GoogleFonts.inter(color: AppColors.gold, fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(_roleIcon, color: Colors.white, size: 26),
                            const SizedBox(width: 12),
                            Text(_roleLabel,
                                style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${_staff.length} member${_staff.length == 1 ? '' : 's'}',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadStaff,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 4, color: AppColors.gold),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: _accentColor))
                : _error != null
                    ? Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 42),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: GoogleFonts.inter(color: AppColors.textMuted)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _loadStaff, child: const Text('Retry')),
                      ]))
                    : _staff.isEmpty
                        ? _buildEmpty()
                        : LayoutBuilder(builder: (ctx, c) {
                            final cols = c.maxWidth > 700 ? 3 : c.maxWidth > 480 ? 2 : 1;
                            return GridView.builder(
                              padding: const EdgeInsets.all(24),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accentColor,
        onPressed: _showAddDialog,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('Add $_roleLabel',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(_roleIcon, size: 64, color: AppColors.borderLight),
        const SizedBox(height: 16),
        Text('No $_roleLabel yet',
            style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Text('Tap the button below to add your first member.',
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
      ]),
    );
  }

  Widget _buildCard(StaffMember s, int i) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _accentColor,
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
            activeColor: _accentColor,
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(s.role.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _accentColor,
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
