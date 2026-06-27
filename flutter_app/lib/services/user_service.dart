import 'package:shabakti/models/user.dart';
import 'package:shabakti/services/api_client.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  Future<User> getProfile() async {
    final response = await _api.get('/api/users/me');
    return User.fromJson(response.data);
  }

  Future<User> updateProfile({String? name}) async {
    final response = await _api.put('/api/users/me', data: {'name': name});
    return User.fromJson(response.data);
  }

  Future<User> uploadProfilePicture(String filePath) async {
    final response = await _api.uploadFile('/api/users/upload-picture', filePath);
    return User.fromJson(response.data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.put('/api/users/password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });
  }

  Future<void> deleteAccount() async {
    await _api.delete('/api/users/me');
  }
}
