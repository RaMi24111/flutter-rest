import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Backend Base URL ───────────────────────────────────────────────────────
const String kBackendBase = 'https://pos-backend-s380.onrender.com';

// ─── API Endpoints ───────────────────────────────────────────────────────────
class ApiEndpoints {
  static const String login = '/api/admin/login';
  static const String me = '/api/admin/me';
  static const String restaurant = '/api/admin/restaurant';
  static const String profile = '/api/admin/profile';

  static const String menuCategories = '/api/admin/menu/categories';
  static String menuCategoryById(String id) => '/api/admin/categories/$id';
  static const String menuItems = '/api/admin/menu/items';
  static String menuItemById(String id) => '/api/admin/menu/items/$id';
  static String toggleMenuItem(String id) => '/api/admin/menu/items/$id/toggle';

  static const String staffList = '/api/admin/staff';
  static String staffById(String id) => '/api/admin/staff/$id';
  static String toggleStaff(String id) => '/api/admin/staff/$id/toggle';

  static const String ordersList = '/api/admin/orders';
  static String orderById(String id) => '/api/admin/orders/$id';

  static const String tablesList = '/api/admin/tables';
  static String toggleTable(String id) => '/api/admin/tables/$id/toggle';
  static String deleteTable(String id) => '/api/admin/tables/$id';
}

// ─── Token / Storage Keys ────────────────────────────────────────────────────
const String kTokenKey = 'admin_auth_token';
const String kUserKey = 'admin_user_data';

// ─── Colors ──────────────────────────────────────────────────────────────────
class AppColors {
  static const Color rubyRed = Color(0xFF8B1D1D);
  static const Color rubyDark = Color(0xFF6B1515);
  static const Color rubyLight = Color(0xFF9B2B2B);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4C430);
  static const Color ivory = Color(0xFFFAF9F6);
  static const Color ivoryDark = Color(0xFFF5F3ED);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

// ─── Text Styles ─────────────────────────────────────────────────────────────
class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.rubyRed,
  );

  static TextStyle get heading2 => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle get heading3 => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 14, color: AppColors.textDark);

  static TextStyle get bodyMuted =>
      GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted);

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glow = [
    BoxShadow(
      color: AppColors.rubyRed.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

