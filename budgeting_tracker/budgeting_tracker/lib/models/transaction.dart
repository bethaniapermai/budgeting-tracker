class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isIncome': isIncome ? 1 : 0,
        'date': date.toIso8601String(),
        'category': category,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'],
        title: map['title'],
        amount: map['amount'],
        isIncome: map['isIncome'] == 1,
        date: DateTime.parse(map['date']),
        category: map['category'],
      );
}