import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shabakti/models/user.dart';
import 'package:shabakti/services/auth_service.dart';
import 'package:shabakti/services/user_service.dart';
import 'package:shabakti/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final StorageService _storage;

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Registration flow temp data
  String? _regEmail;
  // ignore: unused_field
  String? _regName;
  // ignore: unused_field
  String? _regPhone;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String? get regEmail => _regEmail;

  AuthProvider(this._authService, this._userService, this._storage);

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
  void clearError() => _setError(null);

  Future<bool> checkAuth() async {
    if (!await _storage.hasToken()) return false;
    try {
      _user = await _userService.getProfile();
      notifyListeners();
      return true;
    } catch (_) {
      await _storage.clearTokens();
      return false;
    }
  }

  Future<bool> register({required String name, required String email, required String phone}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.register(name: name, email: email, phone: phone);
      _regEmail = email;
      _regName = name;
      _regPhone = phone;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp({required String code}) async {
    if (_regEmail == null) { _setError('Registration data missing'); return false; }
    _setLoading(true);
    _setError(null);
    try {
      await _authService.verifyOtp(identifier: _regEmail!, code: code);
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> setPassword({required String password, required String confirmPassword}) async {
    if (_regEmail == null) { _setError('Registration data missing'); return false; }
    _setLoading(true);
    _setError(null);
    try {
      await _authService.setPassword(
        identifier: _regEmail!,
        password: password,
        confirmPassword: confirmPassword,
      );
      _regEmail = null;
      _regName = null;
      _regPhone = null;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      final data = await _authService.login(email: email, password: password);
      await _storage.saveTokens(data['access_token'], data['refresh_token']);
      _user = await _userService.getProfile();
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _setError(_extractError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearTokens();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      _user = await _userService.getProfile();
      notifyListeners();
    } catch (_) {}
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) return data['detail'];
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
