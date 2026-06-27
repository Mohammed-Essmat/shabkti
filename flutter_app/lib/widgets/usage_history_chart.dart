import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';

class UsageHistoryChart extends StatefulWidget {
  final double totalGb;
  final double usedGb;
  final int totalDays;
  final int daysElapsed;

  const UsageHistoryChart({
    super.key,
    required this.totalGb,
    required this.usedGb,
    required this.totalDays,
    required this.daysElapsed,
  });

  @override
  State<UsageHistoryChart> createState() => _UsageHistoryChartState();
}

class _UsageHistoryChartState extends State<UsageHistoryChart> {
  int? _selectedIndex;
  late List<double> _dailyUsage;

  @override
  void initState() {
    super.initState();
    _dailyUsage = _generateDailyBreakdown();
  }

  List<double> _generateDailyBreakdown() {
    final days = widget.daysElapsed.clamp(1, widget.totalDays);
    final rng = Random(42);
    final raw = List.generate(days, (_) => rng.nextDouble() * 2 + 0.5);
    final rawSum = raw.reduce((a, b) => a + b);
    return raw.map((v) => double.parse((v / rawSum * widget.usedGb).toStringAsFixed(2))).toList();
  }

  String _dayLabel(int index, bool isAr) {
    if (widget.totalDays == 1) return '${index + 1}h';
    return isAr ? 'يوم ${index + 1}' : 'Day ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAr = context.watch<LanguageProvider>().isArabic;
    final maxY = _dailyUsage.isEmpty ? 1.0 : _dailyUsage.reduce(max) * 1.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.chart_2, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Text(isAr ? 'تفاصيل الاستهلاك' : 'Usage Details', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),

        if (_selectedIndex != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.calendar_1, size: 16, color: colors.primary),
                const SizedBox(width: 6),
                Text(
                  '${_dayLabel(_selectedIndex!, isAr)} — ${_dailyUsage[_selectedIndex!].toStringAsFixed(2)} GB',
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  if (response?.spot != null) {
                    setState(() => _selectedIndex = response!.spot!.touchedBarGroupIndex);
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colors.primary,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${_dailyUsage[group.x.toInt()].toStringAsFixed(2)} GB',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.outlineVariant.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 10, color: colors.outline),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (_dailyUsage.length > 10 && i % 2 != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(fontSize: 10, color: colors.outline),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(_dailyUsage.length, (i) {
                final isSelected = _selectedIndex == i;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: _dailyUsage[i],
                      width: _dailyUsage.length > 15 ? 6 : 14,
                      color: isSelected ? colors.primary : colors.primary.withValues(alpha: 0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
              maxY: maxY,
            ),
          ),
        ),
      ],
    );
  }
}
