import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/finance_calculator.dart';
import '../../core/utils/formatters.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthTotal> data;
  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final maxVal = data.fold<double>(0, (m, e) => [m, e.income, e.expense].reduce((a, b) => a > b ? a : b));
    if (maxVal == 0) {
      return Center(child: Text('Belum ada data untuk grafik', style: AppText.caption(context)));
    }
    return BarChart(
      BarChartData(
        maxY: maxVal * 1.2,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(Fmt.monthShort(data[i].month), style: AppText.caption(context)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              Fmt.rupiah(rod.toY),
              TextStyle(color: p.surface, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barsSpace: 4, barRods: [
              BarChartRodData(
                toY: data[i].income,
                width: 10,
                color: p.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
              BarChartRodData(
                toY: data[i].expense,
                width: 10,
                color: p.secondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ]),
        ],
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  final List<(Color, String)> items;
  const ChartLegend({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Gap.l,
      runSpacing: Gap.xs,
      children: [
        for (final (color, label) in items)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: AppText.caption(context)),
          ]),
      ],
    );
  }
}
