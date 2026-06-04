import 'dart:convert';

/// يمثل رحلة حديثة تُحفظ في SharedPreferences
class RecentTrip {
  final String fromName;
  final String toName;
  final int durationMinutes;
  final int price;
  final DateTime date;

  RecentTrip({
    required this.fromName,
    required this.toName,
    required this.durationMinutes,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'fromName': fromName,
        'toName': toName,
        'durationMinutes': durationMinutes,
        'price': price,
        'date': date.toIso8601String(),
      };

  factory RecentTrip.fromJson(Map<String, dynamic> json) => RecentTrip(
        fromName: json['fromName'] as String,
        toName: json['toName'] as String,
        durationMinutes: json['durationMinutes'] as int,
        price: json['price'] as int,
        date: DateTime.parse(json['date'] as String),
      );

  static String encodeList(List<RecentTrip> trips) =>
      jsonEncode(trips.map((t) => t.toJson()).toList());

  static List<RecentTrip> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => RecentTrip.fromJson(e as Map<String, dynamic>)).toList();
  }
}
