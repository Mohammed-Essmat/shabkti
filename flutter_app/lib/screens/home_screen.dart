import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/subscription_provider.dart';
import 'package:shabakti/screens/home/dashboard_screen.dart';
import 'package:shabakti/screens/usage/usage_dashboard_screen.dart';
import 'package:shabakti/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sub = context.read<SubscriptionProvider>();
      sub.onUsageWarning = (percentage) {
        if (!mounted) return;
        final s = context.read<LanguageProvider>().strings;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Iconsax.warning_2, color: Color(0xFFF59E0B), size: 40),
            title: Text(s.isArabic ? 'الباقة قربت تخلص!' : 'Data almost used up!'),
            content: Text(s.isArabic
                ? 'تم استهلاك ${percentage.toStringAsFixed(0)}% من باقتك.\nاشترك في باقة جديدة أو أضف باقة إضافية.'
                : '${percentage.toStringAsFixed(0)}% of your data has been used.\nSubscribe to a new plan or add extra data.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.isArabic ? 'حسناً' : 'OK'))],
          ),
        );
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().strings;
    final screens = [
      DashboardScreen(onProfileTap: () => switchToTab(2)),
      const UsageDashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(icon: const Icon(Iconsax.home_2), activeIcon: const Icon(Iconsax.home_1), label: s.navHome),
            BottomNavigationBarItem(icon: const Icon(Iconsax.chart), activeIcon: const Icon(Iconsax.chart_1), label: s.navUsage),
            BottomNavigationBarItem(icon: const Icon(Iconsax.profile_circle), activeIcon: const Icon(Iconsax.profile_circle), label: s.navProfile),
          ],
        ),
      ),
    );
  }
}
