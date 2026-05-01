import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/providers/auth_provider.dart';
import 'package:restaurant_admin/core/providers/restaurant_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().fetchRestaurant();
    });
  }

  final _dashboardOptions = [
    const _DashOption(
      title: 'Menu Management',
      description: 'Add, update, or remove menu items.',
      icon: Icons.restaurant_menu_rounded,
      route: '/admin/dashboard/menu',
    ),
    const _DashOption(
      title: 'Staff Management',
      description: 'Manage billing and serving staff credentials.',
      icon: Icons.people_outline_rounded,
      route: '/admin/dashboard/staff',
    ),
    const _DashOption(
      title: 'Table Details',
      description: 'Configure layout, view status, and QR codes.',
      icon: Icons.grid_view_rounded,
      route: '/admin/dashboard/tables',
    ),
    const _DashOption(
      title: 'Order Bill',
      description: 'View daily orders and billing history.',
      icon: Icons.receipt_long_rounded,
      route: '/admin/dashboard/orders',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final restaurantProv = context.watch<RestaurantProvider>();
    final restaurant = restaurantProv.restaurant;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: Column(
        children: [
          // ── Header Section ──────────────────────────────────────────────────
          _buildHeader(context, auth, restaurant),

          // ── Main Body Section ───────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Clean Elegant "Foggy" Background
                Positioned.fill(
                  child: Container(
                    color: AppColors.ivory,
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.05,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Dashboard Cards
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80 : 20,
                    vertical: 60,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: LayoutBuilder(builder: (ctx, constraints) {
                        final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.0, // Perfectly square cards
                          ),
                          itemCount: _dashboardOptions.length,
                          itemBuilder: (ctx, i) => _HoverableDashCard(
                            option: _dashboardOptions[i],
                            index: i,
                            onTap: () => context.go(_dashboardOptions[i].route),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                if (restaurantProv.isLoading)
                  const LinearProgressIndicator(color: AppColors.rubyRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth, dynamic restaurant) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.rubyDark,
        border: Border(bottom: BorderSide(color: AppColors.gold, width: 4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered Brand Info
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant?.name ?? 'Restaurant Admin',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (restaurant?.restaurantType ?? 'CAFE').toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(isActive: restaurant?.isActive ?? true),
                  ],
                ),
              ],
            ),
            
            // Right Side Profile & Logout (Stacked)
            Positioned(
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_pin_rounded, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          auth.userEmail ?? 'admin@restaurant.com',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) context.go('/admin/login');
                      },
                      icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                      label: Text('Logout', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverableDashCard extends StatefulWidget {
  final _DashOption option;
  final int index;
  final VoidCallback onTap;

  const _HoverableDashCard({
    required this.option,
    required this.index,
    required this.onTap,
  });

  @override
  State<_HoverableDashCard> createState() => _HoverableDashCardState();
}

class _HoverableDashCardState extends State<_HoverableDashCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? AppColors.gold : AppColors.rubyDark,
              width: 1.0, // Thin maroon outline
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.rubyDark.withOpacity(0.12), // Persistent maroon shadow
                blurRadius: _isHovered ? 30 : 20,
                offset: Offset(0, _isHovered ? 15 : 10),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isHovered 
                      ? AppColors.rubyRed 
                      : AppColors.rubyDark.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.option.icon, 
                  color: _isHovered ? Colors.white : AppColors.rubyDark, 
                  size: 32,
                ),
              ),

              const SizedBox(height: 24),
              Text(
                widget.option.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rubyDark,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.option.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(delay: (widget.index * 100).ms).slideY(begin: 0.1, curve: Curves.easeOutCirc),
      ),
    );
  }
}


class _DashOption {

  final String title, description, route;
  final IconData icon;
  const _DashOption({required this.title, required this.description, required this.icon, required this.route});
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'ACTIVE' : 'INACTIVE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.green.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
