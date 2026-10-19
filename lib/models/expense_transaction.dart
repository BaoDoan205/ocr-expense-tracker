
class ExpenseTransaction {
  final int? id;
  final String merchant;
  final DateTime date;
  final double amount;
  final String category;
  final String rawText;

  const ExpenseTransaction({
    this.id,
    required this.merchant,
    required this.date,
    required this.amount,
    required this.category,
    required this.rawText,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'date': date.toIso8601String(),
      'amount': amount,
      'category': category,
      'raw_text': rawText,
    };
  }

  factory ExpenseTransaction.fromMap(
    Map<String, Object?> map,
  ) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      merchant: map['merchant'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      rawText: map['raw_text'] as String,
    );
  }
}
