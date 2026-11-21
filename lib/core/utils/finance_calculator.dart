import '../constants/categories.dart';
import '../../data/models/transaction_model.dart';

class MonthTotal {
  final DateTime month;
  final double income;
  final double expense;
  const MonthTotal(this.month, this.income, this.expense);
}

/// Seluruh rumus keuangan ada di sini (tidak diduplikasi di widget).
class FinanceCalculator {
  static double totalIncome(Iterable<TransactionModel> t) =>
      t.where((e) => e.type == TxType.income).fold(0.0, (s, e) => s + e.amount);

  static double totalExpense(Iterable<TransactionModel> t) =>
      t.where((e) => e.type == TxType.expense).fold(0.0, (s, e) => s + e.amount);

  /// Saldo total = pemasukan - pengeluaran.
  static double balance(Iterable<TransactionModel> t) => totalIncome(t) - totalExpense(t);

  /// Arus kas bersih = pemasukan - pengeluaran.
  static double netCashFlow(Iterable<TransactionModel> t) => balance(t);

  /// Sisa anggaran = anggaran - pengeluaran bulan tersebut.
  static double remainingBudget(double budget, double monthlyExpense) => budget - monthlyExpense;

  /// Pemakaian anggaran (%) = pengeluaran / anggaran x 100. Anggaran 0 -> 0.
  static double budgetUtilization(double budget, double monthlyExpense) =>
      budget <= 0 ? 0 : monthlyExpense / budget * 100;

  static List<TransactionModel> inMonth(Iterable<TransactionModel> t, DateTime month) =>
      t.where((e) => e.date.year == month.year && e.date.month == month.month).toList();

  static Map<String, double> expenseByCategory(Iterable<TransactionModel> t) {
    final map = <String, double>{};
    for (final e in t.where((e) => e.type == TxType.expense)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  /// Total per bulan untuk [count] bulan yang berakhir pada [endMonth].
  static List<MonthTotal> monthlyTotals(Iterable<TransactionModel> t, DateTime endMonth, int count) {
    return List.generate(count, (i) {
      final m = DateTime(endMonth.year, endMonth.month - (count - 1 - i));
      final txs = inMonth(t, m);
      return MonthTotal(m, totalIncome(txs), totalExpense(txs));
    });
  }
}
