class TripOption {
  const TripOption({
    required this.title,
    required this.durationMinutes,
    required this.price,
    required this.steps,
  });

  final String title;
  final int durationMinutes;
  final int price;
  final List<String> steps;

  Map<String, dynamic> toJson() => {
        'title': title,
        'durationMinutes': durationMinutes,
        'price': price,
        'steps': steps,
      };

  factory TripOption.fromJson(Map<String, dynamic> json) => TripOption(
        title: json['title'] as String,
        durationMinutes: json['durationMinutes'] as int,
        price: json['price'] as int,
        steps: List<String>.from(json['steps'] as List),
      );
}