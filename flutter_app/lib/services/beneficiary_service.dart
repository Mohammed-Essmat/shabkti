import 'package:shabakti/models/user.dart';
import 'package:shabakti/services/api_client.dart';

class BeneficiaryService {
  final ApiClient _api;

  BeneficiaryService(this._api);

  Future<User> addBeneficiary({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _api.post('/api/beneficiaries', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
    return User.fromJson(response.data);
  }

  Future<List<User>> getBeneficiaries() async {
    final response = await _api.get('/api/beneficiaries');
    return (response.data as List).map((b) => User.fromJson(b)).toList();
  }

  Future<User> updateBeneficiary(String id, {required String name}) async {
    final response = await _api.put('/api/beneficiaries/$id', data: {'name': name});
    return User.fromJson(response.data);
  }

  Future<void> deleteBeneficiary(String id) async {
    await _api.delete('/api/beneficiaries/$id');
  }
}
