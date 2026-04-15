import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_admin/core/constants.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get userEmail => _user?['email'] as String?;
  String? get userName => _user?['name'] as String?;

  /// Load token from storage on app start
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(kTokenKey);
    final userEmail = prefs.getString(kUserKey);
    if (userEmail != null && userEmail.isNotEmpty) {
      _user = {'email': userEmail};
    }
    notifyListeners();
  }

  /// Store token and user after successful login
  Future<void> setAuth(String token, Map<String, dynamic> user) async {
    _token = token;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTokenKey, token);
    await prefs.setString(kUserKey, user['email']?.toString() ?? '');
    notifyListeners();
  }

  /// Clear auth on logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
    await prefs.remove(kUserKey);
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
