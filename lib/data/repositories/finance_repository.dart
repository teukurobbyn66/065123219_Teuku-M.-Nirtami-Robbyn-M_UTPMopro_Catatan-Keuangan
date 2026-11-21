import '../database/app_database.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class FinanceRepository {
  Future<List<TransactionModel>> getTransactions() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<int> insertTransaction(TransactionModel t) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now();
    final map = TransactionModel(
      title: t.title, amount: t.amount, type: t.type, category: t.category,
      date: t.date, note: t.note, createdAt: now, updatedAt: now,
    ).toMap();
    return db.insert('transactions', map);
  }

  Future<int> updateTransaction(TransactionModel t) async {
    final db = await AppDatabase.instance.database;
    final map = t.toMap()
      ..remove('created_at')
      ..['updated_at'] = DateTime.now().toIso8601String();
    return db.update('transactions', map, where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BudgetModel>> getBudgets() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('budgets');
    return rows.map(BudgetModel.fromMap).toList();
  }

  /// Membuat anggaran baru atau mengganti anggaran pada bulan yang sama.
  Future<void> upsertBudget(String month, double amount) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();
    final updated = await db.update(
      'budgets', {'amount': amount, 'updated_at': now},
      where: 'month = ?', whereArgs: [month],
    );
    if (updated == 0) {
      await db.insert('budgets', {
        'month': month, 'amount': amount, 'created_at': now, 'updated_at': now,
      });
    }
  }

  Future<void> deleteBudget(String month) async {
    final db = await AppDatabase.instance.database;
    await db.delete('budgets', where: 'month = ?', whereArgs: [month]);
  }
}
