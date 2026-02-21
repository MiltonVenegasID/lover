import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _checkLoginStatus();
  }

  final AuthService _authService = AuthService();

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isLoggedIn') ?? false;
  }

  Future<bool> login(String username, String password) async {
    if (_authService.validateCredentials(username, password)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      state = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
