import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';

class UsageChart extends StatelessWidget {
  final double totalGb;
  final double usedGb;
  final double remainingGb;
  final double radius;

  const UsageChart({
    super.key,
    required this.totalGb,
    required this.usedGb,
    required this.remainingGb,
    this.radius = 80,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalGb > 0 ? (usedGb / totalGb).clamp(0.0, 1.0) : 0.0;
    final colors = Theme.of(context).colorScheme;
    final isAr = context.watch<LanguageProvider>().isArabic;

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: 10,
      percent: percent,
      animation: true,
      animationDuration: 1000,
      progressColor: colors.primary,
      backgroundColor: colors.outlineVariant.withValues(alpha: 0.3),
      circularStrokeCap: CircularStrokeCap.round,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            remainingGb.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(isAr ? 'GB متبقي' : 'GB left', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
