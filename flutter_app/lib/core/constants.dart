class AppConstants {
  static const String appName = 'Shabakti';
  static const String appNameAr = 'شبكتي';
  static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String apiBaseUrlDevice = 'http://192.168.1.5:8000'; // physical device
  static const String apiBaseUrlProd = 'https://shabkti-api-553721465865.me-central1.run.app'; // production

  static String get baseUrl {
    return apiBaseUrlProd;
  }

  static const String vodafoneCashNumber = '01234567890';
  static const String instapayAddress = 'internet.packages@instapay';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
