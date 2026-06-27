import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/package_provider.dart';
import 'package:shabakti/providers/subscription_provider.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/home/package_details_screen.dart';
import 'package:shabakti/models/package.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const DashboardScreen({super.key, this.onProfileTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'daily';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PackageProvider>().loadPackages();
      context.read<SubscriptionProvider>().loadActive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = context.watch<LanguageProvider>().strings;
    final pkgProvider = context.watch<PackageProvider>();
    final subProvider = context.watch<SubscriptionProvider>();
    final colors = Theme.of(context).colorScheme;

    final filteredPackages = pkgProvider.packages.where((p) => p.type == _selectedCategory).toList();

    final categories = [
      {'type': 'daily', 'label': s.daily, 'icon': Iconsax.sun_1},
      {'type': 'weekly', 'label': s.weekly, 'icon': Iconsax.calendar},
      {'type': 'monthly', 'label': s.monthly, 'icon': Iconsax.calendar_1},
      {'type': 'additional', 'label': s.additional, 'icon': Iconsax.add_circle},
    ];

    return Scaffold(
      appBar: ShabaktiAppBar(actions: [
        GestureDetector(
          onTap: widget.onProfileTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colors.primaryContainer,
              backgroundImage: auth.user?.profilePictureUrl != null ? NetworkImage(auth.user!.profilePictureUrl!) : null,
              child: auth.user?.profilePictureUrl == null ? Icon(Iconsax.user, size: 16, color: colors.onPrimary) : null,
            ),
          ),
        ),
      ]),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([pkgProvider.loadPackages(), subProvider.loadActive()]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(s.greeting(auth.user?.name ?? ''), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),

              if (subProvider.hasActive)
                _buildActiveCard(context, subProvider, s)
              else
                _buildNoSubBanner(context, s),

              const SizedBox(height: 28),
              Text(s.choosePlan, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat['type'];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        avatar: Icon(cat['icon'] as IconData, size: 16, color: isSelected ? colors.onPrimary : colors.primary),
                        label: Text(cat['label'] as String),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat['type'] as String),
                        selectedColor: colors.primary,
                        labelStyle: TextStyle(color: isSelected ? colors.onPrimary : colors.onSurface, fontWeight: FontWeight.w600),
                        checkmarkColor: colors.onPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              if (pkgProvider.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else
                ...filteredPackages.map((pkg) => _packageListItem(context, pkg, s)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _packageListItem(BuildContext context, InternetPackage pkg, dynamic s) {
    final colors = Theme.of(context).colorScheme;
    final accent = _accentColor(pkg.type, colors);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PackageDetailsScreen(package: pkg))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Iconsax.wifi, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pkg.nameFor(s.isArabic), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('${pkg.dataAmountGb.toStringAsFixed(0)} GB  •  ${pkg.validityDays > 0 ? '${pkg.validityDays} ${s.isArabic ? 'يوم' : 'days'}' : s.isArabic ? 'فورية' : 'Instant'}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(pkg.price.toStringAsFixed(0), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: accent)),
                  Text(s.egp, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Iconsax.arrow_left_2, size: 16, color: colors.outline),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentColor(String type, ColorScheme colors) => switch (type) {
    'daily' => const Color(0xFFF59E0B),
    'weekly' => colors.primary,
    'monthly' => const Color(0xFF8B5CF6),
    'additional' => const Color(0xFF22C55E),
    _ => colors.primary,
  };

  Widget _buildNoSubBanner(BuildContext context, dynamic s) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary.withValues(alpha: 0.08), colors.primary.withValues(alpha: 0.03)]),
        borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(Iconsax.wifi, color: colors.primary, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.noActiveSub, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(s.isArabic ? 'اختر باقة من الباقات أدناه' : 'Choose a plan below', style: Theme.of(context).textTheme.bodyMedium),
        ])),
      ]),
    );
  }

  Widget _buildActiveCard(BuildContext context, SubscriptionProvider sub, dynamic s) {
    final active = sub.active!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.primaryContainer], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(active.packageName ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Iconsax.tick_circle, size: 14, color: Colors.white), const SizedBox(width: 4),
              Text(s.active, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        Text(active.remainingDataGb.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700)),
        Text(s.gbRemaining, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
          value: active.usagePercentage / 100, backgroundColor: Colors.white.withValues(alpha: 0.2), color: Colors.white, minHeight: 6)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${active.usedDataGb.toStringAsFixed(1)} ${s.isArabic ? 'من' : 'of'} ${active.totalDataGb.toStringAsFixed(0)} GB',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (active.daysRemaining != null)
            Row(children: [
              const Icon(Iconsax.timer_1, size: 14, color: Colors.white70), const SizedBox(width: 4),
              Text('${active.daysRemaining} ${s.isArabic ? 'يوم' : 'days'}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
        ]),
        if (active.hotspotUsername != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Iconsax.wifi, size: 16, color: Colors.white), const SizedBox(width: 6),
                Text(s.connectionInfo, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              _credentialRow(context, s.username, active.hotspotUsername!),
              const SizedBox(height: 4),
              _credentialRow(context, s.password, active.hotspotPassword ?? ''),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _credentialRow(BuildContext context, String label, String value) {
    final s = context.read<LanguageProvider>().strings;
    return Row(children: [
      Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(width: 8),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [const Icon(Iconsax.tick_circle, color: Colors.white, size: 18), const SizedBox(width: 8), Text(s.copied)]),
            backgroundColor: const Color(0xFF22C55E), duration: const Duration(seconds: 2),
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
          child: const Icon(Iconsax.copy, size: 14, color: Colors.white),
        ),
      ),
    ]);
  }
}
