import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/subscription_provider.dart';
import 'package:shabakti/models/subscription.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});
  @override
  State<SubscriptionHistoryScreen> createState() => _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SubscriptionProvider>().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final s = context.watch<LanguageProvider>().strings;
    final filtered = _filter == 'all' ? sub.history : sub.history.where((x) => x.status == _filter).toList();

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.subscriptionHistory, showBack: true),
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _chip(s.isArabic ? 'الكل' : 'All', 'all'),
            const SizedBox(width: 8),
            _chip(s.isArabic ? 'نشطة' : 'Active', 'active'),
            const SizedBox(width: 8),
            _chip(s.isArabic ? 'منتهية' : 'Expired', 'expired'),
            const SizedBox(width: 8),
            _chip(s.isArabic ? 'ملغاة' : 'Cancelled', 'cancelled'),
          ]),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(s.isArabic ? 'لا توجد اشتراكات' : 'No subscriptions', style: Theme.of(context).textTheme.bodyLarge))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _card(context, filtered[i], s),
                ),
        ),
      ]),
    );
  }

  Widget _chip(String label, String value) {
    final isSelected = _filter == value;
    final colors = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label), selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: colors.primary,
      labelStyle: TextStyle(color: isSelected ? colors.onPrimary : colors.onSurface),
      checkmarkColor: colors.onPrimary,
    );
  }

  Widget _card(BuildContext context, Subscription sub, dynamic s) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = switch (sub.status) { 'active' => const Color(0xFF22C55E), 'expired' => colors.outline, 'cancelled' => colors.error, _ => colors.outline };
    final statusLabel = switch (sub.status) {
      'active' => s.isArabic ? 'نشط' : 'Active',
      'pending' => s.isArabic ? 'قيد الانتظار' : 'Pending',
      'expired' => s.isArabic ? 'منتهي' : 'Expired',
      'cancelled' => s.isArabic ? 'ملغي' : 'Cancelled',
      _ => sub.status,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(sub.packageName ?? '', style: Theme.of(context).textTheme.titleMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ]),
        if (sub.startDate != null && sub.endDate != null) ...[
          const SizedBox(height: 8),
          Text('${sub.startDate!.day}/${sub.startDate!.month}/${sub.startDate!.year} → ${sub.endDate!.day}/${sub.endDate!.month}/${sub.endDate!.year}',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
          value: sub.usagePercentage / 100, backgroundColor: colors.outlineVariant, color: colors.primary, minHeight: 6)),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: Text('${sub.usagePercentage.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.labelSmall)),
      ])),
    );
  }
}
