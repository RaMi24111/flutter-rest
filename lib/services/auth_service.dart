import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_admin/services/api_service.dart';
import 'package:restaurant_admin/core/constants.dart';

class AuthService {
  /// Login — POST /api/admin/login
  /// The deployed backend returns: { success, message, data: { token, user } }
  /// ApiService._handleResponse already unwraps the envelope so [response]
  /// arrives here as { token, user }.
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await ApiService.post(
      ApiEndpoints.login,
      {'email': email, 'password': password},
      requiresAuth: false,
    );

    // response is already the unwrapped `data` object: { token, user }
    final data = response as Map<String, dynamic>;

    // token may be at top-level (new backend) or nested under 'data' (fallback)
    final token = (data['token'] ??
            (data['data'] is Map ? (data['data'] as Map)['token'] : null))
        as String?;

    if (token == null || token.isEmpty) {
      throw Exception('No token received from server');
    }

    // Persist token for subsequent requests
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTokenKey, token);

    // Build user object
    final user = (data['user'] ??
            (data['data'] is Map ? (data['data'] as Map)['user'] : null))
        as Map<String, dynamic>? ??
        {'email': email};
    await prefs.setString(kUserKey, email);

    return {'token': token, 'user': user};
  }

  /// Logout — clear stored credentials
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
    await prefs.remove(kUserKey);
  }

  /// Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kTokenKey);
  }

  /// Validate session with backend (GET /api/admin/me)
  static Future<Map<String, dynamic>?> validateSession() async {
    try {
      final data = await ApiService.get(ApiEndpoints.me, requiresAuth: true);
      return data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
