import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_admin/core/constants.dart';

class StaffLandingScreen extends StatelessWidget {
  const StaffLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.rubyDark,
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
            child: SafeArea(
              bottom: false,
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
                        Text('Back to Dashboard',
                            style: GoogleFonts.inter(color: AppColors.gold, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Staff Management',
                      style: GoogleFonts.playfairDisplay(
                          color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Select a staff category to manage',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
          Container(height: 4, color: AppColors.gold),

          // ── Two Option Cards ──────────────────────────────────────────────
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: LayoutBuilder(builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _StaffTypeCard(
                        title: 'Serving Staff',
                        icon: Icons.room_service_rounded,
                        accentColor: AppColors.rubyRed,
                        role: 'server',
                        index: 0,
                      ),
                      SizedBox(width: isWide ? 32 : 0, height: isWide ? 0 : 24),
                      _StaffTypeCard(
                        title: 'Billing Staff',
                        icon: Icons.point_of_sale_rounded,
                        accentColor: const Color(0xFF1D6B8B),
                        role: 'cashier',
                        index: 1,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffTypeCard extends StatefulWidget {
  final String title, role;
  final IconData icon;
  final Color accentColor;
  final int index;

  const _StaffTypeCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.role,
    required this.index,
  });

  @override
  State<_StaffTypeCard> createState() => _StaffTypeCardState();
}

class _StaffTypeCardState extends State<_StaffTypeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/admin/dashboard/staff/${widget.role}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          padding: const EdgeInsets.all(32),
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withValues(alpha: 0.6)
                  : AppColors.borderLight,
              width: _hovered ? 2 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    )
                  ]
                : AppShadows.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: _hovered ? 0.15 : 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: _hovered ? 0.6 : 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 40),
              ),
              const SizedBox(height: 24),
              Text(widget.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Manage',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (widget.index * 100).ms).slideY(begin: 0.08),
      ),
    );
  }
}
