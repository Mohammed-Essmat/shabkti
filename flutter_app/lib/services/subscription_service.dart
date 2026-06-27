import 'package:shabakti/models/subscription.dart';
import 'package:shabakti/services/api_client.dart';

class SubscriptionService {
  final ApiClient _api;

  SubscriptionService(this._api);

  Future<PaymentInfo> createSubscription(String packageId, {bool replaceExisting = false}) async {
    final response = await _api.post('/api/subscriptions', data: {
      'package_id': packageId,
      'replace_existing': replaceExisting,
    });
    return PaymentInfo.fromJson(response.data);
  }

  Future<Subscription> getActiveSubscription() async {
    final response = await _api.get('/api/subscriptions/active');
    return Subscription.fromJson(response.data);
  }

  Future<List<Subscription>> getHistory() async {
    final response = await _api.get('/api/subscriptions/history');
    return (response.data as List).map((s) => Subscription.fromJson(s)).toList();
  }

  Future<UsageStats> getUsage(String subscriptionId) async {
    final response = await _api.get('/api/subscriptions/$subscriptionId/usage');
    return UsageStats.fromJson(response.data);
  }

  Future<Map<String, dynamic>> uploadPaymentProof({
    required String subscriptionId,
    required String filePath,
    required String paymentMethod,
  }) async {
    final response = await _api.uploadFile(
      '/api/subscriptions/$subscriptionId/upload-payment?payment_method=$paymentMethod',
      filePath,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> addData({
    required String subscriptionId,
    required String packageId,
  }) async {
    final response = await _api.post(
      '/api/subscriptions/$subscriptionId/add-data',
      data: {'package_id': packageId},
    );
    return response.data;
  }
}
