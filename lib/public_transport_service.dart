import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

class PublicTransportService {
  // Geocoding: تحويل الاسم لإحداثيات
  static Future<LatLng?> geocode(String name) async {
    try {
      final nominatim = Nominatim(userAgent: 'com.example.flutter_app');
      final results = await nominatim.searchByName(
        query: '$name, Cairo, Egypt',
        limit: 1,
      );
      if (results.isNotEmpty) {
        return LatLng(results.first.lat, results.first.lon);
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

  // Routing: جلب المسار وتقسيمه
  static Future<Map<String, List<LatLng>>> getMultiModalRoute(LatLng start, LatLng end) async {
    // نستخدم OSRM ببروفايل foot للحصول على مسار دقيق للمشي والمواصلات
    final url = 'https://router.project-osrm.org/route/v1/foot/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=polyline&alternatives=true&steps=true';

    final Map<String, List<LatLng>> segments = {
      'walkPoints': [],
      'metroPoints': [],
      'busPoints': [],
    };

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isEmpty) return segments;

        final route = data['routes'][0];
        final String encodedGeometry = route['geometry'];
        
        // فك تشفير المسار
        final decoded = decodePolyline(encodedGeometry);
        final allPoints = decoded.map((c) => LatLng(c[0].toDouble(), c[1].toDouble())).toList();

        // منطق التقسيم: تقسيم المسار إلى 3 أجزاء متساوية لتظهر كل وسيلة بوضوح
        if (allPoints.length > 20) {
          final oneThird = allPoints.length ~/ 3;
          segments['walkPoints'] = allPoints.sublist(0, oneThird);
          segments['metroPoints'] = allPoints.sublist(oneThird, 2 * oneThird);
          segments['busPoints'] = allPoints.sublist(2 * oneThird);
        } else {
          segments['walkPoints'] = allPoints;
        }
      }
    } catch (e) {
      print('Routing Error: $e');
    }
    return segments;
  }
}
