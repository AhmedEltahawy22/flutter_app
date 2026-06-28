import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'metro_graph.dart';
import 'public_transport_data.dart';

class PublicTransportService {
  // Geocoding: تحويل الاسم لإحداثيات (مقيد بنطاق القاهرة الكبرى لضمان الدقة)
  static Future<LatLng?> geocode(String name) async {
    try {
      var targetName = name;
      if (name.contains('الحيوان') && !name.contains('الحيوانات')) {
        targetName = name.replaceAll('الحيوان', 'الحيوانات');
      }
      
      final queryStr = Uri.encodeComponent(targetName);
      // نطاق القاهرة الكبرى (viewbox=left,top,right,bottom) مع تفعيل التقييد الجغرافي
      final url = 'https://nominatim.openstreetmap.org/search?q=$queryStr&format=json&limit=1&accept-language=ar&viewbox=30.80,30.30,31.60,29.80&bounded=1';
      
      var response = await http.get(Uri.parse(url), headers: {'User-Agent': 'com.example.flutter_app'});
      List<dynamic> results = [];
      if (response.statusCode == 200) {
        results = json.decode(response.body);
      }

      if (results.isNotEmpty) {
        final lat = double.parse(results.first['lat']);
        final lon = double.parse(results.first['lon']);
        return LatLng(lat, lon);
      }

      // 2. المحاولة الثانية: تنظيف الكلمات التعريفية الشائعة (مثل نادي، شارع، ميدان) والمحاولة مجدداً
      final cleanedName = name
          .replaceAll(RegExp(r'^(نادي|نادى|شارع|ميدان|منطقة|محطة)\s+'), '')
          .trim();
      if (cleanedName != name && cleanedName.isNotEmpty) {
        final cleanedQuery = Uri.encodeComponent(cleanedName);
        final cleanedUrl = 'https://nominatim.openstreetmap.org/search?q=$cleanedQuery&format=json&limit=1&accept-language=ar&viewbox=30.80,30.30,31.60,29.80&bounded=1';
        
        response = await http.get(Uri.parse(cleanedUrl), headers: {'User-Agent': 'com.example.flutter_app'});
        if (response.statusCode == 200) {
          results = json.decode(response.body);
          if (results.isNotEmpty) {
            final lat = double.parse(results.first['lat']);
            final lon = double.parse(results.first['lon']);
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      print('Geocoding Error: $e');
    }
    return null;
  }

  // Reverse Geocoding: تحويل الإحداثيات لاسم مكان
  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=ar';
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'com.example.flutter_app'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        // نرجع أدق مستوى متاح
        return address['road'] ?? address['suburb'] ?? address['city_district'] ?? address['city'] ?? data['display_name'];
      }
    } catch (e) {
      print('Reverse Geocoding Error: $e');
    }
    return null;
  }


