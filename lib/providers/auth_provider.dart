import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.system;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;
  int get currentUserId => _user?.id ?? 0;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _loadThemeMode();
    _tryAutoLogin();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode');
    if (isDark == null) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dark_mode');
    notifyListeners();
  }

  Future<void> _tryAutoLogin() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      try {
        _user = await _api.getMe();
        notifyListeners();
      } catch (_) {
        await TokenManager.clearToken();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final auth = await _api.login(email, password);
      await TokenManager.setToken(auth.token);
      _user = auth.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String email, String password, String? nickname, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final auth = await _api.register(email, password, nickname, code);
      await TokenManager.setToken(auth.token);
      _user = auth.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _api.getMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await TokenManager.clearToken();
    _user = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('error')) {
        try {
          return msg;
        } catch (_) {
          return msg;
        }
      }
      return msg;
    }
    return '操作失败，请重试';
  }
}
