import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/finance_calculator.dart';
import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/monthly_bar_chart.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/dashboard/budget_progress.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  Future<void> _editBudget(BuildContext context, double current) async {
    final fin = context.read<FinanceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ctrl = TextEditingController(
        text: current > 0 ? ThousandsFormatter().formatEditUpdate(
            TextEditingValue.empty, TextEditingValue(text: current.round().toString())).text : '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Anggaran ${Fmt.month(_month)}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(18), ThousandsFormatter()],
            decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
            validator: (v) => ThousandsFormatter.parse(v ?? '') <= 0 ? 'Masukkan jumlah lebih dari 0' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ThousandsFormatter.parse(ctrl.text));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null) {
      await fin.setBudget(_month, result);
      messenger.showSnackBar(const SnackBar(content: Text('Anggaran disimpan')));
    }
  }

  Future<void> _deleteBudget(BuildContext context) async {
    final fin = context.read<FinanceProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus anggaran?'),
        content: Text('Anggaran ${Fmt.month(_month)} akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: ctx.palette.expense),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) await fin.clearBudget(_month);
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    final p = context.palette;
    final monthTx = fin.inMonth(_month);
    final income = FinanceCalculator.totalIncome(monthTx);
    final expense = FinanceCalculator.totalExpense(monthTx);
    final net = FinanceCalculator.netCashFlow(monthTx);
    final budget = fin.budgetFor(_month);
    final byCat = FinanceCalculator.expenseByCategory(monthTx);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.l, Gap.xl, 120),
        children: [
          Text('Insight', style: AppText.heading(context)),
          const SizedBox(height: Gap.l),
          Row(
            children: [
              IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left), tooltip: 'Bulan sebelumnya'),
              Expanded(
                child: Text(Fmt.month(_month),
                    textAlign: TextAlign.center, style: AppText.bodyStrong(context)),
              ),
              IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right), tooltip: 'Bulan berikutnya'),
            ],
          ),
          const SizedBox(height: Gap.l),
          Row(
            children: [
              Expanded(child: _Stat(label: 'Pemasukan', value: income, color: p.income)),
              Expanded(child: _Stat(label: 'Pengeluaran', value: expense, color: p.expense)),
              Expanded(child: _Stat(label: 'Arus kas', value: net, color: net >= 0 ? p.income : p.expense)),
            ],
          ),
          const SizedBox(height: Gap.xxl),
          const SectionHeader(title: 'Pemasukan vs pengeluaran'),
          const SizedBox(height: Gap.s),
          ChartLegend(items: [(p.primary, 'Pemasukan'), (p.secondary, 'Pengeluaran')]),
          const SizedBox(height: Gap.l),
          SizedBox(height: 200, child: MonthlyBarChart(data: FinanceCalculator.monthlyTotals(fin.all, _month, 6))),
          const SizedBox(height: Gap.xxl),
          const SectionHeader(title: 'Pengeluaran per kategori'),
          const SizedBox(height: Gap.m),
          if (byCat.isEmpty)
            const EmptyState(
                icon: Icons.pie_chart_outline,
                title: 'Belum ada pengeluaran',
                message: 'Tidak ada pengeluaran pada bulan ini.')
          else
            CategoryPieChart(data: byCat),
          const SizedBox(height: Gap.xxl),
          SectionHeader(
            title: 'Anggaran bulanan',
            actionLabel: budget > 0 ? 'Ubah' : 'Atur',
            onAction: () => _editBudget(context, budget),
          ),
          const SizedBox(height: Gap.m),
          Container(
            padding: const EdgeInsets.all(Gap.l),
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BudgetProgress(
                    budget: budget, spent: expense, onSetBudget: () => _editBudget(context, budget)),
                if (budget > 0) ...[
                  const SizedBox(height: Gap.s),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _deleteBudget(context),
                      style: TextButton.styleFrom(foregroundColor: p.muted, padding: EdgeInsets.zero),
                      child: const Text('Hapus anggaran'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption(context)),
        const SizedBox(height: Gap.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(Fmt.rupiah(value),
              style: AppText.bodyStrong(context).copyWith(color: color, fontSize: 15)),
        ),
      ],
    );
  }
}
