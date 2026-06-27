class InternetPackage {
  final String id;
  final String name;
  final String type;
  final double dataAmountGb;
  final double price;
  final int validityDays;
  final String description;
  final List<String> features;
  final bool isActive;

  InternetPackage({
    required this.id,
    required this.name,
    required this.type,
    required this.dataAmountGb,
    required this.price,
    required this.validityDays,
    required this.description,
    required this.features,
    required this.isActive,
  });

  factory InternetPackage.fromJson(Map<String, dynamic> json) {
    return InternetPackage(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      dataAmountGb: (json['data_amount_gb'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      validityDays: json['validity_days'],
      description: json['description'],
      features: List<String>.from(json['features']),
      isActive: json['is_active'],
    );
  }

  String typeLabelFor(bool isArabic) => switch (type) {
    'daily' => isArabic ? 'يومية' : 'Daily',
    'weekly' => isArabic ? 'أسبوعية' : 'Weekly',
    'monthly' => isArabic ? 'شهرية' : 'Monthly',
    'additional' => isArabic ? 'إضافية' : 'Add-on',
    _ => type,
  };

  String nameFor(bool isArabic) {
    if (isArabic) return name;
    final gb = dataAmountGb.toStringAsFixed(0);
    return '${typeLabelFor(false)} $gb GB';
  }

  String descriptionFor(bool isArabic) {
    if (isArabic) return description;
    final gb = dataAmountGb.toStringAsFixed(0);
    return switch (type) {
      'daily' => 'Daily package with $gb GB',
      'weekly' => 'Weekly package with $gb GB',
      'monthly' => 'Monthly package with $gb GB',
      'additional' => 'Extra $gb GB for your monthly plan',
      _ => description,
    };
  }

  List<String> featuresFor(bool isArabic) {
    if (isArabic) return features;
    final gb = dataAmountGb.toStringAsFixed(0);
    return switch (type) {
      'daily' => ['$gb GB', '24 hours', '30 Mbps speed'],
      'weekly' => ['$gb GB', '7 days', '30 Mbps speed'],
      'monthly' => ['$gb GB', '30 days', '30 Mbps speed', 'Add-on packages available'],
      'additional' => ['$gb GB extra', 'Added instantly', 'Monthly subscribers only'],
      _ => features,
    };
  }
}
