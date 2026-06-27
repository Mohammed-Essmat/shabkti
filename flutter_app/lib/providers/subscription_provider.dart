import 'package:flutter/material.dart';
import 'package:shabakti/models/subscription.dart';
import 'package:shabakti/services/subscription_service.dart';

typedef UsageWarningCallback = void Function(double percentage);

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _service;

  Subscription? _active;
  UsageStats? _usage;
  List<Subscription> _history = [];
  bool _isLoading = false;
  String? _error;

  Subscription? get active => _active;
  UsageStats? get usage => _usage;
  List<Subscription> get history => _history;
  bool get isLoading => _isLoading;
  bool get hasActive => _active != null;
  String? get error => _error;
  bool _warningShown = false;
  UsageWarningCallback? onUsageWarning;

  SubscriptionProvider(this._service);

  Future<void> loadActive() async {
    _isLoading = true;
    notifyListeners();
    try {
      _active = await _service.getActiveSubscription();
      if (_active != null) {
        _usage = await _service.getUsage(_active!.id);
        if (_usage != null && _usage!.percentageUsed >= 95 && !_warningShown) {
          _warningShown = true;
          onUsageWarning?.call(_usage!.percentageUsed);
        }
      }
    } catch (_) {
      _active = null;
      _usage = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    try {
      _history = await _service.getHistory();
      notifyListeners();
    } catch (_) {}
  }

  Future<PaymentInfo?> createSubscription(String packageId, {bool replaceExisting = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final info = await _service.createSubscription(packageId, replaceExisting: replaceExisting);
      _isLoading = false;
      notifyListeners();
      return info;
    } catch (e) {
      _error = 'فشل في إنشاء الاشتراك';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> uploadPayment({
    required String subscriptionId,
    required String filePath,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.uploadPaymentProof(
        subscriptionId: subscriptionId,
        filePath: filePath,
        paymentMethod: paymentMethod,
      );
      await loadActive();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
