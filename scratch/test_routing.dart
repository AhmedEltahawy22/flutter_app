import 'package:flutter_app/routing_service.dart';

void main() {
  final testCases = [
    {'from': 'شبرا', 'to': 'المعادي'},
    {'from': 'الدقي', 'to': 'مدينة نصر'},
    {'from': 'المنيرة', 'to': 'مصر القديمة'},
    {'from': 'حلوان', 'to': 'رمسيس'},
    {'from': 'شبرا الخيمة', 'to': 'حدائق القبة'}, // Let's see what happens
  ];

  for (final tc in testCases) {
    final from = tc['from']!;
    final to = tc['to']!;
    print('========================================');
    print('Searching Route: From "$from" To "$to"');
    print('========================================');

    try {
      final routes = RoutingService.findSmartRoutes(from, to);
      if (routes.isEmpty) {
        print('No routes found.');
        continue;
      }

      for (int i = 0; i < routes.length; i++) {
        final r = routes[i];
        print('Option ${i + 1}:');
        print('  Duration: ${r.durationMinutes} mins');
        print('  Price: ${r.price} EGP');
        print('  Steps:');
        for (final step in r.steps) {
          print('    - $step');
        }
        print('  Segments:');
        for (final seg in r.segments) {
          print('    - Mode: ${seg.mode}, Title: ${seg.title}, Subtitle: ${seg.subtitle}, Duration: ${seg.durationMinutes}m');
        }
        print('');
      }
    } catch (e, stack) {
      print('Error finding route: $e');
      print(stack);
    }
  }
}
