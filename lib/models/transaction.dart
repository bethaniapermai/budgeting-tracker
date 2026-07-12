class Transaction {
  final int? id;
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String category;
  final String? note;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.category,
    this.note,
  });

  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    bool? isIncome,
    DateTime? date,
    String? category,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isIncome': isIncome ? 1 : 0,
        'date': date.toIso8601String(),
        'category': category,
        'note': note,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as int?,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        isIncome: (map['isIncome'] as int) == 1,
        date: DateTime.parse(map['date'] as String),
        category: map['category'] as String,
        note: map['note'] as String?,
      );
}