  // Discovery: البحث عن محطات قريبة
  static Future<List<LatLng>> findNearbyStations(LatLng point) async {
    final query = '''
      [out:json];
      (
        node["public_transport"="stop_position"](around:2000, ${point.latitude}, ${point.longitude});
        node["railway"="station"](around:2000, ${point.latitude}, ${point.longitude});
      );
      out body;
    ''';
    
    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['elements'] as List)
            .map((e) => LatLng(e['lat'], e['lon']))
            .toList();
      }
    } catch (e) {
      print('Overpass Error: $e');
    }
    return [];
  }

  // البحث عن أقرب محطة توجيه (مترو أو أتوبيس) لإحداثي معين
  static LatLng? _getClosestTransitStop(LatLng point) {
    double minDistance = double.maxFinite;
    LatLng? closestStop;

    // 1. فحص محطات المترو
    for (final s in MetroGraph.stations.values) {
      final dist = (s.location.latitude - point.latitude).abs() + (s.location.longitude - point.longitude).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closestStop = s.location;
      }
    }

    // 2. فحص مناطق الأتوبيس
    for (final entry in PublicTransportData.regionCoords.entries) {
      final loc = entry.value;
      final dist = (loc.latitude - point.latitude).abs() + (loc.longitude - point.longitude).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closestStop = loc;
      }
    }
    return closestStop;
  }

  // جلب مسار مفرد من OSRM
  static Future<List<LatLng>> _fetchSingleOsrmRoute(LatLng from, LatLng to, String profile) async {
    final url = 'https://router.project-osrm.org/route/v1/$profile/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=polyline';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final String encodedGeometry = data['routes'][0]['geometry'];
          final decoded = decodePolyline(encodedGeometry);
          return decoded.map((c) => LatLng(c[0].toDouble(), c[1].toDouble())).toList();
        }
      }
    } catch (e) {
      print('OSRM $profile error: $e');
    }
    return [];
  }

  static bool _isMetroStation(LatLng loc) {
    return MetroGraph.stations.values.any((s) =>
        (s.location.latitude - loc.latitude).abs() < 0.0001 &&
        (s.location.longitude - loc.longitude).abs() < 0.0001);
  }

  // Routing: جلب المسار متعدد الوسائط وتفصيله
  static Future<Map<String, List<LatLng>>> getMultiModalRoute(LatLng start, LatLng end, {Set<String>? allowedModes}) async {
    final Map<String, List<LatLng>> segments = {
      'walkPoints1': [],
      'walkPoints2': [],
      'metroPoints': [],
      'busPoints': [],
    };

    // إذا اختار المستخدم "المشي فقط"
    if (allowedModes != null && allowedModes.contains('walk') && allowedModes.length == 1) {
      final walk = await _fetchSingleOsrmRoute(start, end, 'foot');
      segments['walkPoints1'] = walk;
      return segments;
    }

    final startStop = _getClosestTransitStop(start);
    final endStop = _getClosestTransitStop(end);

    if (startStop != null && endStop != null && startStop != endStop) {
      // 1. المشي من البداية لأقرب محطة (بروفايل foot - بعيداً عن سيارات الأوتوستراد والطرق السريعة)
      final walk1 = await _fetchSingleOsrmRoute(start, startStop, 'foot');
      
      // 2. التنقل بالمركبات من أول محطة لآخر محطة (بروفايل driving)
      final transit = await _fetchSingleOsrmRoute(startStop, endStop, 'driving');
      
      // 3. المشي من آخر محطة للوجهة النهائية (بروفايل foot)
      final walk2 = await _fetchSingleOsrmRoute(endStop, end, 'foot');

      segments['walkPoints1'] = walk1;
      segments['walkPoints2'] = walk2;
      
      // تحديد وسيلة المواصلات بناءً على نوع المحطات
      final isStartMetro = _isMetroStation(startStop);
      final isEndMetro = _isMetroStation(endStop);

      if (isStartMetro && isEndMetro) {
        // الرحلة كلها مترو
        segments['metroPoints'] = transit;
      } else if (!isStartMetro && !isEndMetro) {
        // الرحلة كلها أتوبيس/ميكروباص
        segments['busPoints'] = transit;
      } else {
        // رحلة مشتركة (نصف مترو ونصف أتوبيس)
        if (transit.isNotEmpty) {
          final half = transit.length ~/ 2;
          segments['metroPoints'] = transit.sublist(0, half);
          segments['busPoints'] = transit.sublist(half);
        }
      }
    } else {
      // Fallback: مسار سيارات مباشر مقسم بالتساوي
      final direct = await _fetchSingleOsrmRoute(start, end, 'driving');
      if (direct.isNotEmpty) {
        final oneThird = direct.length ~/ 3;
        segments['walkPoints1'] = direct.sublist(0, oneThird);
        segments['metroPoints'] = direct.sublist(oneThird, 2 * oneThird);
        segments['busPoints'] = direct.sublist(2 * oneThird);
      }
    }
    return segments;
  }
}
