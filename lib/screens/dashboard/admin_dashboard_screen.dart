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
                // Background Image with Overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
                      fit: BoxFit.cover,
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
                            childAspectRatio: 0.95,
                          ),
                          itemCount: _dashboardOptions.length,
                          itemBuilder: (ctx, i) => _buildOptionCard(context, _dashboardOptions[i], i),
                        );
                      }),
                    ),
                  ),
                ),

                // Loading / Error Banners
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
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            // Centered Brand Info
            Column(
              children: [
                Text(
                  restaurant?.name ?? 'Restaurant Admin',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
            const Spacer(),
            // Right Side Profile & Logout
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        auth.userEmail ?? 'admin@restaurant.com',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) context.go('/admin/login');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                  label: Text('Logout', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildOptionCard(BuildContext context, _DashOption option, int index) {
    return GestureDetector(
      onTap: () => context.go(option.route),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(option.icon, color: AppColors.rubyDark, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              option.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.rubyDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              option.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, curve: Curves.easeOutCirc),
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
