import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/finance_calculator.dart';
import '../../core/utils/formatters.dart';

/// Progres anggaran bulanan (dipakai di Dashboard dan Statistik).
class BudgetProgress extends StatelessWidget {
  final double budget;
  final double spent;
  final VoidCallback? onSetBudget;
  const BudgetProgress({super.key, required this.budget, required this.spent, this.onSetBudget});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (budget <= 0) {
      return Row(
        children: [
          Expanded(child: Text('Belum ada anggaran untuk bulan ini.', style: AppText.caption(context))),
          if (onSetBudget != null) TextButton(onPressed: onSetBudget, child: const Text('Atur anggaran')),
        ],
      );
    }
    final pct = FinanceCalculator.budgetUtilization(budget, spent);
    final remaining = FinanceCalculator.remainingBudget(budget, spent);
    final over = pct >= 100;
    final near = pct >= 80 && !over;
    final color = over ? p.expense : (near ? p.warn : p.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${pct.toStringAsFixed(0)}%',
                style: AppText.heading(context).copyWith(fontSize: 28, color: color)),
            const SizedBox(width: Gap.s),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('terpakai', style: AppText.caption(context)),
            ),
          ],
        ),
        const SizedBox(height: Gap.m),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: (pct / 100).clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: p.tint,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(height: Gap.m),
        Row(
          children: [
            Expanded(child: Text('${Fmt.rupiah(spent)} dari ${Fmt.rupiah(budget)}', style: AppText.caption(context))),
            Text(
              remaining >= 0 ? 'Sisa ${Fmt.rupiah(remaining)}' : 'Lebih ${Fmt.rupiah(-remaining)}',
              style: AppText.caption(context).copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (over || near) ...[
          const SizedBox(height: Gap.m),
          Row(children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: color),
            const SizedBox(width: Gap.s),
            Expanded(
              child: Text(
                over ? 'Pengeluaran sudah melebihi anggaran bulan ini.' : 'Pengeluaran mendekati batas anggaran.',
                style: AppText.caption(context).copyWith(color: color),
              ),
            ),
          ]),
        ],
      ],
    );
  }
}
