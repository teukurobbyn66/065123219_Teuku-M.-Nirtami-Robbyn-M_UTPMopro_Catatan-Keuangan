import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/finance_calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/navigation.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/charts/monthly_bar_chart.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/dashboard/budget_progress.dart';
import '../../widgets/transactions/transaction_tile.dart';
import '../add_transaction/add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onGoTo;
  const DashboardScreen({super.key, required this.onGoTo});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hidden = false;

  String _money(double v) => _hidden ? 'Rp ••••••' : Fmt.rupiah(v);

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    final name = context.watch<SettingsProvider>().userName;
    final p = context.palette;
    final now = DateTime.now();
    final monthTx = fin.inMonth(now);
    final income = FinanceCalculator.totalIncome(monthTx);
    final expense = FinanceCalculator.totalExpense(monthTx);

    return SafeArea(
      bottom: false,
      child: fin.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.l, Gap.xl, 120),
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TEUKUCASH', style: AppText.overline(context)),
                          const SizedBox(height: Gap.xs),
                          Text('${Fmt.greeting()}, $name',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.section(context).copyWith(fontSize: 20)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Profil',
                      onPressed: () => widget.onGoTo(3),
                      style: IconButton.styleFrom(
                          backgroundColor: p.tint, minimumSize: const Size(44, 44)),
                      icon: Icon(Icons.person_outline, color: p.primary),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xxl),

                // Saldo
                Text('Total saldo', style: AppText.caption(context)),
                const SizedBox(height: Gap.xs),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: FittedBox(
                          key: ValueKey(_hidden),
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(_money(fin.balance), style: AppText.balance(context)),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: _hidden ? 'Tampilkan saldo' : 'Sembunyikan saldo',
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: p.muted),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xl),

                // Ringkasan bulan ini
                Row(
                  children: [
                    Expanded(child: _Summary(label: 'Pemasukan bulan ini', value: _money(income),
                        icon: Icons.south_west, color: p.income)),
                    Container(width: 1, height: 44, color: p.divider),
                    const SizedBox(width: Gap.l),
                    Expanded(child: _Summary(label: 'Pengeluaran bulan ini', value: _money(expense),
                        icon: Icons.north_east, color: p.expense)),
                  ],
                ),
                const SizedBox(height: Gap.xxl),

                // Grafik
                const SectionHeader(title: 'Arus kas 6 bulan'),
                const SizedBox(height: Gap.s),
                ChartLegend(items: [(p.primary, 'Pemasukan'), (p.secondary, 'Pengeluaran')]),
                const SizedBox(height: Gap.l),
                SizedBox(
                  height: 180,
                  child: MonthlyBarChart(data: FinanceCalculator.monthlyTotals(fin.all, now, 6)),
                ),
                const SizedBox(height: Gap.xxl),

                // Anggaran
                SectionHeader(
                  title: 'Anggaran ${Fmt.month(now)}',
                  actionLabel: 'Kelola',
                  onAction: () => widget.onGoTo(2),
                ),
                const SizedBox(height: Gap.m),
                Container(
                  padding: const EdgeInsets.all(Gap.l),
                  decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16)),
                  child: BudgetProgress(
                    budget: fin.budgetFor(now),
                    spent: fin.expenseIn(now),
                    onSetBudget: () => widget.onGoTo(2),
                  ),
                ),
                const SizedBox(height: Gap.xxl),

                // Transaksi terbaru
                SectionHeader(
                  title: 'Transaksi terbaru',
                  actionLabel: fin.all.isEmpty ? null : 'Lihat semua',
                  onAction: () => widget.onGoTo(1),
                ),
                if (fin.recent.isEmpty)
                  const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada transaksi',
                    message: 'Ketuk tombol + untuk mencatat pemasukan atau pengeluaran pertama Anda.',
                  )
                else
                  for (var i = 0; i < fin.recent.length; i++) ...[
                    if (i > 0) const Divider(),
                    TransactionTile(
                      tx: fin.recent[i],
                      onTap: () => pushPage(context, AddTransactionScreen(editing: fin.recent[i])),
                    ),
                  ],
              ],
            ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Summary({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
              child: Text(label,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption(context))),
        ]),
        const SizedBox(height: Gap.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppText.bodyStrong(context).copyWith(fontSize: 16)),
        ),
      ],
    );
  }
}
