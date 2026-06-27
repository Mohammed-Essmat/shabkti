import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/core/theme.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/package_provider.dart';
import 'package:shabakti/providers/subscription_provider.dart';
import 'package:shabakti/providers/theme_provider.dart';
import 'package:shabakti/services/api_client.dart';
import 'package:shabakti/services/auth_service.dart';
import 'package:shabakti/services/beneficiary_service.dart';
import 'package:shabakti/services/package_service.dart';
import 'package:shabakti/services/storage_service.dart';
import 'package:shabakti/services/subscription_service.dart';
import 'package:shabakti/services/user_service.dart';
import 'package:shabakti/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShabaktiApp());
}

class ShabaktiApp extends StatelessWidget {
  const ShabaktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final apiClient = ApiClient(storage);
    final authService = AuthService(apiClient);
    final userService = UserService(apiClient);
    final packageService = PackageService(apiClient);
    final subscriptionService = SubscriptionService(apiClient);
    final beneficiaryService = BeneficiaryService(apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService, userService, storage)),
        ChangeNotifierProvider(create: (_) => PackageProvider(packageService)),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider(subscriptionService)),
        Provider.value(value: authService),
        Provider.value(value: userService),
        Provider.value(value: beneficiaryService),
        Provider.value(value: storage),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, langProvider, _) {
          return MaterialApp(
            title: 'Shabakti',
            debugShowCheckedModeBanner: false,
            locale: langProvider.locale,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            builder: (context, child) {
              return Directionality(
                textDirection: langProvider.textDirection,
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
