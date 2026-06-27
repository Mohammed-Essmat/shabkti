import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/models/package.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/subscription_provider.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/payment/payment_screen.dart';

class PackageDetailsScreen extends StatelessWidget {
  final InternetPackage package;
  const PackageDetailsScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sub = context.watch<SubscriptionProvider>();

    final s = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.packageDetails, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _accentColor(colors).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 44, color: _accentColor(colors)),
            ),
            const SizedBox(height: 16),
            Text(package.nameFor(s.isArabic), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _accentColor(colors).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(package.typeLabelFor(s.isArabic), style: TextStyle(color: _accentColor(colors), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            const SizedBox(height: 28),
            Text(
              '${package.price.toStringAsFixed(0)} ${s.egp}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: colors.primary, fontSize: 40),
            ),
            const SizedBox(height: 32),

            _infoRow(context, Iconsax.cloud, s.isArabic ? 'حجم البيانات' : 'Data', '${package.dataAmountGb.toStringAsFixed(0)} GB'),
            _infoRow(context, Iconsax.timer_1, s.isArabic ? 'مدة الصلاحية' : 'Validity', package.validityDays > 0 ? '${package.validityDays} ${s.isArabic ? 'يوم' : 'days'}' : (s.isArabic ? 'فورية' : 'Instant')),
            _infoRow(context, Iconsax.flash_1, s.isArabic ? 'السرعة' : 'Speed', '30 Mbps'),

            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Text(s.isArabic ? 'المميزات' : 'Features', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 14),
            ...package.featuresFor(s.isArabic).map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.tick_circle, color: Color(0xFF22C55E), size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(f, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: sub.isLoading ? null : () async {
              bool replaceExisting = false;

              if (sub.hasActive && package.type != 'additional') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    icon: Icon(Iconsax.warning_2, color: Theme.of(context).colorScheme.error, size: 36),
                    title: Text(s.isArabic ? 'باقة نشطة موجودة' : 'Active plan exists'),
                    content: Text(s.isArabic ? 'عندك باقة شغالة حالياً.\nلو اشتركت في باقة جديدة، الباقة القديمة هتتلغي.\n\nمتأكد تريد المتابعة؟'
                        : 'You have an active plan.\nSubscribing to a new one will cancel it.\n\nContinue?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.isArabic ? 'إلغاء' : 'Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(s.isArabic ? 'متابعة وإلغاء القديمة' : 'Continue & cancel old'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                replaceExisting = true;
              }

              final paymentInfo = await sub.createSubscription(package.id, replaceExisting: replaceExisting);
              if (paymentInfo != null && context.mounted) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PaymentScreen(paymentInfo: paymentInfo, package: package),
                ));
              }
            },
            child: sub.isLoading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('${s.subscribeNow} — ${package.price.toStringAsFixed(0)} ${s.egp}'),
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (package.type) {
    'daily' => Iconsax.sun_1,
    'weekly' => Iconsax.calendar,
    'monthly' => Iconsax.calendar_1,
    'additional' => Iconsax.add_circle,
    _ => Iconsax.wifi,
  };

  Color _accentColor(ColorScheme colors) => switch (package.type) {
    'daily' => const Color(0xFFF59E0B),
    'weekly' => colors.primary,
    'monthly' => const Color(0xFF8B5CF6),
    'additional' => const Color(0xFF22C55E),
    _ => colors.primary,
  };

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
