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
}