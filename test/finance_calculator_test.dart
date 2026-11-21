import 'package:flutter_test/flutter_test.dart';
import 'package:catatankeuangan/core/constants/categories.dart';
import 'package:catatankeuangan/core/utils/finance_calculator.dart';
import 'package:catatankeuangan/data/models/transaction_model.dart';

TransactionModel tx(String type, double amount, DateTime date, [String cat = 'Makanan']) =>
    TransactionModel(title: 't', amount: amount, type: type, category: cat, date: date);

void main() {
  final jan = DateTime(2026, 1, 10);
  final feb = DateTime(2026, 2, 5);
  final data = [
    tx(TxType.income, 5000000, jan, 'Gaji'),
    tx(TxType.expense, 1000000, jan),
    tx(TxType.expense, 500000, feb, 'Belanja'),
  ];

  test('saldo dan arus kas', () {
    expect(FinanceCalculator.totalIncome(data), 5000000);
    expect(FinanceCalculator.totalExpense(data), 1500000);
    expect(FinanceCalculator.balance(data), 3500000);
  });

  test('filter bulan', () {
    expect(FinanceCalculator.inMonth(data, jan).length, 2);
    expect(FinanceCalculator.totalExpense(FinanceCalculator.inMonth(data, feb)), 500000);
  });

  test('anggaran', () {
    expect(FinanceCalculator.remainingBudget(2000000, 500000), 1500000);
    expect(FinanceCalculator.budgetUtilization(2000000, 500000), 25);
    expect(FinanceCalculator.budgetUtilization(0, 500000), 0);
  });

  test('total bulanan 6 bulan', () {
    final r = FinanceCalculator.monthlyTotals(data, feb, 6);
    expect(r.length, 6);
    expect(r.last.expense, 500000);
    expect(r[4].income, 5000000);
  });
}
