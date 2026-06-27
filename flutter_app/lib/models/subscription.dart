class Subscription {
  final String id;
  final String userId;
  final String packageId;
  final String? packageName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalDataGb;
  final double usedDataGb;
  final double remainingDataGb;
  final String status;
  final String? hotspotUsername;
  final String? hotspotPassword;
  final List<String> beneficiaryIds;
  final DateTime createdAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.packageId,
    this.packageName,
    this.startDate,
    this.endDate,
    required this.totalDataGb,
    required this.usedDataGb,
    required this.remainingDataGb,
    required this.status,
    this.hotspotUsername,
    this.hotspotPassword,
    required this.beneficiaryIds,
    required this.createdAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      packageId: json['package_id'],
      packageName: json['package_name'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      totalDataGb: (json['total_data_gb'] as num).toDouble(),
      usedDataGb: (json['used_data_gb'] as num).toDouble(),
      remainingDataGb: (json['remaining_data_gb'] as num).toDouble(),
      status: json['status'],
      hotspotUsername: json['hotspot_username'],
      hotspotPassword: json['hotspot_password'],
      beneficiaryIds: List<String>.from(json['beneficiary_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';

  int? get daysRemaining {
    if (endDate == null) return null;
    final diff = endDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get usagePercentage =>
      totalDataGb > 0 ? (usedDataGb / totalDataGb * 100) : 0;

  String get statusLabel => switch (status) {
    'active' => 'نشط',
    'pending' => 'قيد الانتظار',
    'expired' => 'منتهي',
    'cancelled' => 'ملغي',
    _ => status,
  };
}

class UsageStats {
  final double totalGb;
  final double usedGb;
  final double remainingGb;
  final double percentageUsed;
  final int? daysRemaining;
  final String status;

  UsageStats({
    required this.totalGb,
    required this.usedGb,
    required this.remainingGb,
    required this.percentageUsed,
    this.daysRemaining,
    required this.status,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      totalGb: (json['total_gb'] as num).toDouble(),
      usedGb: (json['used_gb'] as num).toDouble(),
      remainingGb: (json['remaining_gb'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      daysRemaining: json['days_remaining'],
      status: json['status'],
    );
  }
}

class PaymentInfo {
  final String paymentId;
  final String subscriptionId;
  final double amount;
  final String status;
  final String vodafoneCashNumber;
  final String instapayAddress;

  PaymentInfo({
    required this.paymentId,
    required this.subscriptionId,
    required this.amount,
    required this.status,
    required this.vodafoneCashNumber,
    required this.instapayAddress,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentId: json['payment_id'],
      subscriptionId: json['subscription_id'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      vodafoneCashNumber: json['vodafone_cash_number'] ?? '01234567890',
      instapayAddress: json['instapay_address'] ?? 'internet.packages@instapay',
    );
  }
}
