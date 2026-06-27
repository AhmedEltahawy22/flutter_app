import 'dart:convert';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'titleAr': titleAr,
        'titleEn': titleEn,
        'type': type.name,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        titleAr: json['titleAr'] as String,
        titleEn: json['titleEn'] as String,
        type: TransactionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TransactionType.topUp,
        ),
      );

  static String encodeList(List<Transaction> transactions) =>
      jsonEncode(transactions.map((t) => t.toJson()).toList());

  static List<Transaction> decodeList(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

enum TransactionType { topUp, tripDeduction }
