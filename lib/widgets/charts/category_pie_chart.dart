import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (s, e) => s + e.value);
    Color colorAt(int i) => p.chartColors[i % p.chartColors.length];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 48,
            sections: [
              for (var i = 0; i < entries.length; i++)
                PieChartSectionData(
                  value: entries[i].value,
                  color: colorAt(i),
                  radius: 28,
                  showTitle: false,
                ),
            ],
          )),
        ),
        const SizedBox(height: Gap.l),
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: colorAt(i), shape: BoxShape.circle)),
              const SizedBox(width: Gap.m),
              Expanded(child: Text(entries[i].key, style: AppText.body(context))),
              Text(Fmt.rupiah(entries[i].value), style: AppText.body(context)),
              const SizedBox(width: Gap.m),
              SizedBox(
                width: 44,
                child: Text('${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right, style: AppText.caption(context)),
              ),
            ]),
          ),
      ],
    );
  }
}
