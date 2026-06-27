import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/core/app_strings.dart';
import 'package:shabakti/models/package.dart';
import 'package:shabakti/screens/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final InternetPackage package;
  const PaymentSuccessScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.read<AppStrings>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [colors.primary, colors.primaryContainer]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Iconsax.send_1, color: Colors.white, size: 44),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  s.isArabic ? 'تم إرسال طلبك بنجاح!' : 'Request submitted successfully!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  s.isArabic
                      ? 'سيتم مراجعة الدفع وتفعيل باقتك قريباً.\nستصلك بيانات الاتصال على الإيميل.'
                      : 'Your payment is under review.\nYou will receive connection details via email.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _row(context, Iconsax.box_1, s.isArabic ? 'الباقة' : 'Package', package.name),
                      Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 20),
                      _row(context, Iconsax.cloud, s.isArabic ? 'البيانات' : 'Data', '${package.dataAmountGb.toStringAsFixed(0)} GB'),
                      if (package.validityDays > 0) ...[
                        Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 20),
                        _row(context, Iconsax.timer_1, s.isArabic ? 'المدة' : 'Duration', '${package.validityDays} ${s.isArabic ? 'يوم' : 'days'}'),
                      ],
                      Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Iconsax.timer_start, size: 18, color: colors.outline),
                            const SizedBox(width: 8),
                            Text(s.isArabic ? 'الحالة' : 'Status', style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.clock, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text(
                                  s.isArabic ? 'قيد المراجعة' : 'Under review',
                                  style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                  icon: const Icon(Iconsax.home_2, size: 20),
                  label: Text(s.goHome),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ]),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
