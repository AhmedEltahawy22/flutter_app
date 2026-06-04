class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String titleAr;
  final String titleEn;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.titleAr,
    required this.titleEn,
    required this.type,
  });
}

enum TransactionType { topUp, tripDeduction }
