class BudgetModel {
  final int? id;
  final String month; // format yyyy-MM
  final double amount;

  const BudgetModel({this.id, required this.month, required this.amount});

  factory BudgetModel.fromMap(Map<String, dynamic> m) => BudgetModel(
        id: m['id'] as int?,
        month: m['month'] as String,
        amount: (m['amount'] as num).toDouble(),
      );
}
