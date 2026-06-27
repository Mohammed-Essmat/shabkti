import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/models/package.dart';
import 'package:shabakti/providers/language_provider.dart';

class PackageCard extends StatelessWidget {
  final InternetPackage package;
  final VoidCallback onTap;

  const PackageCard({super.key, required this.package, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = _accentColor(colors);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: accent, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(package.typeLabelFor(context.read<LanguageProvider>().isArabic), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${package.dataAmountGb.toStringAsFixed(0)} GB',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${package.price.toStringAsFixed(0)} ج.م',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
