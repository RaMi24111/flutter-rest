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
      backgroundColor: AppColors.rubyDark, // Solid background as requested
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Header (Back Button) ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.go('/admin/dashboard'),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // ── Title Section ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          'Staff Management',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1),
                        const SizedBox(height: 8),
                        Text(
                          'Select a role to manage credentials and access.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppColors.gold.withOpacity(0.9),
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ── Cards Section ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Wrap(
                      spacing: 40,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children: [
                        _StaffTypeCard(
                          title: 'Billing Staff',
                          description: 'Manage cashier terminals and transaction logs.',
                          icon: Icons.receipt_long_rounded,
                          role: 'cashier',
                          index: 0,
                        ),
                        _StaffTypeCard(
                          title: 'Serving Staff',
                          description: 'Manage floor staff and service assignments.',
                          icon: Icons.restaurant_rounded,
                          role: 'server',
                          index: 1,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffTypeCard extends StatefulWidget {
  final String title, description, role;
  final IconData icon;
  final int index;

  const _StaffTypeCard({
    required this.title,
    required this.description,
    required this.role,
    required this.icon,
    required this.index,
  });

  @override
  State<_StaffTypeCard> createState() => _StaffTypeCardState();
}

class _StaffTypeCardState extends State<_StaffTypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/admin/dashboard/staff/${widget.role}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isHovered ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(_isHovered ? 0.2 : 0.08),
              width: 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon Container ──────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.rubyDark,
                  size: 40,
                ),
              ),
              const SizedBox(height: 32),
              // ── Title ───────────────────────────────────────────
              Text(
                widget.title,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // ── Description ─────────────────────────────────────
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (widget.index * 200).ms).scale(
              begin: const Offset(0.95, 0.95),
              curve: Curves.easeOutCirc,
            ),
      ),
    );
  }
}
