// اختبارات خوارزمية المسارات - مشروع التخرج مواصلاتي
// تشغيل: flutter test test/routing_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/routing_service.dart';
import 'package:flutter_app/metro_graph.dart';

void main() {
  setUpAll(() {
    // تهيئة الرسم البياني للمترو قبل تشغيل الاختبارات
    MetroGraph.init();
  });

  // ============================================================
  // اختبارات البحث عن المسارات (findSmartRoutes)
  // ============================================================
  group('RoutingService - البحث عن المسارات', () {
    test('شبرا → المعادي: يجب أن يجد مسار بالمترو', () {
      final routes = RoutingService.findSmartRoutes('شبرا', 'المعادي');
      expect(routes, isNotEmpty, reason: 'يجب أن يوجد مسار من شبرا إلى المعادي');
      expect(routes.first.durationMinutes, greaterThan(0));
      expect(routes.first.segments, isNotEmpty);
      // يجب أن يحتوي على مقطع مترو
      final hasMetro = routes.first.segments.any((s) => s.mode == 'metro');
      expect(hasMetro, isTrue, reason: 'المسار من شبرا للمعادي يمر بالمترو');
    });

    test('الدقي → مدينة نصر: يجد مسار (تبادل خط 2 → 3)', () {
      final routes = RoutingService.findSmartRoutes('الدقي', 'مدينة نصر');
      expect(routes, isNotEmpty, reason: 'يجب أن يوجد مسار من الدقي إلى مدينة نصر');
      expect(routes.first.durationMinutes, greaterThan(0));
    });

    test('المنيرة → مصر القديمة: تعرفة 8 ج.م (≤4 محطات مترو)', () {
      final routes = RoutingService.findSmartRoutes('المنيرة', 'مصر القديمة');
      expect(routes, isNotEmpty, reason: 'يجب أن يوجد مسار من المنيرة إلى مصر القديمة');
      expect(routes.first.price, equals(8),
          reason: 'تعرفة أقل من 5 محطات = 8 ج.م');
    });

    test('حلوان → رمسيس: تعرفة 20 ج.م (>16 محطة مترو)', () {
      final routes = RoutingService.findSmartRoutes('حلوان', 'رمسيس');
      expect(routes, isNotEmpty, reason: 'يجب أن يوجد مسار من حلوان إلى رمسيس');
      expect(routes.first.price, equals(20),
          reason: 'تعرفة أكثر من 16 محطة = 20 ج.م');
    });

    test('شبرا الخيمة → حلوان: مسار طويل بين طرفي الخط', () {
      final routes = RoutingService.findSmartRoutes('شبرا الخيمة', 'حلوان');
      expect(routes, isNotEmpty, reason: 'يجب أن يوجد مسار من شبرا الخيمة إلى حلوان');
      expect(routes.first.durationMinutes, greaterThan(30));
    });

    test('مكان غير موجود: يعيد قائمة فارغة', () {
      final routes =
          RoutingService.findSmartRoutes('مكان_وهمي_xyz_123', 'مكان_آخر_abc_456');
      expect(routes, isEmpty,
          reason: 'مكان غير موجود في النظام يجب أن يعيد قائمة فارغة');
    });

    test('نفس نقطة البداية والنهاية: يعيد قائمة فارغة', () {
      final routes = RoutingService.findSmartRoutes('المعادي', 'المعادي');
      expect(routes, isEmpty,
          reason: 'البداية = النهاية يجب أن تعيد قائمة فارغة');
    });

    test('إدخال فارغ: يعيد قائمة فارغة', () {
      final routes = RoutingService.findSmartRoutes('', '');
      expect(routes, isEmpty, reason: 'إدخال فارغ يجب أن يعيد قائمة فارغة');
    });
  });

  // ============================================================
  // اختبارات صحة النتائج (Result Correctness)
  // ============================================================
  group('RoutingService - صحة النتائج', () {
    test('جميع المسارات تحتوي على segments وsteps', () {
      final routes = RoutingService.findSmartRoutes('شبرا', 'المعادي');
      expect(routes, isNotEmpty);
      for (final route in routes) {
        expect(route.segments, isNotEmpty,
            reason: 'كل مسار يجب أن يحتوي على segments');
        expect(route.steps, isNotEmpty,
            reason: 'كل مسار يجب أن يحتوي على steps');
      }
    });

    test('أوقات الرحلات منطقية (أقل من 3 ساعات داخل القاهرة)', () {
      final routes = RoutingService.findSmartRoutes('حلوان', 'شبرا الخيمة');
      expect(routes, isNotEmpty);
      for (final route in routes) {
        expect(route.durationMinutes, lessThan(180),
            reason: 'رحلة داخل القاهرة لا تتجاوز 3 ساعات');
      }
    });

    test('الأسعار منطقية (بين 0 و 50 ج.م)', () {
      final routes = RoutingService.findSmartRoutes('شبرا', 'المعادي');
      expect(routes, isNotEmpty);
      for (final route in routes) {
        expect(route.price, greaterThanOrEqualTo(0));
        expect(route.price, lessThanOrEqualTo(50),
            reason: 'الأسعار يجب ألا تتجاوز 50 ج.م');
      }
    });

    test('المسار الأول هو الأسرع', () {
      final routes = RoutingService.findSmartRoutes('حلوان', 'شبرا الخيمة');
      if (routes.length >= 2) {
        // المسار الأول يجب أن يكون مشابهاً في الوقت أو أسرع من الثاني
        expect(routes.first.durationMinutes,
            lessThanOrEqualTo(routes[1].durationMinutes + 5));
      }
    });
  });

  // ============================================================
  // اختبارات بنية المترو (Metro Graph)
  // ============================================================
  group('MetroGraph - بنية الشبكة', () {
    test('محطة السادات موجودة في الخطين 1 و 2', () {
      final station = MetroGraph.stations['sadat'];
      expect(station, isNotNull, reason: 'محطة السادات يجب أن تكون موجودة');
      expect(station!.lines, containsAll(['1', '2']),
          reason: 'السادات تبادلية بين الخط 1 والخط 2');
    });

    test('محطة الشهداء موجودة في الخطين 1 و 2', () {
      final station = MetroGraph.stations['al_shohadaa'];
      expect(station, isNotNull, reason: 'محطة الشهداء يجب أن تكون موجودة');
      expect(station!.lines, containsAll(['1', '2']),
          reason: 'الشهداء تبادلية بين الخط 1 والخط 2');
    });

    test('محطة العتبة موجودة في الخطين 2 و 3', () {
      final station = MetroGraph.stations['attaba'];
      expect(station, isNotNull, reason: 'محطة العتبة يجب أن تكون موجودة');
      expect(station!.lines, containsAll(['2', '3']),
          reason: 'العتبة تبادلية بين الخط 2 والخط 3');
    });

    test('محطة جمال عبدالناصر موجودة في الخطين 1 و 3', () {
      final station = MetroGraph.stations['gamal_abdalnasser'];
      expect(station, isNotNull);
      expect(station!.lines, containsAll(['1', '3']),
          reason: 'جمال عبدالناصر تبادلية بين الخط 1 والخط 3');
    });

    test('المترو يتصل بين الشهداء والسادات (خط 1 و 2)', () {
      MetroGraph.init();
      final connections = MetroGraph.connections;
      expect(connections['al_shohadaa'], contains('attaba'),
          reason: 'الشهداء يجب أن تتصل بالعتبة');
    });

    test('إجمالي المحطات أكثر من 50 محطة', () {
      expect(MetroGraph.stations.length, greaterThan(50),
          reason: 'مترو القاهرة يحتوي على أكثر من 50 محطة');
    });
  });

  // ============================================================
  // اختبارات تعرفة المترو (Fare Calculation)
  // ============================================================
  group('RoutingService - حساب التعرفة', () {
    test('أقل من 5 محطات: 8 ج.م', () {
      // المنيرة → مصر القديمة: السادات ← سعد زغلول ← الملك الصالح ← مار جرجس (4 محطات)
      final routes = RoutingService.findSmartRoutes('المنيرة', 'مصر القديمة');
      expect(routes, isNotEmpty, reason: 'يجب أن يوجد مسار من المنيرة إلى مصر القديمة');
      final metroRoute = routes.firstWhere(
        (r) => r.segments.any((s) => s.mode == 'metro'),
        orElse: () => routes.first,
      );
      expect(metroRoute.price, equals(8),
          reason: 'أقل من 5 محطات مترو = تعرفة 8 ج.م');
    });

    test('أكثر من 16 محطة: 20 ج.م', () {
      final routes = RoutingService.findSmartRoutes('حلوان', 'رمسيس');
      expect(routes, isNotEmpty);
      expect(routes.first.price, equals(20));
    });
  });
}
