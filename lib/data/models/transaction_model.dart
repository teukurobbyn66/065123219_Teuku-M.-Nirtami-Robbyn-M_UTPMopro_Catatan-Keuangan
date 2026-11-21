class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final String category;
  final DateTime date;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'] as int?,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: m['type'] as String,
        category: m['category'] as String,
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String?,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
        updatedAt: m['updated_at'] == null ? null : DateTime.parse(m['updated_at'] as String),
      );
}
