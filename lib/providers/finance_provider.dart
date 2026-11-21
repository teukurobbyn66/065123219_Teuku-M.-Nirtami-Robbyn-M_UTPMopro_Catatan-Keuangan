import 'package:flutter/foundation.dart';
import '../core/utils/finance_calculator.dart';
import '../core/utils/formatters.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceRepository _repo;
  FinanceProvider(this._repo);

  List<TransactionModel> _all = [];
  final Map<String, double> _budgets = {};
  bool loading = true;

  // filter riwayat
  String query = '';
  String? typeFilter; // null = semua
  String? categoryFilter;
  DateTime? monthFilter;

  List<TransactionModel> get all => _all;

  Future<void> load() async {
    _all = await _repo.getTransactions();
    _budgets
      ..clear()
      ..addEntries((await _repo.getBudgets()).map((b) => MapEntry(b.month, b.amount)));
    loading = false;
    notifyListeners();
  }

  // ringkasan keseluruhan
  double get totalIncome => FinanceCalculator.totalIncome(_all);
  double get totalExpense => FinanceCalculator.totalExpense(_all);
  double get balance => FinanceCalculator.balance(_all);

  List<TransactionModel> get recent => _all.take(5).toList();

  List<TransactionModel> inMonth(DateTime m) => FinanceCalculator.inMonth(_all, m);
  double budgetFor(DateTime m) => _budgets[Fmt.monthKey(m)] ?? 0;
  double expenseIn(DateTime m) => FinanceCalculator.totalExpense(inMonth(m));

  List<TransactionModel> get filtered {
    final q = query.trim().toLowerCase();
    return _all.where((t) {
      if (typeFilter != null && t.type != typeFilter) return false;
      if (categoryFilter != null && t.category != categoryFilter) return false;
      if (monthFilter != null &&
          (t.date.year != monthFilter!.year || t.date.month != monthFilter!.month)) {
        return false;
      }
      if (q.isNotEmpty &&
          !(t.title.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q) ||
              (t.note ?? '').toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get hasActiveFilter =>
      query.isNotEmpty || typeFilter != null || categoryFilter != null || monthFilter != null;

  void setQuery(String v) { query = v; notifyListeners(); }
  void setType(String? v) { typeFilter = v; notifyListeners(); }
  void setCategory(String? v) { categoryFilter = v; notifyListeners(); }
  void setMonth(DateTime? v) { monthFilter = v; notifyListeners(); }
  void clearFilters() {
    query = ''; typeFilter = null; categoryFilter = null; monthFilter = null;
    notifyListeners();
  }

  // CRUD transaksi
  Future<void> addTransaction(TransactionModel t) async {
    await _repo.insertTransaction(t);
    await load();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await _repo.updateTransaction(t);
    await load();
  }

  Future<void> deleteTransaction(int id) async {
    await _repo.deleteTransaction(id);
    await load();
  }

  // anggaran
  Future<void> setBudget(DateTime month, double amount) async {
    await _repo.upsertBudget(Fmt.monthKey(month), amount);
    await load();
  }

  Future<void> clearBudget(DateTime month) async {
    await _repo.deleteBudget(Fmt.monthKey(month));
    await load();
  }
}
