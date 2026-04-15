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

  final _menuItems = [
    const _DashCard(
      title: 'Menu Management',
      description: 'Add, update, or remove menu items.',
      icon: Icons.restaurant_menu_rounded,
      route: '/admin/dashboard/menu',
    ),
    const _DashCard(
      title: 'Staff Management',
      description: 'Manage billing and serving staff credentials.',
      icon: Icons.people_rounded,
      route: '/admin/dashboard/staff',
    ),
    const _DashCard(
      title: 'Table Details',
      description: 'Configure layout, view status, and QR codes.',
      icon: Icons.grid_view_rounded,
      route: '/admin/dashboard/tables',
    ),
    const _DashCard(
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
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          _buildHeader(context, auth, restaurant, isWide),

          // ── Loading indicator ──────────────────────────────────────────────
          if (restaurantProv.isLoading)
            const LinearProgressIndicator(
              backgroundColor: AppColors.ivoryDark,
              color: AppColors.rubyRed,
            ),

          // ── API Error Banner ───────────────────────────────────────────────
          if (restaurantProv.error != null)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      restaurantProv.error!
                          .replaceAll('Exception: ', ''),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFDC2626)),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<RestaurantProvider>().fetchRestaurant(),
                    child: const Text('Retry',
                        style: TextStyle(color: Color(0xFFDC2626))),
                  ),
                ],
              ),
            ),

          // ── Inactive restaurant warning ────────────────────────────────────
          if (restaurant != null && !restaurant.isActive)
            _buildWarningBanner(restaurant.name),

          // ── Dashboard Cards ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 40 : 20),
              child: LayoutBuilder(builder: (ctx, constraints) {
                final cols = constraints.maxWidth > 700
                    ? 4
                    : constraints.maxWidth > 480
                        ? 2
                        : 1;
                const spacing = 20.0;
                final cardW =
                    (constraints.maxWidth - (cols - 1) * spacing) / cols;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _menuItems.asMap().entries.map((e) {
                    return SizedBox(
                      width: cardW,
                      child: _buildCard(context, e.value, e.key),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth,
      dynamic restaurant, bool isWide) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.rubyRed,
        boxShadow: AppShadows.elevated,
        border: const Border(
          bottom: BorderSide(color: AppColors.gold, width: 4),
        ),
      ),
      padding: EdgeInsets.fromLTRB(isWide ? 48 : 20, 48, isWide ? 48 : 20, 32),
      child: Stack(
        children: [
          // centered title
          Center(
            child: Column(
              children: [
                Text(
                  restaurant?.name ?? 'Admin Dashboard',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isWide ? 44 : 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      restaurant?.restaurantType ??
                          'Oversee your fine dining operations',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.gold.withValues(alpha: 0.9),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (restaurant != null) ...[
                      const SizedBox(width: 10),
                      _StatusBadge(isActive: restaurant.isActive),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // logout button — top right
          Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      auth.userEmail ?? 'Admin',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(children: [
                    Icon(Icons.business_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Restaurant Profile'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    Icon(Icons.logout, size: 18, color: AppColors.danger),
                    SizedBox(width: 10),
                    Text('Logout',
                        style: TextStyle(color: AppColors.danger)),
                  ]),
                ),
              ],
              onSelected: (val) async {
                if (val == 'logout') {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/admin/login');
                } else if (val == 'profile') {
                  context.go('/admin/dashboard/profile');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(String name) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: Color(0xFFD97706), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your restaurant "$name" is currently inactive. Please contact support.',
            style:
                GoogleFonts.inter(fontSize: 13, color: const Color(0xFF92400E)),
          ),
        ),
      ]),
    );
  }

  Widget _buildCard(BuildContext context, _DashCard item, int index) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.card,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.ivory,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.rubyRed, size: 36),
              ),
              const SizedBox(height: 18),
              Text(item.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(item.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1),
      ),
    );
  }
}

class _DashCard {
  final String title, description, route;
  final IconData icon;
  const _DashCard(
      {required this.title,
      required this.description,
      required this.icon,
      required this.route});
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.success : AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(isActive ? 'ACTIVE' : 'INACTIVE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isActive ? AppColors.success : AppColors.warning,
            )),
      ]),
    );
  }
}


