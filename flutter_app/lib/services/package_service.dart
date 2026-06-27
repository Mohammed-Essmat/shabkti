import 'package:shabakti/models/package.dart';
import 'package:shabakti/services/api_client.dart';

class PackageService {
  final ApiClient _api;

  PackageService(this._api);

  Future<List<InternetPackage>> getPackages() async {
    final response = await _api.get('/api/packages');
    return (response.data as List).map((p) => InternetPackage.fromJson(p)).toList();
  }

  Future<InternetPackage> getPackage(String packageId) async {
    final response = await _api.get('/api/packages/$packageId');
    return InternetPackage.fromJson(response.data);
  }
}
