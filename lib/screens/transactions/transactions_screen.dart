import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/navigation.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/transactions/transaction_tile.dart';
import '../add_transaction/add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, TransactionModel tx) async {
    final fin = context.read<FinanceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: Text('"${tx.title}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ctx.palette.expense),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && tx.id != null) {
      await fin.deleteTransaction(tx.id!);
      messenger.showSnackBar(const SnackBar(content: Text('Transaksi dihapus')));
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    final fin = context.read<FinanceProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: fin.monthFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal (bulan dipakai sebagai filter)',
    );
    if (picked != null) fin.setMonth(DateTime(picked.year, picked.month));
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    final p = context.palette;
    final items = fin.filtered;

    // kelompokkan per tanggal
    final rows = <Object>[];
    DateTime? last;
    for (final t in items) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (last == null || d != last) {
        rows.add(d);
        last = d;
      }
      rows.add(t);
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.l, Gap.xl, Gap.m),
            child: Text('Transaksi', style: AppText.heading(context)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
            child: TextField(
              onChanged: fin.setQuery,
              decoration: InputDecoration(
                hintText: 'Cari judul, kategori, atau catatan',
                prefixIcon: Icon(Icons.search, color: p.muted),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
              children: [
                _Chip(label: 'Semua', selected: fin.typeFilter == null, onTap: () => fin.setType(null)),
                _Chip(label: 'Pemasukan', selected: fin.typeFilter == TxType.income,
                    onTap: () => fin.setType(TxType.income)),
                _Chip(label: 'Pengeluaran', selected: fin.typeFilter == TxType.expense,
                    onTap: () => fin.setType(TxType.expense)),
                const SizedBox(width: Gap.s),
                _Chip(
                  label: fin.monthFilter == null ? 'Semua bulan' : Fmt.month(fin.monthFilter!),
                  selected: fin.monthFilter != null,
                  icon: Icons.calendar_month_outlined,
                  onTap: () => _pickMonth(context),
                ),
                if (fin.monthFilter != null)
                  _Chip(label: 'Hapus bulan', selected: false, icon: Icons.close,
                      onTap: () => fin.setMonth(null)),
              ],
            ),
          ),
          const SizedBox(height: Gap.s),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
              children: [
                _Chip(label: 'Semua kategori', selected: fin.categoryFilter == null,
                    onTap: () => fin.setCategory(null)),
                for (final c in allCategories)
                  _Chip(label: c.name, selected: fin.categoryFilter == c.name,
                      onTap: () => fin.setCategory(c.name)),
              ],
            ),
          ),
          const SizedBox(height: Gap.s),
          Expanded(
            child: fin.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: EmptyState(
                            icon: fin.hasActiveFilter ? Icons.search_off : Icons.receipt_long_outlined,
                            title: fin.hasActiveFilter ? 'Tidak ada hasil' : 'Belum ada transaksi',
                            message: fin.hasActiveFilter
                                ? 'Coba ubah kata kunci atau filter yang dipakai.'
                                : 'Transaksi yang Anda catat akan muncul di sini.',
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, 120),
                        itemCount: rows.length,
                        itemBuilder: (ctx, i) {
                          final r = rows[i];
                          if (r is DateTime) {
                            return Padding(
                              padding: const EdgeInsets.only(top: Gap.l, bottom: Gap.xs),
                              child: Text(Fmt.dayHeader(r).toUpperCase(), style: AppText.overline(ctx)),
                            );
                          }
                          final tx = r as TransactionModel;
                          return TransactionTile(
                            tx: tx,
                            showDate: false,
                            onTap: () => pushPage(ctx, AddTransactionScreen(editing: tx)),
                            trailingAction: PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, size: 20, color: ctx.palette.muted),
                              onSelected: (v) {
                                if (v == 'edit') {
                                  pushPage(ctx, AddTransactionScreen(editing: tx));
                                } else {
                                  _confirmDelete(ctx, tx);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Ubah')),
                                PopupMenuItem(value: 'delete', child: Text('Hapus')),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(right: Gap.s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? p.primary : p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? p.primary : p.divider),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? Theme.of(context).colorScheme.onPrimary : p.muted),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppText.caption(context).copyWith(
                  color: selected ? Theme.of(context).colorScheme.onPrimary : p.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
