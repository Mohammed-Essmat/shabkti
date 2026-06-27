import 'package:shabakti/services/api_client.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
  }) async {
    final response = await _api.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    final response = await _api.post('/api/auth/verify-otp', data: {
      'identifier': identifier,
      'code': code,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> setPassword({
    required String identifier,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _api.post('/api/auth/set-password', data: {
      'identifier': identifier,
      'password': password,
      'confirm_password': confirmPassword,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await _api.post('/api/auth/forgot-password', data: {'email': email});
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String identifier,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _api.post('/api/auth/reset-password', data: {
      'identifier': identifier,
      'password': password,
      'confirm_password': confirmPassword,
    });
    return response.data;
  }
}
