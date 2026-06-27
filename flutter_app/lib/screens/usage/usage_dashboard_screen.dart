import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/subscription_provider.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/widgets/usage_chart.dart';
import 'package:shabakti/widgets/usage_history_chart.dart';
import 'package:shabakti/screens/history/subscription_history_screen.dart';

class UsageDashboardScreen extends StatefulWidget {
  const UsageDashboardScreen({super.key});

  @override
  State<UsageDashboardScreen> createState() => _UsageDashboardScreenState();
}

class _UsageDashboardScreenState extends State<UsageDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SubscriptionProvider>().loadActive());
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final s = context.watch<LanguageProvider>().strings;
    final colors = Theme.of(context).colorScheme;

    if (sub.isLoading) return const Center(child: CircularProgressIndicator());
    if (!sub.hasActive) return _buildEmptyState(context, s);

    final active = sub.active!;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.usageTitle),
      body: RefreshIndicator(
        onRefresh: () => sub.loadActive(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(child: UsageChart(totalGb: active.totalDataGb, usedGb: active.usedDataGb, remainingGb: active.remainingDataGb)),
              const SizedBox(height: 28),

              Row(children: [
                _statChip(context, s.total, '${active.totalDataGb.toStringAsFixed(0)} GB', Iconsax.cloud),
                const SizedBox(width: 8),
                _statChip(context, s.used, '${active.usedDataGb.toStringAsFixed(1)} GB', Iconsax.arrow_up_3),
                const SizedBox(width: 8),
                _statChip(context, s.remaining, '${active.remainingDataGb.toStringAsFixed(1)} GB', Iconsax.arrow_down),
              ]),
              const SizedBox(height: 22),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: active.usagePercentage / 100, backgroundColor: colors.outlineVariant.withValues(alpha: 0.3), color: colors.primary, minHeight: 8),
              ),
              const SizedBox(height: 6),
              Align(alignment: Alignment.centerLeft, child: Text('${active.usagePercentage.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.labelMedium)),
              const SizedBox(height: 22),

              if (active.daysRemaining != null)
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: colors.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Iconsax.timer_1, color: colors.primary, size: 22)),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.daysLeft(active.daysRemaining!), style: Theme.of(context).textTheme.titleMedium),
                      if (active.endDate != null)
                        Text('${s.isArabic ? 'تنتهي' : 'Expires'} ${active.endDate!.day}/${active.endDate!.month}/${active.endDate!.year}',
                            style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                  ]),
                ),

              const SizedBox(height: 28),
              UsageHistoryChart(
                totalGb: active.totalDataGb, usedGb: active.usedDataGb,
                totalDays: active.endDate != null && active.startDate != null
                    ? active.endDate!.difference(active.startDate!).inDays.clamp(1, 365) : 1,
                daysElapsed: active.startDate != null ? DateTime.now().difference(active.startDate!).inDays.clamp(1, 365) : 1,
              ),

              const SizedBox(height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(s.subscriptionHistory, style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionHistoryScreen())),
                  icon: const Icon(Iconsax.arrow_left_2, size: 16), label: Text(s.viewAll),
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, String value, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: colors.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ]),
    ));
  }

  Widget _buildEmptyState(BuildContext context, dynamic s) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.usageTitle),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.06), shape: BoxShape.circle),
            child: Icon(Iconsax.wifi_square, size: 56, color: colors.outline)),
          const SizedBox(height: 24),
          Text(s.noActiveSub, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(s.isArabic ? 'اختر باقة من الباقات المتاحة\nوابدأ الاستمتاع بالإنترنت' : 'Choose a plan and\nstart enjoying the internet',
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      )),
    );
  }
}
